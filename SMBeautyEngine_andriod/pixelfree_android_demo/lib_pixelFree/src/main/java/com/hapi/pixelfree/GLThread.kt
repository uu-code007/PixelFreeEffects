package com.hapi.pixelfree

import android.os.Handler
import android.os.HandlerThread
import android.util.Log
import com.hapi.pixelfree.gl.OpenGLTools
import java.nio.ByteBuffer
import java.util.concurrent.CountDownLatch

class GLThread {
    var mHandlerThread: HandlerThread = HandlerThread("handlerThread")
    private val mWorkHandler by lazy { Handler(mHandlerThread.looper) }
    fun attachGLContext() {
        mHandlerThread.start()
        OpenGLTools.load()
        val countDownLatch = CountDownLatch(1)
        mWorkHandler.post(Runnable {
            OpenGLTools.bind()
            switchContext()
            countDownLatch.countDown()
        })
        countDownLatch.await()
    }

    private fun switchContext() {
        OpenGLTools.switchContext()
    }

    fun getTexture(format: Int, width: Int, height: Int, buffer: ByteBuffer?): Int {
        return OpenGLTools.createTexture(format, width, height, buffer)
    }

    fun <T> runOnGLThread(wait: Boolean = false, run: () -> T?): T? {
        var ret: T? = null
        val countDownLatch = CountDownLatch(1)
        mWorkHandler.post(Runnable {
            switchContext()
            ret = run.invoke()
            if (wait) {
                countDownLatch.countDown()
            }
        })
        if (wait) {
            countDownLatch.await()
        }
        return ret
    }

    fun release() {
        mHandlerThread.quit()
        OpenGLTools.release()
    }
}