package com.byteflow.pixelfree

import android.os.Handler
import android.os.HandlerThread
import com.byteflow.pixelfree.gl.OpenGLTools
import java.nio.ByteBuffer

class GLThread {
    var mHandlerThread: HandlerThread = HandlerThread("handlerThread")
    private val mWorkHandler by lazy { Handler(mHandlerThread.looper) }
    fun attachGLContext(callback: Runnable) {
        mHandlerThread.start()
        OpenGLTools.load()
        mWorkHandler.post(Runnable {
            OpenGLTools.bind()
            switchContext()
            callback.run()
        })
    }

    private fun switchContext() {
        OpenGLTools.switchContext()
    }

    fun getTexture(width: Int, height: Int, buffer: ByteBuffer): Int {
        return OpenGLTools.createTexture(width, height, buffer)
    }

    fun runOnGLThread(runnable: Runnable) {
        mWorkHandler.post(Runnable {
            switchContext()
            runnable.run()
        })
    }

    fun release() {
        mHandlerThread.quit()
        OpenGLTools.release()
    }
}