package com.hapi.pixelfreeuikit

import com.hapi.pixelfree.PFBeautyFiterType
import com.hapi.pixelfree.PFBeautyTypeOneKey
import java.io.FileInputStream
import java.io.ObjectInputStream

class PFDateHandle {

var skinDatalist = ArrayList<BeautyItem>().apply {
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
}

    fun getSkinData():ArrayList<BeautyItem> {
        val filePath = "path/to/file.dat"
        // 解档文件
        ObjectInputStream(FileInputStream(filePath)).use { inputStream ->
            skinDatalist = inputStream.readObject() as ArrayList<BeautyItem>
        }
        return skinDatalist;
    }


}