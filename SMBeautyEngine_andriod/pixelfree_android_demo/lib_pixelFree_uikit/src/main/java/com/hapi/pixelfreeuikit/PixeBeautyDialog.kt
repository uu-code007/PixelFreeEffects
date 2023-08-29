package com.hapi.pixelfreeuikit

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.RadioGroup
import com.hapi.pixelfree.PFBeautyFiterType
import com.hapi.pixelfree.PixelFree

class PixeBeautyDialog(pixelFree: PixelFree) : BeautyDialog() {

    private val page by lazy {
        listOf(BeautyView(requireContext()).apply {
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
                        PFBeautyFiterType.PFBeautyFiterTypeFaceSharpenStrength,
                        0.2f,
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
                        R.mipmap.edanlian
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
        }
        )
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.dialog_pixe, container)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val vp = view.findViewById<BeautyViewPage>(R.id.vpEffect)
        val rgOP = view.findViewById<RadioGroup>(R.id.rgOP)
        vp.adapter = CommonViewPagerAdapter(page)
        rgOP.setOnCheckedChangeListener { p0, id ->
            val index = when (id) {
                R.id.rbBaseBeauty -> 0
                R.id.rbShapeBeauty -> 1
                R.id.rbFilter -> 2
                else -> 0
            }
            if (vp.currentItem != index) {
                vp.currentItem = index
            }
        }
    }

}