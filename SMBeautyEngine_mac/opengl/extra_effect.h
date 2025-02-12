//
// Created by wlanjie on 2020/7/4.
//

#ifndef TRINITY_APP_EXTRA_EFFECT_H
#define TRINITY_APP_EXTRA_EFFECT_H

#include <list>
#include <map>
#include "background.h"
#include "trinity.h"
#include "gl.h"

extern "C" {
#include "cJSON.h"
};

namespace trinity {

class SubExtraEffect {
public:
    SubExtraEffect() {}
    virtual ~SubExtraEffect() {}

    virtual int InitExtraEffectConfig(char* config) {
        return 0;
    }

    virtual void UpdateExtraEffectConfig(char* config) {
        LOGE("%s ", __func__);
        auto json = cJSON_Parse(config);
        if (nullptr == json) {
            LOGE("parse json error config: %s", config);
            return;
        }
        auto type_json = cJSON_GetObjectItem(json, "type");
        auto type = type_json->valuestring;
        UpdateSubExtraEffectConfig(type, json);
        cJSON_Delete(json);
    }

    virtual void UpdateSubExtraEffectConfig(char* type, cJSON* json) {}

    virtual void DeleteExtraEffectConfig() {}

    virtual int OnDrawFrame(int origin_texture_id, int texture_id,
                            int surface_width, int surface_height,
                            int width, int height, uint64_t current_time) {
        return texture_id;
    }
};

class RotateSubExtraEffect : public SubExtraEffect {
 public:
    RotateSubExtraEffect()
        : rotate_frame_buffer_(nullptr)
        , rotate_(0)
        , width_(0)
        , height_(0) {
        rotate_frame_buffer_ = new FrameBuffer();
        rotate_vertex_coordinate_ = new float[8];
    }
    ~RotateSubExtraEffect() {
        SAFE_DELETE(rotate_frame_buffer_);
        SAFE_DELETE_ARRAY(rotate_vertex_coordinate_);
    }

    void UpdateSubExtraEffectConfig(char* type, cJSON* json) override {
        LOGE("Update rotate config");
        if (strcasecmp(type, "rotate") == 0) {
            auto rotate = cJSON_GetObjectItem(json, "rotate")->valueint;
            SetRotate(rotate);
        }
    }

    void SetRotate(int rotate) {
        rotate_ = rotate;
    }

    virtual int OnDrawFrame(int origin_texture_id, int texture_id,
                            int surface_width, int surface_height,
                            int width, int height, uint64_t current_time) override {

        LOGE("rotate: %d", rotate_);
        float* texture_coordinate;
        if (rotate_ == 0) {
            texture_coordinate = TEXTURE_COORDINATE_NO_ROTATION;
        } else if (rotate_ == 90) {
            texture_coordinate = TEXTURE_COORDINATE_ROTATED_90;
        } else if (rotate_ == 180) {
            texture_coordinate = TEXTURE_COORDINATE_ROTATED_180;
        } else {
            texture_coordinate = TEXTURE_COORDINATE_ROTATED_270;
        }
        int rotate_width = width;
        int rotate_height = height;
        if (rotate_ == 90 || rotate_ == 270) {
            rotate_width = height;
            rotate_height = width;
        }
        CalculateFrameVertexCoordinate(rotate_width, rotate_height, surface_width, surface_height,
                                       FIT, rotate_vertex_coordinate_);
        return rotate_frame_buffer_->OnDrawFrame(texture_id, width, height,
                     rotate_vertex_coordinate_, texture_coordinate, current_time);
    }
 private:
    FrameBuffer* rotate_frame_buffer_;
    float* rotate_vertex_coordinate_;
    int rotate_;
    int width_;
    int height_;
};

class BackgroundSubExtraEffect : public SubExtraEffect {
public:
    BackgroundSubExtraEffect()
        : background_(nullptr)
        , vertex_coordinate_(nullptr)
        , surface_width_(0)
        , surface_height_(0)
        , image_width_(0)
        , image_height_(0)
        , source_width_(0)
        , source_height_(0) {
        vertex_coordinate_ = new float[8];
    }

    ~BackgroundSubExtraEffect() {
        SAFE_DELETE(background_);
        SAFE_DELETE_ARRAY(vertex_coordinate_);
    }

    virtual int InitExtraEffectConfig(char* config) override {
        LOGE("%s config: %s", __func__, config);
        return 0;
    }

    void UpdateSubExtraEffectConfig(char* type, cJSON* json) override {
        LOGE("%s", __func__);
        if (strcasecmp(type, "background") == 0) {
            auto backgroundType = cJSON_GetObjectItem(json, "backgroundType")->valueint;
            auto start_time = cJSON_GetObjectItem(json, "startTime")->valueint;
            auto end_time = cJSON_GetObjectItem(json, "endTime")->valueint;
            if (backgroundType == 0) {
                auto red = cJSON_GetObjectItem(json, "red")->valueint;
                auto green = cJSON_GetObjectItem(json, "green")->valueint;
                auto blue = cJSON_GetObjectItem(json, "blue")->valueint;
                auto alpha = cJSON_GetObjectItem(json, "alpha")->valueint;
                SetColor(red, green, blue, alpha);
            } else if (backgroundType == 1) {
                auto path = cJSON_GetObjectItem(json, "path")->valuestring;
                SetImagePath(path);
            } else if (backgroundType == 2) {
                auto blur = cJSON_GetObjectItem(json, "blur")->valueint;
                SetBlur(blur, start_time, end_time);
            }
        }
    }

    virtual void DeleteExtraEffectConfig() override {
        LOGE("%s", __func__);
    }

    void InitBackground() {
        if (nullptr == background_) {
            background_ = new Background();
        }
    }

    void SetImagePath(char* path) {
        int width;
        int height;
        int channels;
        unsigned char *data = stbi_load(path, &width, &height, &channels, 0);
        if (width == 0 || height == 0) {
            return;
        }
        image_width_ = width;
        image_height_ = height;
        InitBackground();
        background_->SetImage(data, width, height);
        stbi_image_free(data);
    }

    void SetColor(int red, int green, int blue, int alpha) {
        InitBackground();
        background_->SetColor(red, green, blue, alpha);
        image_width_ = 0;
        image_height_ = 0;
    }

    void SetBlur(int blur, int start_time, int end_time) {
        InitBackground();
        background_->SetBlur(start_time, end_time, blur);
    }

    virtual int OnDrawFrame(int origin_texture_id, int texture_id,
                            int surface_width, int surface_height,
                            int width, int height, uint64_t current_time) override {
        if (nullptr == background_) {
            return texture_id;
        }
        LOGE("background draw");
        int frame_width = image_width_ == 0 ? width : image_width_;
        int frame_height = image_height_ == 0 ? height : image_height_;
        if (surface_width != surface_width_ || surface_height != surface_height_
            || frame_width != source_width_ || frame_height != source_height_) {
            surface_width_ = surface_width;
            surface_height_ = surface_height;
            source_width_ = frame_width;
            source_height_ = frame_height;
            CalculateFrameVertexCoordinate(width, height, surface_width, surface_height, FIT, vertex_coordinate_);
        }
        return background_->OnDrawFrame(texture_id, surface_width, surface_height, width, height, vertex_coordinate_);
    }

 private:
    Background* background_;
    float* vertex_coordinate_;
    int surface_width_;
    int surface_height_;
    int source_width_;
    int source_height_;
    int image_width_;
    int image_height_;
};

class ExtraEffect {
 public:
    ExtraEffect();
    virtual ~ExtraEffect();
    int InitConfig(char* config);
    void UpdateConfig(char* config);
    int OnDrawFrame(GLuint texture_id, int surface_width, int surface_height,
            int frame_width, int frame_height, uint64_t current_time);

 private:
    std::map<char*, SubExtraEffect*> sub_extra_effects_;
};

}

#endif  // TRINITY_APP_EXTRA_EFFECT_H
