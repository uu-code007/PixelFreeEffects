//
// Created by wlanjie on 2020/7/4.
//

#include "extra_effect.h"
#include "parse_config.h"
#include "error_code.h"

namespace trinity {

ExtraEffect::ExtraEffect() {

}

ExtraEffect::~ExtraEffect() {
    for (auto sub_extra_effect : sub_extra_effects_) {
        delete sub_extra_effect.second;
    }
    sub_extra_effects_.clear();
}

int ExtraEffect::InitConfig(char *config) {
    LOGI("enter: %s config: %s", __func__, config);
    auto json = cJSON_Parse(config);
    if (nullptr == json) {
        LOGE("parse json error config: %s", config);
        return JSON_CONFIG_ERROR;
    }
    auto type_json = cJSON_GetObjectItem(json, "type");
    auto type = type_json->valuestring;
    if (strcasecmp(type, "background") == 0) {
        auto background = new BackgroundSubExtraEffect();
        int background_type = cJSON_GetObjectItem(json, "backgroundType")->valueint;
        auto start_time = cJSON_GetObjectItem(json, "startTime")->valueint;
        auto end_time = cJSON_GetObjectItem(json, "endTime")->valueint;
        if (background_type == 0) {
            auto red = cJSON_GetObjectItem(json, "red")->valueint;
            auto green = cJSON_GetObjectItem(json, "green")->valueint;
            auto blue = cJSON_GetObjectItem(json, "blue")->valueint;
            auto alpha = cJSON_GetObjectItem(json, "alpha")->valueint;
            background->SetColor(red, green, blue, alpha);
        } else if (background_type == 1) {
            auto path = cJSON_GetObjectItem(json, "path")->valuestring;
            background->SetImagePath(path);
        } else if (background_type == 2) {
            auto blur = cJSON_GetObjectItem(json, "blur")->valueint;
            background->SetBlur(blur, start_time, end_time);
        }
        auto key = std::string(type);
        sub_extra_effects_.insert(std::pair<char*, SubExtraEffect*>(const_cast<char*>(key.c_str()), background));
    } else if (strcasecmp(type, "rotate") == 0) {
        auto rotate_effect = new RotateSubExtraEffect();
        auto rotate = cJSON_GetObjectItem(json, "rotate")->valueint;
        rotate_effect->SetRotate(rotate);
        sub_extra_effects_.insert(std::pair<char*, SubExtraEffect*>(type, rotate_effect));
    }
    cJSON_Delete(json);
    LOGI("leave: %s", __func__);
    return 0;
}

void ExtraEffect::UpdateConfig(char *config) {
    LOGI("enter: %s config: %s size: %d", __func__, config, sub_extra_effects_.size());
    for (auto& extra_sub_effect : sub_extra_effects_) {
        LOGE("key: %s", extra_sub_effect.first);
        extra_sub_effect.second->UpdateExtraEffectConfig(config);
    }
    LOGI("leave: %s", __func__);
}

int ExtraEffect::OnDrawFrame(GLuint texture_id, int surface_width, int surface_height,
                             int frame_width, int frame_height, uint64_t current_time) {
    if (sub_extra_effects_.empty()) {
        return -1;
    }
    int origin_texture_id = texture_id;
    int texture = texture_id;
    for (auto& extra_sub_effect : sub_extra_effects_) {
        texture = extra_sub_effect.second->OnDrawFrame(origin_texture_id,
                texture, surface_width, surface_height, frame_width, frame_height, current_time);
    }
    return texture;
}

}