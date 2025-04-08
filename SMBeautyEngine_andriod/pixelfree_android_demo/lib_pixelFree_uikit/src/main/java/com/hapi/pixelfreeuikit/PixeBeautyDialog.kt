package com.hapi.pixelfreeuikit

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.RadioButton
import android.widget.RadioGroup
import com.hapi.pixelfree.PFBeautyFiterType
import com.hapi.pixelfree.PFBeautyTypeOneKey
import com.hapi.pixelfree.PixelFree

class PixeBeautyDialog(pixelFree: PixelFree) : BeautyDialog() {
    // 新增回调接口
    interface OnCompButtonStateListener {
        fun onCompButtonPressed(isPressed: Boolean) // true=长按按下，false=松开
    }

    private var compButtonListener: OnCompButtonStateListener? = null

    // 设置回调的方法
    fun setOnCompButtonStateListener(listener: OnCompButtonStateListener) {
        this.compButtonListener = listener
    }
    lateinit var mPixelFree:PixelFree;
    private val page by lazy {
        mPixelFree = pixelFree;
        listOf(BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { pixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeOneKey,
                        PFBeautyTypeOneKey.PFBeautyTypeOneKeyNormal,
                        "origin",
                        R.mipmap.filter_origin
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyNatural,
                        "自然",
                        R.mipmap.face_ziran,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyCute,
                        "可爱",
                        R.mipmap.face_keai,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyGoddess,
                        "女神",
                        R.mipmap.face_nvsheng,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeOneKey, PFBeautyTypeOneKey.PFBeautyTypeOneKeyFair,
                        "白净",
                        R.mipmap.face_baijin,
                    )
                )
            })
        },BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { pixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceWhitenStrength,
                        0.2f,
                        "美白",
                        R.mipmap.meibai
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceRuddyStrength,
                        0.6f,
                        "红润",
                        R.mipmap.hongrun
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceBlurStrength,
                        0.7f,
                        "磨皮",
                        R.mipmap.mopi
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceEyeBrighten,
                        0.0f,
                        "亮眼",
                        R.mipmap.liangyan
                    )
                )
                // android 建议配置低一些
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceSharpenStrength,
                        0.3f,
                        "锐化",
                        R.mipmap.ruihua
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFaceH_qualityStrength,
                        0.2f,
                        "增强画质",
                        R.mipmap.huazhizengqiang
                    )
                )
            })
        }, BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { pixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_EyeStrength,
                        0.2f,
                        "大眼",
                        R.mipmap.dayan
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_thinning,
                        0.2f,
                        "瘦脸",
                        R.mipmap.shoulian
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_narrow,
                        0.2f,
                        "窄脸",
                        R.mipmap.zhailian
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_chin,
                        0.5f,
                        "下巴",
                        R.mipmap.xiaba
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_V,
                        0.2f,
                        "v脸",
                        R.mipmap.vlian
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_small,
                        0.2f,
                        "小脸",
                        R.mipmap.xianlian
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_nose,
                        0.2f,
                        "鼻子",
                        R.mipmap.bizhi
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_forehead,
                        0.5f,
                        "额头",
                        R.mipmap.etou
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_mouth,
                        0.5f,
                        "嘴巴",
                        R.mipmap.zuiba
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_philtrum,
                        0.5f,
                        "人中",
                        R.mipmap.renzhong
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_long_nose,
                        0.5f,
                        "长鼻",
                        R.mipmap.changbi
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_eye_space,
                        0.5f,
                        "眼距",
                        R.mipmap.yanju
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_smile,
                        0.0f,
                        "微笑嘴角",
                        R.mipmap.weixiaozuijiao
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_eye_rotate,
                        0.5f,
                        "旋转眼睛",
                        R.mipmap.yanjingjiaodu
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterTypeFace_canthus,
                        0.0f,
                        "开眼角",
                        R.mipmap.kaiyanjiao
                    )
                )
            })
        }, BeautyView(requireContext()).apply {
            this.pixelFreeGetter = { pixelFree }
            setList(ArrayList<BeautyItem>().apply {
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "origin",
                        R.mipmap.filter_origin,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "meibai1",
                        R.mipmap.f_meibai1,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "liangbai1",
                        R.mipmap.f_bailiang,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "fennen1",
                        R.mipmap.f_fennen1,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "nuansediao1",
                        R.mipmap.f_nuansediao1,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "gexing1",
                        R.mipmap.f_gexing1,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "xiaoqingxin1",
                        R.mipmap.f_xiaoqingxin1,
                    )
                )
                add(
                    BeautyItem(
                        PFBeautyFiterType.PFBeautyFiterName, 0.5f,
                        "heibai1",
                        R.mipmap.f_heibai1,
                    )
                )
            })
        },
            BeautyView(requireContext()).apply {
                this.pixelFreeGetter = { pixelFree }
                setList(ArrayList<BeautyItem>().apply {
                    add(
                        BeautyItem(
                            PFBeautyFiterType.PFBeautyFiterSticker2DFilter,
                            "origin",
                            R.mipmap.filter_origin,
                        )
                    )
                    add(
                        BeautyItem(
                            PFBeautyFiterType.PFBeautyFiterSticker2DFilter,
                            "flowers",
                            R.mipmap.flowers,
                        )
                    )
                    add(
                        BeautyItem(
                            PFBeautyFiterType.PFBeautyFiterSticker2DFilter,
                            "candy",
                            R.mipmap.candy,
                        )
                    )
                    add(
                        BeautyItem(
                            PFBeautyFiterType.PFBeautyFiterSticker2DFilter,
                            "maorong",
                            R.mipmap.maorong,
                        )
                    )
                    add(
                        BeautyItem(
                            PFBeautyFiterType.PFBeautyFiterSticker2DFilter,
                            "xiongerduo",
                            R.mipmap.xiongerduo,
                        )
                    )
                })
            }
        )
    }


//    fun c(){
//        page.forEach {
//            it.mBeautyItemAdapter.data.forEach {
//                it.name
//                it.progress
//            }
//            it.mBeautyItemAdapter.notifyDataSetChanged()
//        }
//    }
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
                    // 确保调用 performClick() 以支持无障碍功能
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
                else -> 0
            }
            if (vp.currentItem == 0 && vp.currentItem != index) {
                mPixelFree.pixelFreeSetBeautyFiterParam(PFBeautyFiterType.PFBeautyFiterTypeOneKey,PFBeautyTypeOneKey.PFBeautyTypeOneKeyNormal.ordinal)
            }
            if (vp.currentItem != index) {
                vp.currentItem = index
            }
        }
    }


}