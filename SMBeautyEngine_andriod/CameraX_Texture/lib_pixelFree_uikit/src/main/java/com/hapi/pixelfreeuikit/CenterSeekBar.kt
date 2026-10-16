package com.hapi.pixelfreeuikit

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.util.TypedValue
import android.util.Log
import android.view.MotionEvent
import android.view.View

class CenterSeekBar @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyle: Int = 0
) : View(context, attrs, defStyle) {

    var onValueChanged: ((Float) -> Unit)? = null
    private var progress: Float = -1f // -1~1, 默认在最左
    private val thumbRadius: Float
    private val barHeight: Float
    private val extraMargin: Float
    private val highlightColor = Color.parseColor("#A68BFF")
    private val bgColor = Color.parseColor("#E0E0E0")
    private val thumbColor = Color.parseColor("#BAACFF") // 与原seekbar一致

    init {
        // 原seekbar thumb为16dp直径
        thumbRadius = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8f, resources.displayMetrics)
        barHeight = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 2f, resources.displayMetrics) // 更细
        extraMargin = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 2f, resources.displayMetrics) // 两端额外空余
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val left = paddingLeft.toFloat() + thumbRadius + extraMargin
        val right = width - paddingRight.toFloat() - thumbRadius - extraMargin
        val usableWidth = right - left
        val barY = height / 2f
        val center = left + usableWidth / 2
        val pos = left + ((progress + 1) / 2f) * usableWidth

        // Draw background bar
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        paint.color = bgColor
        paint.strokeWidth = barHeight
        canvas.drawLine(left, barY, right, barY, paint)

        // Draw highlight bar
        paint.color = highlightColor
        canvas.drawLine(center, barY, pos, barY, paint)

        // Draw solid thumb
        paint.color = thumbColor
        canvas.drawCircle(pos, barY, thumbRadius, paint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        val left = paddingLeft.toFloat() + thumbRadius + extraMargin
        val right = width - paddingRight.toFloat() - thumbRadius - extraMargin
        val usableWidth = right - left
        val centerX = (left + right) / 2
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                val x = event.x.coerceIn(left, right)
                progress = ((x - left) / usableWidth) * 2f - 1f
                val callbackValue = (progress + 1) / 2f
                onValueChanged?.invoke(callbackValue)
                invalidate()
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    // value: 0~1, 0.5为中点
    fun setValue(value: Float) {
        progress = value.coerceIn(0f, 1f) * 2f - 1f
        invalidate()
    }

    // 返回0~1
    fun getValue(): Float = (progress + 1) / 2f
} 