package com.hapi.pixelfreeuikit

import android.annotation.SuppressLint
import android.content.Context
import android.content.DialogInterface
import android.content.SharedPreferences
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.Toast
import com.hapi.pixelfree.PFBeautyFilterType
import com.hapi.pixelfree.PFBeautyTypeOneKey
import com.hapi.pixelfree.PixelFree
import org.json.JSONArray
import org.json.JSONObject

class PixeBeautyDialog(pixelFree: PixelFree) : BeautyDialog() {
    // 新增回调接口
    interface OnCompButtonStateListener {
        fun onCompButtonPressed(isPressed: Boolean) // true=长按按下，false=松开
    }

    private var compButtonListener: OnCompButtonStateListener? = null
    private lateinit var sharedPreferences: SharedPreferences
    private val BEAUTY_SETTINGS_KEY = "beauty_settings"

    // 设置回调的方法
    fun setOnCompButtonStateListener(listener: OnCompButtonStateListener) {
        this.compButtonListener = listener
    }
    lateinit var mPixelFree:PixelFree;
    private val page by lazy {
        mPixelFree = pixelFree;
        
        // Temporarily force default settings to bypass any JSON loading issues
        Log.d("PixeBeautyDialog", "Loading beauty settings...")
        // 打开注释，加载历史保存的 UI 配置
//        val loadedSettings = loadSavedSettings()
//        if (loadedSettings != null) {
//            Log.d("PixeBeautyDialog", "Loaded ${loadedSettings.size} pages from saved settings")
//            // Check if loaded items have correct state support
//            loadedSettings.forEach { beautyView ->
//                beautyView.mBeautyItemAdapter.data.forEach { item ->
//                    Log.d("PixeBeautyDialog", "Loaded item: ${item.name}, supportsStateIcons: ${item.supportsStateIcons}, iconBaseName: ${item.iconBaseName}")
//                }
//            }
//        } else {
//            Log.d("PixeBeautyDialog", "No saved settings found, using default pages")
//        }
        
        // For now, always use default pages to ensure correct setup
        createDefaultPages()
    }

    private fun createDefaultPages(): List<BeautyView> {
        return listOf(
            createOneKeyPage(),
            createBaseBeautyPage(),
            createShapeBeautyPage(),
            createFilterPage(),
            createStickerPage(),
            createMakeupPage()
        )
    }

    private fun createOneKeyPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyNormal, "origin", R.mipmap.filter_origin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyNatural, "自然", R.mipmap.face_ziran))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyCute, "可爱", R.mipmap.face_keai))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyGoddess, "女神", R.mipmap.face_nvsheng))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyFair, "白净", R.mipmap.face_baijin))
            })
        }
    }

    private fun createBaseBeautyPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }
            val beautyItems = ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceM_newWhitenStrength, 0.2f, "美白", "meibai"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceRuddyStrength, 0.6f, "红润", "hongrun"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceBlurStrength, 0.7f, "磨皮", "mopi"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceEyeBrighten, 0.0f, "亮眼", "liangyan"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceSharpenStrength, 0.2f, "锐化", "ruihua"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFaceH_qualityStrength, 0.2f, "增强画质", "huazhizengqiang"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterNasolabial, 0.0f, "祛法令纹", "falingwen"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterBlackEye, 0.0f, "祛黑眼圈", "heiyanquan"))
            }
            
            // Debug logging
            Log.d("PixeBeautyDialog", "Creating base beauty page with ${beautyItems.size} items:")
            beautyItems.forEach { item ->
                Log.d("PixeBeautyDialog", "Created item: ${item.name}, supportsStateIcons: ${item.supportsStateIcons}, iconBaseName: ${item.iconBaseName}")
            }
            
            setList(beautyItems)
        }
    }

    private fun createShapeBeautyPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }
            val beautyItems = ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_EyeStrength, 0.2f, "大眼", "dayan"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_thinning, 0.2f, "瘦脸", "shoulian"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_narrow, 0.2f, "瘦颧骨", "zhailian"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_chin, 0.5f, "下巴", "xiaba"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_V, 0.2f, "瘦下颔", "vlian"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_small, 0.2f, "小脸", "xianlian"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_nose, 0.2f, "鼻子", "bizhi"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_forehead, 0.5f, "额头", "etou"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_mouth, 0.5f, "嘴巴", "zuiba"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_philtrum, 0.5f, "人中", "renzhong"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_long_nose, 0.5f, "长鼻", "changbi"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_eye_space, 0.5f, "眼距", "yanju"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_smile, 0.0f, "微笑嘴角", "weixiaozuijiao"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_eye_rotate, 0.5f, "旋转眼睛", "yanjingjiaodu"))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterTypeFace_canthus, 0.0f, "开眼角", "kaiyanjiao"))
            }
            
            // Debug logging
            Log.d("PixeBeautyDialog", "Creating shape beauty page with ${beautyItems.size} items:")
            beautyItems.forEach { item ->
                Log.d("PixeBeautyDialog", "Created item: ${item.name}, supportsStateIcons: ${item.supportsStateIcons}, iconBaseName: ${item.iconBaseName}")
            }
            
            setList(beautyItems)
        }
    }

    private fun createFilterPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "origin", R.mipmap.filter_origin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "chulian", R.mipmap.chulian))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "chuxin", R.mipmap.chuxin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "fennen", R.mipmap.f_fennen1))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "lengku", R.mipmap.lengku))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "meiwei", R.mipmap.meiwei))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "naicha", R.mipmap.naicha))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "pailide", R.mipmap.pailide))

                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "qingxin", R.mipmap.qingxin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "rixi", R.mipmap.rixi))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "riza", R.mipmap.riza))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterName, 0.5f, "weimei", R.mipmap.pailide))
            })
        }
    }

    private fun createStickerPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }

            // Create the initial list with existing items
            val stickerList = ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterSticker2DFilter, "origin", R.mipmap.filter_origin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterSticker2DFilter, "flowers", R.mipmap.flowers))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterSticker2DFilter, "candy", R.mipmap.candy))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterSticker2DFilter, "maorong", R.mipmap.maorong))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterSticker2DFilter, "xiongerduo", R.mipmap.xiongerduo))
            }

            // Parse and add stickers from allStickers.json
            try {
                val inputStream = requireContext().assets.open("allStickers.json")
                val size = inputStream.available()
                val buffer = ByteArray(size)
                inputStream.read(buffer)
                inputStream.close()
                val jsonString = String(buffer, Charsets.UTF_8)

                val jsonArray = JSONArray(jsonString)
                for (i in 0 until jsonArray.length()) {
                    val jsonObject = jsonArray.getJSONObject(i)
                    val param = jsonObject.getString("mParam")
                    val title = jsonObject.getString("mTitle")

                    // Assuming you have corresponding mipmap resources named the same as mParam
                    val resId = try {
                        resources.getIdentifier(param, "mipmap", requireContext().packageName)
                    } catch (e: Exception) {
                        // Fallback to a default image if the specific one doesn't exist
                        R.mipmap.filter_origin
                    }

                    stickerList.add(BeautyItem(
                        PFBeautyFilterType.PFBeautyFilterSticker2DFilter,
                        param,
                        resId
                    ))
                }
            } catch (e: Exception) {
                e.printStackTrace()
                // Handle error (maybe log it)
            }

            setList(stickerList)
        }
    }

    private fun createMakeupPage(): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }

            // Create the initial list with existing items
            val makeupList = ArrayList<BeautyItem>().apply {
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup, 1.0f,"关闭", R.mipmap.filter_origin))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "大气", R.mipmap.makeup_elegant))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "撩人", R.mipmap.makeup_seductive))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "清新", R.mipmap.makeup_fresh))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "唯美", R.mipmap.makeup_beautiful))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "温柔", R.mipmap.makeup_gentle))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "氧气", R.mipmap.makeup_oxygen))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "妖媚", R.mipmap.makeup_charming))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "夜魅", R.mipmap.makeup_night_charm))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f,"御姐", R.mipmap.makeup_mature))
                add(BeautyItem(PFBeautyFilterType.PFBeautyFilterMakeup,1.0f, "知性", R.mipmap.makeup_intelligent))
            }

            setList(makeupList)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sharedPreferences = requireContext().getSharedPreferences("BeautySettings", Context.MODE_PRIVATE)
        
        // Clear old cached settings to ensure we use the new format
        clearOldSettings()
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.dialog_pixe, container)
    }

    @SuppressLint("ClickableViewAccessibility")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val vp = view.findViewById<BeautyViewPage>(R.id.vpEffect)
        val rgOP = view.findViewById<RadioGroup>(R.id.rgOP)
        val firstButtonId: Int = rgOP.getChildAt(0).id
        val compBtn = view.findViewById<RadioButton>(R.id.compBtn)
        compBtn.setOnTouchListener { v, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    compButtonListener?.onCompButtonPressed(true)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    compButtonListener?.onCompButtonPressed(false)
                    v.performClick()
                    true
                }
                MotionEvent.ACTION_CANCEL -> {
                    compButtonListener?.onCompButtonPressed(false)
                    true
                }
                else -> false
            }
        }

        rgOP.check(firstButtonId)

        vp.adapter = CommonViewPagerAdapter(page)
        rgOP.setOnCheckedChangeListener { p0, id ->
            val index = when (id) {
                R.id.rbFaceOnekey -> 0
                R.id.rbBaseBeauty -> 1
                R.id.rbShapeBeauty -> 2
                R.id.rbFilter -> 3
                R.id.rbSticker -> 4
                R.id.rbMakeup -> 5
                else -> 0
            }
            if (vp.currentItem == 0 && vp.currentItem != index) {
                val firstBeautyView = page.first();
                page[0].apply {
                    mBeautyItemAdapter.selectedItem?.let { selectedItem ->
                        if (selectedItem.srcType != PFBeautyTypeOneKey.PFBeautyTypeOneKeyNormal) {
                            mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFilterType.PFBeautyFilterTypeOneKey,PFBeautyTypeOneKey.PFBeautyTypeOneKeyNormal.ordinal)
                            Log.d("PixelFree", "onViewCreated: 已关闭一键美颜");
                            showOneKeyBeautyToast()
                            mBeautyItemAdapter.updateSelectedItem(listOf(mBeautyItemAdapter).first().getItem(0));
                        }
                    }

                }

            }
            if (vp.currentItem != index) {
                vp.currentItem = index
            }
        }
    }

    private fun showOneKeyBeautyToast() {
        val toast = Toast.makeText(requireContext(), "一键美颜已关闭", Toast.LENGTH_SHORT)
        toast.setGravity(Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL, 0, 100)

        // 使用Handler延迟2秒后取消Toast
        Handler(Looper.getMainLooper()).postDelayed({
            toast.cancel()
        }, 2000)

        toast.show()
    }

    override fun onDismiss(dialog: DialogInterface) {
        super.onDismiss(dialog)
        saveCurrentSettings()
    }

    private fun saveCurrentSettings() {
        val jsonArray = JSONArray()
        val pageTitles = listOf("一键美颜", "美肤", "美形", "滤镜", "贴纸", "美妆")
        
        page.forEachIndexed { index, beautyView ->
            val pageJson = JSONObject().apply {
                put("title", pageTitles[index])
                put("selIndex", beautyView.mBeautyItemAdapter.selectedItem?.let { 
                    beautyView.mBeautyItemAdapter.data.indexOf(it) 
                } ?: 0)
                
                val dataArray = JSONArray()
                beautyView.mBeautyItemAdapter.data.forEach { item ->
                    try {
                        dataArray.put(item.toJSON())
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
                put("data", dataArray)
            }
            jsonArray.put(pageJson)
        }
        sharedPreferences.edit().putString(BEAUTY_SETTINGS_KEY, jsonArray.toString()).apply()
    }

    private fun loadSavedSettings(): List<BeautyView>? {
        val savedSettings = sharedPreferences.getString(BEAUTY_SETTINGS_KEY, null) ?: return null
        try {
            val jsonArray = JSONArray(savedSettings)
            val beautyViews = mutableListOf<BeautyView>()
            
            for (i in 0 until jsonArray.length()) {
                val pageJson = jsonArray.getJSONObject(i)
                val dataArray = pageJson.getJSONArray("data")
                val items = mutableListOf<BeautyItem>()
                
                for (j in 0 until dataArray.length()) {
                    try {
                        items.add(BeautyItem.fromJSON(dataArray.getJSONObject(j)))
                    } catch (e: Exception) {
                        e.printStackTrace()
                        // Skip invalid items
                        continue
                    }
                }
                
                if (items.isEmpty()) {
                    // If no valid items were loaded, create default items for this page
                    items.addAll(createDefaultItemsForPage(i))
                }
                
                val beautyView = createBeautyView(items)
                val selIndex = try {
                    pageJson.getInt("selIndex")
                } catch (e: Exception) {
                    0
                }
                
                // Ensure selIndex is within bounds
                if (selIndex in items.indices) {
//                    beautyView.mBeautyItemAdapter.selectedItem = items[selIndex]
                    beautyView.mBeautyItemAdapter.updateSelectedItem(items[selIndex]);
                    beautyView.seek.getSeekBar().progress = (items[selIndex].progress * 100).toInt()
                } else if (items.isNotEmpty()) {
                    // If selIndex is out of bounds, select the first item
                    beautyView.mBeautyItemAdapter.selectedItem = items[0]
                }
                
                beautyViews.add(beautyView)
            }
            
            // Ensure we have all required pages
            while (beautyViews.size < 6) {
                beautyViews.add(createDefaultBeautyView(beautyViews.size))
            }
            
            return beautyViews
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }

    private fun createDefaultItemsForPage(pageIndex: Int): List<BeautyItem> {
        return when (pageIndex) {
            0 -> createOneKeyPage().mBeautyItemAdapter.data
            1 -> createBaseBeautyPage().mBeautyItemAdapter.data
            2 -> createShapeBeautyPage().mBeautyItemAdapter.data
            3 -> createFilterPage().mBeautyItemAdapter.data
            4 -> createStickerPage().mBeautyItemAdapter.data
            5 -> createMakeupPage().mBeautyItemAdapter.data
            else -> emptyList()
        }
    }

    private fun createDefaultBeautyView(pageIndex: Int): BeautyView {
        return when (pageIndex) {
            0 -> createOneKeyPage()
            1 -> createBaseBeautyPage()
            2 -> createShapeBeautyPage()
            3 -> createFilterPage()
            4 -> createStickerPage()
            5 -> createMakeupPage()
            else -> createOneKeyPage()
        }
    }

    private fun createBeautyView(items: List<BeautyItem>): BeautyView {
        return BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { mPixelFree }
            setList(ArrayList(items))
        }
    }

    private fun clearOldSettings() {
        Log.d("PixeBeautyDialog", "Clearing old cached settings to ensure fresh start")
        sharedPreferences.edit().remove(BEAUTY_SETTINGS_KEY).apply()
    }
}