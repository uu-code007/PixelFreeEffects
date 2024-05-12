package com.hapi.pixelfreeuikit

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.SeekBar
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.hapi.pixelfree.PFBeautyFiterType
import com.hapi.pixelfree.PFSrcType
import com.hapi.pixelfree.PixelFree

class BeautyView : FrameLayout {

     var mBeautyItemAdapter = BeautyItemAdapter()

    lateinit var pixelFreeGetter: () -> PixelFree
    var seek: IndicatorSeekBar;

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
        seek = findViewById<IndicatorSeekBar>(R.id.seekbarProgress)
        seek.getSeekBar().progress = 20
        mBeautyItemAdapter.itemChangeCall = {
            seek.getSeekBar().progress = (it.progress * 100).toInt()
            if (it.type == PFBeautyFiterType.PFBeautyFiterName) {
                pixelFreeGetter.invoke().pixelFreeSetFiterParam(it.name, it.progress)
            }
            if (it.type == PFBeautyFiterType.PFBeautyFiterSticker2DFilter) {
                if (it.name == "origin") {
                    val byteArray = ByteArray(0)
                    pixelFreeGetter.invoke().createBeautyItemFormBundle(
                        byteArray,
                        0,
                        PFSrcType.PFSrcTypeStickerFile
                    )
                } else {
                    pixelFreeGetter.invoke().pixelFreeSetBeautyExtend(PFBeautyFiterType.PFBeautyFiterExtend,"mirrorX_1");
                    val sticker_bundle =
                        pixelFreeGetter.invoke().readBundleFile(context,it.name + ".bundle")
                    pixelFreeGetter.invoke().createBeautyItemFormBundle(
                        sticker_bundle,
                        sticker_bundle.size,
                        PFSrcType.PFSrcTypeStickerFile
                    )
                }
            }

            if (it.type == PFBeautyFiterType.PFBeautyFiterTypeOneKey) {
                pixelFreeGetter.invoke().pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeOneKey,it.srcType.ordinal)
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
            if (it.type.intType < 21) {
                pixelFreeGetter.invoke()
                    .pixelFreeSetBeautyFiterParam(it.type, it.progress)
            }
            if (it.type == PFBeautyFiterType.PFBeautyFiterSticker2DFilter || it.type == PFBeautyFiterType.PFBeautyFiterTypeOneKey) {
                seek!!.visibility = View.INVISIBLE
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


