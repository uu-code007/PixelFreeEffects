package com.hapi.camerax_texture.record

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import android.opengl.EGL14
import android.opengl.EGLContext
import android.opengl.GLES20
import android.util.Log
import com.hapi.camerax_texture.gl.Texture2DDrawer

internal class TextureVideoRecorder(
    private val outputPath: String,
    requestedWidth: Int,
    requestedHeight: Int,
    private val bitRate: Int = 4_000_000,
    private val frameRate: Int = 30
) {
    companion object {
        private const val TAG = "TextureVideoRecorder"
    }

    private val width = requestedWidth.coerceAtLeast(2) and 1.inv()
    private val height = requestedHeight.coerceAtLeast(2) and 1.inv()
    private lateinit var encoder: MediaCodec
    private lateinit var muxer: MediaMuxer
    private lateinit var inputSurface: InputSurface
    private lateinit var drawer: Texture2DDrawer
    private val bufferInfo = MediaCodec.BufferInfo()
    private var muxerStarted = false
    private var trackIndex = -1
    private var sampleCount = 0

    fun start(sharedContext: EGLContext) {
        Log.i(TAG, "Start recorder path=$outputPath, size=${width}x${height}")
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height)
        format.setInteger(
            MediaFormat.KEY_COLOR_FORMAT,
            MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface
        )
        format.setInteger(MediaFormat.KEY_BIT_RATE, bitRate)
        format.setInteger(MediaFormat.KEY_FRAME_RATE, frameRate)
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)

        encoder = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        encoder.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        val surface = encoder.createInputSurface()
        encoder.start()

        muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        inputSurface = InputSurface(surface, sharedContext)
        drawer = Texture2DDrawer()
    }

    fun drawFrame(textureId: Int, presentationTimeNs: Long) {
        drainEncoder(false)

        val oldDisplay = EGL14.eglGetCurrentDisplay()
        val oldDraw = EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW)
        val oldRead = EGL14.eglGetCurrentSurface(EGL14.EGL_READ)
        val oldContext = EGL14.eglGetCurrentContext()

        inputSurface.makeCurrent()
        GLES20.glViewport(0, 0, width, height)
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        drawer.draw(textureId, mirrorX = false, flipY = false)
        inputSurface.setPresentationTime(presentationTimeNs.coerceAtLeast(0L))
        inputSurface.swapBuffers()

        EGL14.eglMakeCurrent(oldDisplay, oldDraw, oldRead, oldContext)
        drainEncoder(false)
    }

    fun stop() {
        var pendingError: Throwable? = null
        try {
            drainEncoder(true)
        } catch (t: Throwable) {
            pendingError = t
            Log.e(TAG, "Drain encoder failed", t)
        }

        try {
            if (::drawer.isInitialized) {
                drawer.release()
            }
        } catch (t: Throwable) {
            Log.w(TAG, "Release drawer failed", t)
        }
        try {
            if (::inputSurface.isInitialized) {
                inputSurface.release()
            }
        } catch (t: Throwable) {
            Log.w(TAG, "Release input surface failed", t)
        }
        try {
            if (::encoder.isInitialized) {
                encoder.stop()
                encoder.release()
            }
        } catch (t: Throwable) {
            if (pendingError == null) pendingError = t
            Log.e(TAG, "Release encoder failed", t)
        }
        try {
            if (::muxer.isInitialized) {
                if (muxerStarted && sampleCount > 0) {
                    muxer.stop()
                }
                muxer.release()
            }
        } catch (t: Throwable) {
            if (pendingError == null) pendingError = t
            Log.e(TAG, "Release muxer failed, muxerStarted=$muxerStarted sampleCount=$sampleCount", t)
        }

        if (pendingError != null) {
            throw pendingError
        }
        if (sampleCount <= 0) {
            throw IllegalStateException("No encoded video frame was written")
        }
        Log.i(TAG, "Stop recorder success, samples=$sampleCount")
    }

    private fun drainEncoder(endOfStream: Boolean) {
        if (endOfStream) {
            encoder.signalEndOfInputStream()
        }

        while (true) {
            val encoderStatus = encoder.dequeueOutputBuffer(bufferInfo, 0)
            when {
                encoderStatus == MediaCodec.INFO_TRY_AGAIN_LATER -> {
                    if (!endOfStream) {
                        return
                    }
                }
                encoderStatus == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    if (muxerStarted) {
                        throw RuntimeException("Format changed twice")
                    }
                    trackIndex = muxer.addTrack(encoder.outputFormat)
                    muxer.start()
                    muxerStarted = true
                }
                encoderStatus >= 0 -> {
                    val encodedData = encoder.getOutputBuffer(encoderStatus)
                        ?: throw RuntimeException("Encoder output buffer was null")
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG != 0) {
                        bufferInfo.size = 0
                    }
                    if (bufferInfo.size != 0) {
                        if (!muxerStarted) {
                            throw RuntimeException("Muxer has not started")
                        }
                        encodedData.position(bufferInfo.offset)
                        encodedData.limit(bufferInfo.offset + bufferInfo.size)
                        muxer.writeSampleData(trackIndex, encodedData, bufferInfo)
                        sampleCount++
                    }
                    encoder.releaseOutputBuffer(encoderStatus, false)
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        return
                    }
                }
            }
        }
    }
}
