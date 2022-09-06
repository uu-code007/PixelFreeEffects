package com.hapi.pixelfreeuikit;

import com.byteflow.pixelfree.PFBeautyFiterType;

public class BeautyItem {
    public PFBeautyFiterType type;
    public float progress = 0;
    public String name;
    public int selectedIcon;

    public BeautyItem(PFBeautyFiterType type, String name, int selectedIcon) {
        this.type = type;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }

    public BeautyItem(PFBeautyFiterType type, float progress, String name, int selectedIcon) {
        this.type = type;
        this.progress = progress;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }
}
