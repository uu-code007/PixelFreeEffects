package com.hapi.pixelfree_android

import android.opengl.GLES20
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.appcompat.app.AppCompatActivity
import com.hapi.avrender.HapiCapturePreView
import com.hapi.avcapture.FrameCall
import com.hapi.avcapture.VideoTrack
import com.hapi.avparam.ImgFmt
import com.hapi.avparam.VideoFrame
import com.hapi.pixelfree.PixelFree
import com.hapi.pixelfree.PFBeautyFilterType
import com.hapi.pixelfree.PFFaceDetectMode
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(AndroidJUnit4::class)
class PreviewContextTest {
    @Before
    fun bringDemoToForeground() {
        val instrumentation = InstrumentationRegistry.getInstrumentation()
        val pkg = instrumentation.targetContext.packageName
        for (permission in listOf("CAMERA", "RECORD_AUDIO", "READ_EXTERNAL_STORAGE", "WRITE_EXTERNAL_STORAGE")) {
            instrumentation.uiAutomation.grantRuntimePermission(pkg, "android.permission.$permission")
        }
        instrumentation.uiAutomation.executeShellCommand(
            "am start -W -n $pkg/com.hapi.pixelfree_android.StartActivity"
        ).use { descriptor ->
            java.io.FileInputStream(descriptor.fileDescriptor).use { it.readBytes() }
        }
        instrumentation.waitForIdleSync()
    }

    @Test
    fun imageProcessingUsesPreviewContextAndDrawsPixels() {
        ActivityScenario.launch(ImageActivity::class.java).use { scenario ->
            assertPreviewDraws(scenario)
        }
    }

    @Test
    fun originalComparisonAndReopeningKeepDrawing() {
        repeat(2) {
            ActivityScenario.launch(ImageActivity::class.java).use { scenario ->
                assertPreviewDraws(scenario)
                scenario.onActivity { it.isLongPress = true }
                Thread.sleep(200)
                assertPreviewDraws(scenario)
                scenario.onActivity { it.isLongPress = false }
                Thread.sleep(200)
                assertPreviewDraws(scenario)
            }
        }
    }

    @Test
    fun cameraProcessingUsesPreviewContextAndDrawsPixels() {
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            assertPreviewDraws(scenario)
            scenario.onActivity { it.isLongPress = true }
            Thread.sleep(200)
            assertPreviewDraws(scenario)
            scenario.onActivity { it.isLongPress = false }
            Thread.sleep(200)
            assertPreviewDraws(scenario)
        }
    }

    @Test
    fun cameraRotationKeepsTheFaceUprightForDetection() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val source = BitmapFactory.decodeResource(context.resources, R.drawable.image_face,
            BitmapFactory.Options().apply { inScaled = false })
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            assertPreviewDraws(scenario)
            lateinit var callback: FrameCall<VideoFrame>
            lateinit var sdk: PixelFree
            lateinit var preview: com.hapi.avrender.renderview.HapiGLSurfacePreview
            scenario.onActivity { activity ->
                val trackField = MainActivity::class.java.getDeclaredField("cameTrack\$delegate")
                trackField.isAccessible = true
                val track = (trackField.get(activity) as Lazy<*>).value as VideoTrack
                callback = track.frameCall!!
                track.frameCall = null
                val sdkField = MainActivity::class.java.getDeclaredField("mPixelFree\$delegate")
                sdkField.isAccessible = true
                sdk = (sdkField.get(activity) as Lazy<*>).value as PixelFree
                preview = activity.hapiCapturePreView.mHapiGLSurfacePreview
            }
            sdk.setDetectMode(PFFaceDetectMode.PF_FACE_DETECT_MODE_VIDEO)
            for (degrees in listOf(0, 90, 270)) {
                val matrix = Matrix().apply { postRotate(-degrees.toFloat()) }
                val image = Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, true)
                val argb = IntArray(image.width * image.height)
                image.getPixels(argb, 0, image.width, 0, 0, image.width, image.height)
                val rgba = ByteArray(argb.size * 4)
                argb.forEachIndexed { index, color ->
                    rgba[index * 4] = (color shr 16).toByte()
                    rgba[index * 4 + 1] = (color shr 8).toByte()
                    rgba[index * 4 + 2] = color.toByte()
                    rgba[index * 4 + 3] = (color ushr 24).toByte()
                }
                val reset = CountDownLatch(1)
                preview.queueEvent {
                    sdk.resetDetectStateOnCurrentGLThread()
                    reset.countDown()
                }
                assertTrue(reset.await(5, TimeUnit.SECONDS))
                val faces = mutableListOf<Int>()
                repeat(16) {
                    val frame = VideoFrame(image.width, image.height, ImgFmt.IMAGE_FORMAT_RGBA,
                        rgba, degrees, 4, 0).apply { rowStride = image.width * 4 }
                    callback.onProcessFrame(frame)
                    faces.add(sdk.hasFace())
                }
                assertTrue("CameraX clockwise correction=$degrees lost face: $faces",
                    faces.takeLast(8).all { it > 0 })
                val frame = VideoFrame(image.width, image.height, ImgFmt.IMAGE_FORMAT_RGBA,
                    rgba, degrees, 4, 0).apply { rowStride = image.width * 4 }
                fun outputAt(strength: Float): ByteArray {
                    sdk.pixelFreeSetBeautyFiterParam(
                        PFBeautyFilterType.PFBeautyFilterTypeFace_thinning, strength)
                    repeat(8) { callback.onProcessFrame(frame) }
                    assertTrue("Face lost before thinning comparison", sdk.hasFace() > 0)
                    return readTexture(preview, frame.textureID, image.width, image.height)
                }
                val original = outputAt(0f)
                val thinned = outputAt(1f)
                val restored = outputAt(0f)
                fun changedPixels(a: ByteArray, b: ByteArray) = argb.indices.count { pixel ->
                    (0..2).any { channel ->
                        val offset = pixel * 4 + channel
                        kotlin.math.abs((a[offset].toInt() and 255) -
                            (b[offset].toInt() and 255)) > 5
                    }
                }
                val changed = changedPixels(original, thinned)
                val residual = changedPixels(original, restored)
                android.util.Log.i("PixelFreeRegression",
                    "video thinning correction=$degrees changedPixels=$changed/${argb.size} restoredResidual=$residual")
                assertTrue("Video thinning has no visible pixel effect at rotation=$degrees: $changed",
                    changed > 100)
                assertTrue("Pixel changes are not attributable to thinning: changed=$changed residual=$residual",
                    residual < changed / 2)
                if (image !== source) image.recycle()
            }
        }
        source.recycle()
    }

    private fun readTexture(preview: com.hapi.avrender.renderview.HapiGLSurfacePreview,
                            texture: Int, width: Int, height: Int): ByteArray {
        assertTrue("Missing processed texture", texture > 0)
        val done = CountDownLatch(1)
        var failure: Throwable? = null
        val bytes = ByteArray(width * height * 4)
        preview.queueEvent {
            val previous = IntArray(1)
            val fbo = IntArray(1)
            GLES20.glGetIntegerv(GLES20.GL_FRAMEBUFFER_BINDING, previous, 0)
            GLES20.glGenFramebuffers(1, fbo, 0)
            try {
                GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fbo[0])
                GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0,
                    GLES20.GL_TEXTURE_2D, texture, 0)
                assertEquals(GLES20.GL_FRAMEBUFFER_COMPLETE,
                    GLES20.glCheckFramebufferStatus(GLES20.GL_FRAMEBUFFER))
                val pixels = ByteBuffer.allocateDirect(bytes.size)
                GLES20.glReadPixels(0, 0, width, height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, pixels)
                assertEquals(GLES20.GL_NO_ERROR, GLES20.glGetError())
                pixels.get(bytes)
            } catch (error: Throwable) {
                failure = error
            } finally {
                GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, previous[0])
                GLES20.glDeleteFramebuffers(1, fbo, 0)
                done.countDown()
            }
        }
        assertTrue("Texture read stalled", done.await(5, TimeUnit.SECONDS))
        failure?.let { throw it }
        return bytes
    }

    private fun <A : AppCompatActivity> assertPreviewDraws(scenario: ActivityScenario<A>) {
        var sdk: PixelFree? = null
        scenario.onActivity { activity ->
            val field = activity.javaClass.getDeclaredField("mPixelFree\$delegate")
            field.isAccessible = true
            sdk = (field.get(activity) as Lazy<*>).value as PixelFree
        }
        val deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(15)
        var colored = false
        while (!colored && System.nanoTime() < deadline) {
            val done = CountDownLatch(1)
            scenario.onActivity { activity ->
                val preview = activity.findViewById<HapiCapturePreView>(R.id.preview)
                    .mHapiGLSurfacePreview
                preview.queueEvent {
                    val viewport = IntArray(4)
                    GLES20.glGetIntegerv(GLES20.GL_VIEWPORT, viewport, 0)
                    if (viewport[2] > 0 && viewport[3] > 0) {
                        preview.mOpenGLRender.onDrawFrame(null)
                        val pixels = ByteBuffer.allocateDirect(16 * 16 * 4)
                        GLES20.glReadPixels(viewport[2] / 2 - 8, viewport[3] / 2 - 8,
                            16, 16, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, pixels)
                        colored = (0 until 256).any {
                            val r = pixels.get(it * 4).toInt() and 255
                            val g = pixels.get(it * 4 + 1).toInt() and 255
                            val b = pixels.get(it * 4 + 2).toInt() and 255
                            r + g + b > 30 && maxOf(r, g, b) - minOf(r, g, b) > 8
                        }
                    }
                    done.countDown()
                }
            }
            assertTrue("Preview GL queue stalled", done.await(5, TimeUnit.SECONDS))
            if (sdk!!.hasOwnedGL()) break
            if (!colored) Thread.sleep(100)
        }
        assertFalse("SDK created an unshared EGL context instead of using preview EGL",
            sdk!!.hasOwnedGL())
        assertTrue("Preview did not draw image pixels", colored)
    }
}
