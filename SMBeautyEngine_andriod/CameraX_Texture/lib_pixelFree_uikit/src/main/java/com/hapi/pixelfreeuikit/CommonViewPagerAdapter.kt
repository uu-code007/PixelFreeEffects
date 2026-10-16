package com.hapi.pixelfreeuikit

import android.view.View
import android.view.ViewGroup
import androidx.viewpager.widget.PagerAdapter

class CommonViewPagerAdapter(private val viewLists: List<View>) : PagerAdapter(){

    override fun getCount(): Int {
        return viewLists.size
    }

    override fun isViewFromObject(view: View, obj: Any): Boolean {
        return view == obj
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        container.removeView(viewLists[position]);
    }

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        container.addView(viewLists[position]);
        return viewLists[position];
    }
}