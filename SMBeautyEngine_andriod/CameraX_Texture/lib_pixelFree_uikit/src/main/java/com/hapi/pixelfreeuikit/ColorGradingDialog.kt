package com.hapi.pixelfreeuikit

import android.app.Dialog
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.Window
import android.view.WindowManager
import android.widget.SeekBar
import android.widget.Switch
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.hapi.pixelfree.PixelFree

class ColorGradingDialog(
    context: Context,
    private val pixelFree: PixelFree,
    private val onDismiss: () -> Unit = {}
) : Dialog(context) {

    init {
        requestWindowFeature(Window.FEATURE_NO_TITLE)
        window?.apply {
            setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            setDimAmount(0.5f)
            setLayout(WindowManager.LayoutParams.MATCH_PARENT, WindowManager.LayoutParams.WRAP_CONTENT)
            setGravity(android.view.Gravity.BOTTOM)
            attributes.width = WindowManager.LayoutParams.MATCH_PARENT
            attributes.height = WindowManager.LayoutParams.WRAP_CONTENT
            attributes.gravity = android.view.Gravity.BOTTOM
            attributes.flags = attributes.flags or WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        }
    }

    private lateinit var recyclerView: RecyclerView
    private lateinit var switchEnable: Switch
    private var isEnabled = true
    private val colorGradingItems = mutableListOf<ColorGradingItem>()

    init {
        // 初始化颜色分级参数项
        colorGradingItems.addAll(listOf(
            ColorGradingItem("亮度", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(brightness = value) }
            },
            ColorGradingItem("对比度", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(contrast = value) }
            },
            ColorGradingItem("曝光", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(exposure = value) }
            },
            ColorGradingItem("高光", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(highlights = value) }
            },
            ColorGradingItem("阴影", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(shadows = value) }
            },
            ColorGradingItem("饱和度", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(saturation = value) }
            },
            ColorGradingItem("色温", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(temperature = value) }
            },
            ColorGradingItem("色调", -100f, 100f, 0f) { value ->
                updateColorGrading { it.copy(hue = value) }
            }
        ))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.dialog_color_grading)

        switchEnable = findViewById(R.id.switchEnable)
        recyclerView = findViewById(R.id.recyclerView)
        recyclerView.layoutManager = LinearLayoutManager(context)
        recyclerView.adapter = ColorGradingAdapter(colorGradingItems)

        switchEnable.isChecked = isEnabled
        switchEnable.setOnCheckedChangeListener { _, isChecked ->
            isEnabled = isChecked
            // 当开关状态改变时，重新应用当前的颜色分级参数
            updateColorGrading { it.copy(isUse = isEnabled) }
        }
    }

    override fun dismiss() {
        super.dismiss()
        onDismiss()
    }

    private fun updateColorGrading(update: (ColorGradingParams) -> ColorGradingParams) {
        val currentParams = ColorGradingParams(
            brightness = colorGradingItems[0].currentValue,
            contrast = colorGradingItems[1].currentValue,
            exposure = colorGradingItems[2].currentValue,
            highlights = colorGradingItems[3].currentValue,
            shadows = colorGradingItems[4].currentValue,
            saturation = colorGradingItems[5].currentValue,
            temperature = colorGradingItems[6].currentValue,
            hue = colorGradingItems[7].currentValue,
            isUse = isEnabled
        )
        
        val newParams = update(currentParams)
        val sdkParams = newParams.toSdkParams()
        
        // 添加日志输出
        android.util.Log.d("ColorGrading", "亮度 brightness: ${sdkParams.brightness}")
        android.util.Log.d("ColorGrading", "对比度 contrast: ${sdkParams.contrast}")
        android.util.Log.d("ColorGrading", "曝光 exposure: ${sdkParams.exposure}")
        android.util.Log.d("ColorGrading", "高光 highlights: ${sdkParams.highlights}")
        android.util.Log.d("ColorGrading", "阴影 shadows: ${sdkParams.shadows}")
        android.util.Log.d("ColorGrading", "饱和度 saturation: ${sdkParams.saturation}")
        android.util.Log.d("ColorGrading", "色温 temperature: ${sdkParams.temperature}")
        android.util.Log.d("ColorGrading", "色调 hue: ${sdkParams.hue}")
        android.util.Log.d("ColorGrading", "是否启用 isUse: ${newParams.isUse}")
        
        pixelFree.setColorGrading(
            sdkParams.brightness,
            sdkParams.contrast,
            sdkParams.exposure,
            sdkParams.highlights,
            sdkParams.shadows,
            sdkParams.saturation,
            sdkParams.temperature,
            sdkParams.tint,
            sdkParams.hue,
            newParams.isUse
        )
    }

    private inner class ColorGradingAdapter(
        private val items: List<ColorGradingItem>
    ) : RecyclerView.Adapter<ColorGradingAdapter.ViewHolder>() {

        inner class ViewHolder(view: View) : RecyclerView.ViewHolder(view) {
            val title: TextView = view.findViewById(R.id.title)
            val valueText: TextView = view.findViewById(R.id.valueText)
            val seekBar: SeekBar = view.findViewById(R.id.seekBar)
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_color_grading, parent, false)
            return ViewHolder(view)
        }

        override fun onBindViewHolder(holder: ViewHolder, position: Int) {
            val item = items[position]
            holder.title.text = item.name
            holder.valueText.text = item.currentValue.toInt().toString()
            
            val range = (item.maxValue - item.minValue).toInt().coerceAtLeast(1)
            holder.seekBar.max = range
            val progress = (item.currentValue - item.minValue).toInt().coerceIn(0, range)
            holder.seekBar.progress = progress

            holder.seekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
                override fun onProgressChanged(seekBar: SeekBar, progress: Int, fromUser: Boolean) {
                    if (fromUser) {
                        val value = item.minValue + progress.toFloat()
                        item.currentValue = value
                        holder.valueText.text = value.toInt().toString()
                        item.onValueChanged(value)
                    }
                }

                override fun onStartTrackingTouch(seekBar: SeekBar) {}
                override fun onStopTrackingTouch(seekBar: SeekBar) {}
            })
        }

        override fun getItemCount() = items.size
    }

    data class ColorGradingItem(
        val name: String,
        val minValue: Float,
        val maxValue: Float,
        var currentValue: Float,
        val onValueChanged: (Float) -> Unit
    )

    data class ColorGradingParams(
        val brightness: Float,
        val contrast: Float,
        val exposure: Float,
        val highlights: Float,
        val shadows: Float,
        val saturation: Float,
        val temperature: Float,
        val hue: Float,
        val isUse: Boolean = true  // 默认启用
    ) {
        fun toSdkParams(): SdkColorGradingParams {
            fun delta(value: Float): Float = value.coerceIn(-100f, 100f) / 10f

            val brightnessDelta = delta(brightness)
            val contrastDelta = delta(contrast)
            val exposureDelta = delta(exposure)
            val highlightsDelta = delta(highlights)
            val shadowsDelta = delta(shadows)
            val saturationDelta = delta(saturation)
            val temperatureDelta = delta(temperature)
            val hueDelta = delta(hue)

            return SdkColorGradingParams(
                brightness = brightnessDelta * 0.01f,
                contrast = 1.0f + contrastDelta * 0.03f,
                exposure = exposureDelta * 0.05f,
                highlights = highlightsDelta * 0.035f,
                shadows = shadowsDelta * 0.03f,
                saturation = 1.0f + saturationDelta * 0.003f,
                temperature = 5000.0f + temperatureDelta * 100.0f,
                tint = 0.0f,
                hue = hueDelta * 0.5f
            )
        }
    }

    data class SdkColorGradingParams(
        val brightness: Float,
        val contrast: Float,
        val exposure: Float,
        val highlights: Float,
        val shadows: Float,
        val saturation: Float,
        val temperature: Float,
        val tint: Float,
        val hue: Float
    )
}
