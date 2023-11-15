package com.hapi.pixelfreeuikit

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.widget.FrameLayout
import android.widget.SeekBar
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.hapi.pixelfree.PFBeautyFiterType
import com.hapi.pixelfree.PixelFree
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder

class BeautyView : FrameLayout {

    private var mBeautyItemAdapter = BeautyItemAdapter()

    lateinit var pixelFreeGetter: () -> PixelFree

    constructor(context: Context) : this(context, null)
    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, 0)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    ) {
        LayoutInflater.from(context).inflate(R.layout.view_pixe, this, true)
        findViewById<RecyclerView>(R.id.reycBeautyItem).let {
            it.layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
            it.adapter = mBeautyItemAdapter

        }
        val seek = findViewById<IndicatorSeekBar>(R.id.seekbarProgress)
        mBeautyItemAdapter.itemChangeCall = {
            seek.getSeekBar().progress = (it.progress * 100).toInt()
            if (it.type == PFBeautyFiterType.PFBeautyFiterName) {
                pixelFreeGetter.invoke().pixelFreeSetFiterParam(it.name, it.progress)
            }
        }

        seek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                seek.updateTextView(p1)
                if (p2) {
                    val select = mBeautyItemAdapter.selectedItem!!
                    select.progress = p1 / 100f
                    if (select.type == PFBeautyFiterType.PFBeautyFiterName) {
                        pixelFreeGetter.invoke()
                            .pixelFreeSetFiterParam(select.name, select.progress)
                    } else {
                        pixelFreeGetter.invoke()
                            .pixelFreeSetBeautyFiterParam(select.type, select.progress)
                    }
                }
            }

            override fun onStartTrackingTouch(p0: SeekBar?) {}

            override fun onStopTrackingTouch(p0: SeekBar?) {}

        })
    }

    fun setList(list: MutableList<BeautyItem>) {
        mBeautyItemAdapter.setList(list)
        mBeautyItemAdapter.selectedItem = list.get(0)
        list.forEach() {
            if (it.type == PFBeautyFiterType.PFBeautyFiterName) {
//                pixelFreeGetter.invoke()
//                    .pixelFreeSetFiterParam(it.name, it.progress)
            } else {
                pixelFreeGetter.invoke()
                    .pixelFreeSetBeautyFiterParam(it.type, it.progress)
            }
        }
    }

    class BeautyItemAdapter : BaseQuickAdapter<BeautyItem, BaseViewHolder>(
        R.layout.item_beauty,
        ArrayList<BeautyItem>()
    ) {
        var itemChangeCall: (item: BeautyItem) -> Unit = {

        }
        var selectedItem: BeautyItem? = null


        @SuppressLint("NotifyDataSetChanged")
        override fun convert(holder: BaseViewHolder, item: BeautyItem) {
            holder.itemView.findViewById<TextView>(R.id.tvTittle).isSelected = item == selectedItem
            holder.setImageResource(R.id.ivIcon, item.selectedIcon)
            holder.setText(R.id.tvTittle, item.name)
            holder.itemView.setOnClickListener {
                selectedItem = item
                itemChangeCall.invoke(item)
                notifyDataSetChanged()
            }
        }
    }
}


