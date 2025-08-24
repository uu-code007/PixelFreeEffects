package com.hapi.pixelfreeuikit

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.SeekBar
import android.widget.TextView
import android.util.Log
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.chad.library.adapter.base.BaseQuickAdapter
import com.chad.library.adapter.base.viewholder.BaseViewHolder
import com.hapi.pixelfree.PFBeautyFilterType
import com.hapi.pixelfree.PFSrcType
import com.hapi.pixelfree.PixelFree

class BeautyView : FrameLayout {

     var mBeautyItemAdapter = BeautyItemAdapter()

    lateinit var pixelFreeGetter: () -> PixelFree
    var seek: IndicatorSeekBar;
    lateinit var centerSeekBar: CenterSeekBar
    lateinit var seekbarContainer: LinearLayout
    lateinit var seekbarValue: TextView
    lateinit var centerSeekBarContainer: LinearLayout
    lateinit var centerSeekBarValue: TextView

    // 双向调节类型（用intType判断，避免enum引用不一致问题）
    private val twoWayTypeInts = setOf(
        PFBeautyFilterType.PFBeautyFilterTypeFace_chin.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_forehead.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_mouth.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_philtrum.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_long_nose.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_eye_space.intType,
        PFBeautyFilterType.PFBeautyFilterTypeFace_eye_rotate.intType
    )

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
        centerSeekBar = findViewById<CenterSeekBar>(R.id.centerSeekBar)
        seekbarContainer = findViewById<LinearLayout>(R.id.seekbarContainer)
        seekbarValue = findViewById<TextView>(R.id.seekbarValue)
        centerSeekBarContainer = findViewById<LinearLayout>(R.id.centerSeekBarContainer)
        centerSeekBarValue = findViewById<TextView>(R.id.centerSeekBarValue)
        Log.d("BeautyView", "findViewById centerSeekBar: $centerSeekBar")
        seek.getSeekBar().progress = 20
        mBeautyItemAdapter.itemChangeCall = {
            Log.d("BeautyView", "itemChangeCall called, item=${it.name}, type=${it.type}, intType=${it.type.intType}, centerSeekBar=$centerSeekBar")
            // 判断是否为双向调节类型
            if (twoWayTypeInts.contains(it.type.intType)) {
                Log.d("BeautyView", "准备显示CenterSeekBar, 当前progress=${it.progress}, centerSeekBar=$centerSeekBar")
                centerSeekBarContainer.visibility = View.VISIBLE
                seekbarContainer.visibility = View.GONE
                // progress 0~1 -> value 0~1 (CenterSeekBar内部会映射到-1~1)
                centerSeekBar.setValue(it.progress)
                updateCenterSeekBarValue(it.progress)
                Log.d("BeautyView", "CenterSeekBar已设置VISIBLE, setValue=${it.progress}")
            } else if (it.type == PFBeautyFilterType.PFBeautyFilterSticker2DFilter || it.type == PFBeautyFilterType.PFBeautyFilterTypeOneKey) {
                seekbarContainer.visibility = View.INVISIBLE
                centerSeekBarContainer.visibility = View.GONE
                Log.d("BeautyView", "Sticker/OneKey, CenterSeekBar GONE")
            } else {
                seekbarContainer.visibility = View.VISIBLE
                centerSeekBarContainer.visibility = View.GONE
                seek.getSeekBar().progress = (it.progress * 100).toInt()
                seek.updateTextView((it.progress * 100).toInt())
                updateSeekbarValue(it.progress)
                Log.d("BeautyView", "普通类型, CenterSeekBar GONE, seekbar progress set")
            }
            
            if (it.type == PFBeautyFilterType.PFBeautyFilterName) {
                pixelFreeGetter.invoke().pixelFreeSetFilterParam(it.name, it.progress)
            }
            if (it.type == PFBeautyFilterType.PFBeautyFilterSticker2DFilter) {
                if (it.name == "origin") {
                    val byteArray = ByteArray(0)
                    pixelFreeGetter.invoke().createBeautyItemFormBundle(
                        byteArray,
                        0,
                        PFSrcType.PFSrcTypeStickerFile
                    )
                } else {
                    pixelFreeGetter.invoke().pixelFreeSetBeautyExtend(PFBeautyFilterType.PFBeautyFilterExtend,"mirrorX_1");
                    pixelFreeGetter.invoke().pixelFreeSetBeautyExtend(PFBeautyFilterType.PFBeautyFilterExtend,"rotation_90");
                    val sticker_bundle =
                        pixelFreeGetter.invoke().readBundleFile(context,it.name + ".bundle")
                    pixelFreeGetter.invoke().createBeautyItemFormBundle(
                        sticker_bundle,
                        sticker_bundle.size,
                        PFSrcType.PFSrcTypeStickerFile
                    )
                }
            }

            if (it.type == PFBeautyFilterType.PFBeautyFilterTypeOneKey) {
                pixelFreeGetter.invoke().pixelFreeSetBeautyFiterParam(PFBeautyFilterType.PFBeautyFilterTypeOneKey,it.srcType.ordinal)
            }
        }

        // CenterSeekBar回调
        centerSeekBar.onValueChanged = { value ->
            // value: 0~1, progress: 0~1
            val select = mBeautyItemAdapter.selectedItem
            if (select != null && twoWayTypeInts.contains(select.type.intType)) {
                select.progress = value
                updateCenterSeekBarValue(value)
                // 更新icon
                if (select.supportsStateIcons) {
                    Log.d("BeautyView", "CenterSeekBar changed: ${select.name}, progress: ${select.progress}, isEditing: ${select.isEditing}")
                    mBeautyItemAdapter.updateIconForItem(select)
                }
                pixelFreeGetter.invoke().pixelFreeSetBeautyFiterParam(select.type, select.progress)
            }
        }

        seek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                seek.updateTextView(p1)
                if (p2) {
                    val select = mBeautyItemAdapter.selectedItem!!
                    select.progress = p1 / 100f
                    updateSeekbarValue(select.progress)
                    
                    // Update the icon when progress changes
                    if (select.supportsStateIcons) {
                        Log.d("BeautyView", "Progress changed: ${select.name}, progress: ${select.progress}, isEditing: ${select.isEditing}")
                        mBeautyItemAdapter.updateIconForItem(select)
                    }
                    
                    if (select.type == PFBeautyFilterType.PFBeautyFilterName) {
                        pixelFreeGetter.invoke()
                            .pixelFreeSetFilterParam(select.name, select.progress)
                    } else {
                        pixelFreeGetter.invoke()
                            .pixelFreeSetBeautyFiterParam(select.type, select.progress)
                    }
                }
            }

            override fun onStartTrackingTouch(p0: SeekBar?) {
                // Set editing state when starting to track
                mBeautyItemAdapter.selectedItem?.let { item ->
                    if (item.supportsStateIcons) {
                        Log.d("BeautyView", "Start tracking: ${item.name}, setting editing state to true")
                        item.setEditingState(true)
                        mBeautyItemAdapter.updateIconForItem(item)
                    }
                }
            }

            override fun onStopTrackingTouch(p0: SeekBar?) {
                // Keep editing state after dragging is complete
                // The editing state will only be cleared when selecting another item
                mBeautyItemAdapter.selectedItem?.let { item ->
                    if (item.supportsStateIcons) {
                        Log.d("BeautyView", "Stop tracking: ${item.name}, keeping editing state true")
                        // Keep editing state as true, don't clear it
                        // item.setEditingState(false)  // Removed this line
                        mBeautyItemAdapter.updateIconForItem(item)
                    }
                }
            }

        })
    }
    
    // 更新单向SeekBar的值显示
    private fun updateSeekbarValue(value: Float) {
        // 将0~1的值转换为0~100的显示值
        val displayValue = (value * 100f).toInt()
        seekbarValue.text = displayValue.toString()
    }
    
    // 更新CenterSeekBar的值显示
    private fun updateCenterSeekBarValue(value: Float) {
        // 将0~1的值转换为-100~100的显示值，0.5显示为0
        val displayValue = ((value - 0.5f) * 200f).toInt()
        centerSeekBarValue.text = displayValue.toString()
    }

    fun setList(list: MutableList<BeautyItem>) {
        mBeautyItemAdapter.setList(list)
        
        // Properly set the first item as selected using updateSelectedItem
        if (list.isNotEmpty()) {
            mBeautyItemAdapter.updateSelectedItem(list[0])
            Log.d("BeautyView", "Initial item selected: ${list[0].name}, supportsStateIcons: ${list[0].supportsStateIcons}")
        }
        
        list.forEach() {
            if (it.type.intType < 21) {
                pixelFreeGetter.invoke()
                    .pixelFreeSetBeautyFiterParam(it.type, it.progress)
            }
        }
        
        // Set initial seekbar visibility based on first item
        if (list.isNotEmpty()) {
            val firstItem = list[0]
            if (firstItem.type == PFBeautyFilterType.PFBeautyFilterSticker2DFilter || firstItem.type == PFBeautyFilterType.PFBeautyFilterTypeOneKey) {
                seekbarContainer.visibility = View.INVISIBLE
            } else {
                seekbarContainer.visibility = View.VISIBLE
                seek.getSeekBar().progress = (firstItem.progress * 100).toInt()
                seek.updateTextView((firstItem.progress * 100).toInt())
                updateSeekbarValue(firstItem.progress)
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

        fun updateSelectedItem(item:BeautyItem?) {
            // 获取新旧选中项的位置
            val oldPosition = selectedItem?.let { data.indexOf(it) }.takeIf { it != -1 }
            val newPosition = item?.let { data.indexOf(it) }.takeIf { it != -1 }

            // Update editing state for old item
            selectedItem?.let { oldItem ->
                if (oldItem.supportsStateIcons) {
                    Log.d("BeautyView", "Clearing editing state for old item: ${oldItem.name}")
                    oldItem.setEditingState(false)
                }
            }

            // 更新选中项引用
            selectedItem = item

            // Set editing state for new item (when selected, it should be in editing mode)
            item?.let { newItem ->
                if (newItem.supportsStateIcons) {
                    Log.d("BeautyView", "Setting editing state for new item: ${newItem.name}")
                    newItem.setEditingState(true)
                }
            }

            // 只刷新受影响的item
            oldPosition?.let { notifyItemChanged(it) }
            newPosition?.let { notifyItemChanged(it) }
            if (item != null) {
                Log.d("BeautyView", "Selected new item: ${item.name}, supportsStateIcons: ${item.supportsStateIcons}")
                itemChangeCall.invoke(item)
            }
        }
        
        // Method to update icon for a specific item
        fun updateIconForItem(item: BeautyItem) {
            val position = data.indexOf(item)
            if (position != -1) {
                Log.d("BeautyView", "Updating icon for item: ${item.name} at position: $position")
                notifyItemChanged(position)
            }
        }

        @SuppressLint("NotifyDataSetChanged")
        override fun convert(holder: BaseViewHolder, item: BeautyItem) {
            holder.itemView.findViewById<TextView>(R.id.tvTittle).isSelected = item == selectedItem
            
            // Get the ImageView
            val imageView = holder.itemView.findViewById<android.widget.ImageView>(R.id.ivIcon)
            
            // Apply rounded corners for stickers, one-key beauty, skin beauty, and shape beauty
            if (item.type == PFBeautyFilterType.PFBeautyFilterSticker2DFilter || 
                item.type == PFBeautyFilterType.PFBeautyFilterTypeOneKey ||
                // Skin beauty types (美肤)
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceM_newWhitenStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceRuddyStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceEyeBrighten ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceSharpenStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFaceH_qualityStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterNasolabial ||
                item.type == PFBeautyFilterType.PFBeautyFilterBlackEye ||
                // Shape beauty types (美型)
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_EyeStrength ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_thinning ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_narrow ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_chin ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_V ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_small ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_nose ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_forehead ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_mouth ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_philtrum ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_long_nose ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_eye_space ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_smile ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_eye_rotate ||
                item.type == PFBeautyFilterType.PFBeautyFilterTypeFace_canthus) {
                imageView.setBackgroundResource(R.drawable.bg_icon_rounded)
                imageView.clipToOutline = true
                imageView.scaleType = android.widget.ImageView.ScaleType.CENTER_CROP
                Log.d("BeautyView", "Applied circular background to ${item.name}")
            } else {
                // Clear background for other types (like filters)
                imageView.background = null
                imageView.clipToOutline = false
            }
            
            // Use getCurrentIcon to get the appropriate icon based on state
            val iconResId = if (item.supportsStateIcons) {
                val currentIcon = item.getCurrentIcon(context)
                Log.d("BeautyView", "Getting icon for ${item.name}: iconBaseName=${item.iconBaseName}, progress=${item.progress}, isEditing=${item.isEditing}, iconResId=$currentIcon")
                currentIcon
            } else {
                item.selectedIcon
            }
            
            // Safety check: ensure we have a valid resource ID before setting it
            if (iconResId != 0) {
                try {
                    holder.setImageResource(R.id.ivIcon, iconResId)
                } catch (e: Exception) {
                    Log.e("BeautyView", "Failed to set image resource $iconResId for ${item.name}", e)
                    // Try to set our safe fallback icon
                    val safeFallback = getSafeFallbackIcon()
                    try {
                        holder.setImageResource(R.id.ivIcon, safeFallback)
                    } catch (ex: Exception) {
                        Log.e("BeautyView", "Failed to set safe fallback icon", ex)
                        // Last resort: try system icon
                        try {
                            holder.setImageResource(R.id.ivIcon, android.R.drawable.ic_menu_gallery)
                        } catch (exx: Exception) {
                            Log.e("BeautyView", "Failed to set system fallback icon", exx)
                        }
                    }
                }
            } else {
                Log.w("BeautyView", "Invalid resource ID (0) for ${item.name}, using safe fallback")
                val safeFallback = getSafeFallbackIcon()
                try {
                    holder.setImageResource(R.id.ivIcon, safeFallback)
                } catch (e: Exception) {
                    Log.e("BeautyView", "Failed to set safe fallback icon", e)
                }
            }
            
            holder.setText(R.id.tvTittle, item.name)
            holder.itemView.setOnClickListener {
                Log.d("BeautyView", "Item clicked: ${item.name}")
                // Use updateSelectedItem instead of direct assignment
                updateSelectedItem(item)
            }
        }
        
        // Helper method to get a safe fallback icon
        private fun getSafeFallbackIcon(): Int {
            // Try several common icons that we know we copied
            val fallbackNames = arrayOf("meibai_0", "dayan_0", "hongrun_0", "mopi_0")
            
            for (fallbackName in fallbackNames) {
                val fallbackId = context.resources.getIdentifier(fallbackName, "mipmap", context.packageName)
                if (fallbackId != 0) {
                    Log.d("BeautyView", "Using safe fallback icon: $fallbackName")
                    return fallbackId
                }
            }
            
            // If even our fallbacks fail, use system icon as last resort
            Log.w("BeautyView", "All fallback icons failed, using system icon")
            return android.R.drawable.ic_menu_gallery
        }
    }
}


