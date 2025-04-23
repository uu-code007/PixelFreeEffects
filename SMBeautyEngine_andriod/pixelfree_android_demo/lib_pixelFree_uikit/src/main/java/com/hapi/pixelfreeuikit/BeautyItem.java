package com.hapi.pixelfreeuikit;

import com.hapi.pixelfree.PFBeautyFiterType;
import com.hapi.pixelfree.PFBeautyTypeOneKey;
import org.json.JSONException;
import org.json.JSONObject;

public class BeautyItem {
    public PFBeautyFiterType type;
    public float progress = 0;
    public String name;
    public int selectedIcon;
    public PFBeautyTypeOneKey srcType;

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

    public BeautyItem(PFBeautyFiterType type, PFBeautyTypeOneKey srcType, String name, int selectedIcon) {
        this.type = type;
        this.srcType = srcType;
        this.name = name;
        this.selectedIcon = selectedIcon;
    }

    public JSONObject toJSON() throws JSONException {
        JSONObject json = new JSONObject();
        json.put("type", type.getIntType());
        json.put("name", name);
        json.put("selectedIcon", selectedIcon);
        if (srcType != null) {
            json.put("srcType", srcType.ordinal());
        } else {
            json.put("progress", progress);
        }
        return json;
    }

    public static PFBeautyFiterType fromInt(int value) {
        for (PFBeautyFiterType type : PFBeautyFiterType.values()) {
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
        PFBeautyFiterType type = BeautyItem.fromInt(json.getInt("type"));
        String name = json.getString("name");
        int selectedIcon = json.getInt("selectedIcon");
        
        if (json.has("progress")) {
            float progress = (float) json.getDouble("progress");
            return new BeautyItem(type, progress, name, selectedIcon);
        } else if (json.has("srcType")) {
            PFBeautyTypeOneKey srcType = modelfromInt(json.getInt("srcType"));
            return new BeautyItem(type, srcType, name, selectedIcon);
        } else {
            return new BeautyItem(type, name, selectedIcon);
        }
    }

}
