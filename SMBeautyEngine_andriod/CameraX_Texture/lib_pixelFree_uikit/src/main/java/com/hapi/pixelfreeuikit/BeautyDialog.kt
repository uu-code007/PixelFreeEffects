package com.hapi.pixelfreeuikit

import android.content.DialogInterface
import android.os.Bundle
import android.view.*
import androidx.fragment.app.DialogFragment

open class BeautyDialog : DialogFragment() {
    var dismissCall: () -> Unit = {}
    private var mdimAmount = 0f
    private var mGravityEnum: Int = Gravity.BOTTOM


    private fun Window.applyGravityStyle(
        gravity: Int, resId: Int?, width: Int = ViewGroup.LayoutParams.MATCH_PARENT,
        height: Int = ViewGroup.LayoutParams.WRAP_CONTENT, x: Int = 0, y: Int = 0
    ) {
        val attributes = this.attributes
        attributes.gravity = gravity
        attributes.width = width
        attributes.height = height
        attributes.x = x
        attributes.y = y
        this.attributes = attributes
        resId?.let { this.setWindowAnimations(it) }
    }

    override fun onStart() {
        super.onStart()
        //STYLE_NO_FRAME设置之后会调至无法自动点击外部自动消失，因此添加手动控制
        dialog?.setCanceledOnTouchOutside(true)
        dialog?.window?.applyGravityStyle(mGravityEnum, null)
        if (mdimAmount >= 0) {
            val window = dialog!!.window
            val windowParams: WindowManager.LayoutParams = window!!.attributes
            windowParams.dimAmount = mdimAmount
            window.attributes = windowParams
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setStyle(androidx.fragment.app.DialogFragment.STYLE_NO_FRAME, R.style.dialogFullScreen)
    }

    override fun onResume() {
        super.onResume()
        dialog?.setCanceledOnTouchOutside(true)
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        dismissCall.invoke()
    }
}
