package com.hapi.avparam

import android.media.MediaFormat
import java.nio.ByteBuffer
import java.security.InvalidParameterException

interface IMuxer {

    //链接回调
    var mMuxerConnectCallBack: MuxerConnectCallBack?

    //码率调节
    var mVideoBitrateRegulatorCallBack: ((Int) -> Unit)?
    var mAudioBitrateRegulatorCallBack: ((Int) -> Unit)?

    val mVideoEncoderCallBack: EncoderCallBack
    val mAudioEncoderCallBack: EncoderCallBack

    fun start(url: String, param: EncodeParam)
    fun stop()
    fun init()
    fun unInit()

    fun videoGenerateExtra( format: MediaFormat): ByteBuffer {
        val csd0 = format.getByteBuffer("csd-0")
        val csd1 = format.getByteBuffer("csd-1")

        var byteBufferSize = csd0?.limit() ?: 0
        byteBufferSize += csd1?.limit() ?: 0

        val extra = ByteBuffer.allocate(byteBufferSize)
        csd0?.let { extra.put(it) }
        csd1?.let { extra.put(it) }

        extra.rewind()
        return extra
    }

    fun audioGenerateExtra(buffer: ByteBuffer, format: MediaFormat): ByteBuffer {
        when (val mimeType = format.getString(MediaFormat.KEY_MIME)) {
            MediaFormat.MIMETYPE_AUDIO_AAC -> {
                return Adts(format, buffer.limit()).toByteBuffer()
            }
            MediaFormat.MIMETYPE_AUDIO_OPUS -> {
                TODO("Not yet implemented")
            }
            else -> {
                throw InvalidParameterException("Format is not supported: $mimeType")
            }
        }
    }
}