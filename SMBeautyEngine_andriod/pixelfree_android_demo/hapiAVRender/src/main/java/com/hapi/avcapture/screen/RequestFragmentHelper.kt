package com.hapi.avcapture.screen;

import androidx.fragment.app.FragmentActivity

object RequestFragmentHelper {
    private val TAG = "RequestFragmentHelper"
    // 获取Fragment的方法
    fun getPermissionReqFragment(activity: FragmentActivity): RequestFragment {
        // 查询是否已经存在了该Fragment，这样是为了让该Fragment只有一个实例
        var permissionsFragment: RequestFragment? = findPhotoRequstFragment(activity)
        val isNewInstance = permissionsFragment == null
        // 如果还没有存在，则创建Fragment，并添加到Activity中
        if (isNewInstance) {
            permissionsFragment = RequestFragment()
            val fragmentManager = activity.supportFragmentManager
            fragmentManager
                .beginTransaction()
                .add(permissionsFragment, TAG)
                .commitAllowingStateLoss()
            fragmentManager.executePendingTransactions()
        }
        return permissionsFragment!!
    }

    // 利用tag去找是否已经有该Fragment的实例
    private fun findPhotoRequstFragment(activity: FragmentActivity): RequestFragment? {
        return activity.fragmentManager.findFragmentByTag(TAG) as RequestFragment?
    }
}