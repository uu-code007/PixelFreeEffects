package com.hapi.pixelfreeuikit;

import com.hapi.pixelfree.PFBeautyFilterType;
import com.hapi.pixelfree.PFBeautyTypeOneKey;
import org.json.JSONException;
import org.json.JSONObject;

public class BeautyItem {
    public PFBeautyFilterType type;
    public float progress = 0;
    public String name;
    public int selectedIcon;
    public PFBeautyTypeOneKey srcType;
    
    // New fields for icon states
    public String iconBaseName; // Base name for icon (e.g., "meibai", "dayan")
    public boolean isEditing = false; // Whether the item is currently being edited
    public boolean supportsStateIcons = false; // Whether this item supports different icon states

    public BeautyItem(PFBeautyFilterType type, String name, int selectedIcon) {
        this.type = type;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }

    public BeautyItem(PFBeautyFilterType type, float progress, String name, int selectedIcon) {
        this.type = type;
        this.progress = progress;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }

    public BeautyItem(PFBeautyFilterType type, PFBeautyTypeOneKey srcType, String name, int selectedIcon) {
        this.type = type;
        this.srcType = srcType;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }
    
    // New constructor with icon base name for state-based icons
    public BeautyItem(PFBeautyFilterType type, float progress, String name, int selectedIcon, String iconBaseName) {
        this.type = type;
        this.progress = progress;
        this.name = name;
        this.iconBaseName = iconBaseName;
        this.supportsStateIcons = true;
        // Don't use the provided selectedIcon for state-based icons
        // We'll dynamically get it in getCurrentIcon()
        this.selectedIcon = selectedIcon; // Keep as fallback, but we'll try dynamic first
    }
    
    // Simplified constructor for state-based icons - no need to provide selectedIcon
    public BeautyItem(PFBeautyFilterType type, float progress, String name, String iconBaseName) {
        this.type = type;
        this.progress = progress;
        this.name = name;
        this.iconBaseName = iconBaseName;
        this.supportsStateIcons = true;
        this.selectedIcon = 0; // Will be dynamically determined
    }
    
    // Method to get the appropriate icon based on current state
    public int getCurrentIcon(android.content.Context context) {
        if (!supportsStateIcons || iconBaseName == null) {
            android.util.Log.d("BeautyItem", "Using default icon for " + name + ": supportsStateIcons=" + supportsStateIcons + ", iconBaseName=" + iconBaseName);
            // If no selectedIcon was provided, try to get the _0 state as default
            if (selectedIcon == 0 && iconBaseName != null) {
                String defaultIconName = iconBaseName + "_0";
                int defaultResourceId = context.getResources().getIdentifier(defaultIconName, "mipmap", context.getPackageName());
                if (defaultResourceId != 0) {
                    return defaultResourceId;
                }
                // If still no icon found, use a safe fallback from our icons
                return getSafeFallbackIcon(context);
            }
            return selectedIcon != 0 ? selectedIcon : getSafeFallbackIcon(context);
        }
        
        int iconState = getIconState();
        String iconName = iconBaseName + "_" + iconState;
        
        android.util.Log.d("BeautyItem", "Looking for icon: " + iconName + " for item: " + name + " (progress=" + progress + ", isEditing=" + isEditing + ", state=" + iconState + ")");
        
        int resourceId = context.getResources().getIdentifier(iconName, "mipmap", context.getPackageName());
        
        if (resourceId == 0) {
            // If state icon not found, try to get the state-0 icon as fallback
            String fallbackIconName = iconBaseName + "_0";
            int fallbackResourceId = context.getResources().getIdentifier(fallbackIconName, "mipmap", context.getPackageName());
            if (fallbackResourceId != 0) {
                android.util.Log.w("BeautyItem", "Icon not found: " + iconName + ", using state-0 fallback: " + fallbackIconName);
                return fallbackResourceId;
            } else {
                android.util.Log.w("BeautyItem", "Neither " + iconName + " nor " + fallbackIconName + " found, using safe fallback");
                // Use our safe fallback icon
                return getSafeFallbackIcon(context);
            }
        } else {
            android.util.Log.d("BeautyItem", "Found icon: " + iconName + " with resourceId: " + resourceId);
            return resourceId;
        }
    }
    
    // Helper method to get a safe fallback icon that we know exists
    private int getSafeFallbackIcon(android.content.Context context) {
        // Try several common icons that we know we copied
        String[] fallbackNames = {"meibai_0", "dayan_0", "hongrun_0", "mopi_0"};
        
        for (String fallbackName : fallbackNames) {
            int fallbackId = context.getResources().getIdentifier(fallbackName, "mipmap", context.getPackageName());
            if (fallbackId != 0) {
                android.util.Log.d("BeautyItem", "Using safe fallback icon: " + fallbackName);
                return fallbackId;
            }
        }
        
        // If even our fallbacks fail, use system icon as last resort
        android.util.Log.w("BeautyItem", "All fallback icons failed, using system icon");
        return android.R.drawable.ic_menu_gallery;
    }
    
    // Determine icon state based on value and editing status
    // 0: default value, not editing
    // 1: has value, not editing
    // 2: default value, editing
    // 3: has value, editing
    private int getIconState() {
        boolean hasValue;
        
        if (isTwoWayAdjustment()) {
            // 双向调节：偏离0.5表示有值
            hasValue = Math.abs(progress - 0.5f) > 0.01f;
        } else {
            // 单向调节：偏离0表示有值
            hasValue = progress > 0.0f;
        }
        
        int state;
        if (isEditing) {
            state = hasValue ? 3 : 2;
        } else {
            state = hasValue ? 1 : 0;
        }
        
        android.util.Log.d("BeautyItem", "Icon state for " + name + ": " + state + " (hasValue=" + hasValue + ", progress=" + progress + ", isEditing=" + isEditing + ", isTwoWay=" + isTwoWayAdjustment() + ")");
        return state;
    }
    
    // Method to set editing state
    public void setEditingState(boolean editing) {
        this.isEditing = editing;
    }
    
    // Check if this item is a two-way adjustment type
    public boolean isTwoWayAdjustment() {
        if (type == null) return false;
        
        // 双向调节类型（与BeautyView中的twoWayTypeInts保持一致）
        int intType = type.getIntType();
        return intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_chin.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_nose.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_forehead.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_mouth.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_philtrum.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_long_nose.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_eye_space.getIntType() ||
               intType == com.hapi.pixelfree.PFBeautyFilterType.PFBeautyFilterTypeFace_eye_rotate.getIntType();
    }

    public JSONObject toJSON() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("type", type.getIntType());
        json.put("name", name);
        json.put("selectedIcon", selectedIcon);
        json.put("iconBaseName", iconBaseName);
        json.put("supportsStateIcons", supportsStateIcons);
        if (srcType != null) {
            json.put("srcType", srcType.ordinal());
        } else {
            json.put("progress", progress);
        }
        return json;
    }

    public static PFBeautyFilterType fromInt(int value) {
        for (PFBeautyFilterType type : PFBeautyFilterType.values()) {
            if (type.getIntType() == value) {
                return type;
            }
        }
        return null; // 或者抛出异常
    }

    public static PFBeautyTypeOneKey modelfromInt(int value) {
        for (PFBeautyTypeOneKey type : PFBeautyTypeOneKey.values()) {
            if (type.getIntModel() == value) {
                return type;
            }
        }
        return null; // 或者抛出异常
    }

    public static BeautyItem fromJSON(JSONObject json) throws JSONException {
        PFBeautyFilterType type = BeautyItem.fromInt(json.getInt("type"));
        String name = json.getString("name");
        int selectedIcon = json.getInt("selectedIcon");
        String iconBaseName = json.optString("iconBaseName", null);
        boolean supportsStateIcons = json.optBoolean("supportsStateIcons", false);
        
        if (json.has("progress")) {
            float progress = (float) json.getDouble("progress");
            BeautyItem item = new BeautyItem(type, progress, name, selectedIcon);
            item.iconBaseName = iconBaseName;
            item.supportsStateIcons = supportsStateIcons;
            return item;
        } else if (json.has("srcType")) {
            PFBeautyTypeOneKey srcType = modelfromInt(json.getInt("srcType"));
            return new BeautyItem(type, srcType, name, selectedIcon);
        } else {
            BeautyItem item = new BeautyItem(type, name, selectedIcon);
            item.iconBaseName = iconBaseName;
            item.supportsStateIcons = supportsStateIcons;
            return item;
        }
    }
}
