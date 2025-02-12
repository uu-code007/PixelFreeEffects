//
// Created by wlanjie on 2020/7/4.
//

#include "parse_config.h"

#include <string>
#include "error_code.h"

namespace trinity {

int ParseConfig::ParseEffectConfig(char *config) {
    return 0;
}

int ParseConfig::ParseExtraEffectConfig(char* config, SubExtraEffect* effect) {
    auto json = cJSON_Parse(config);
    if (nullptr == json) {
        LOGE("parse json error config: %s", config);
        return JSON_CONFIG_ERROR;
    }
    auto type_json = cJSON_GetObjectItem(json, "type");
    auto type = type_json->valuestring;
    if (strcasecmp(type, "backgroundColor") == 0) {
        auto red = cJSON_GetObjectItem(json, "red")->valueint;
        auto green = cJSON_GetObjectItem(json, "green")->valueint;
        auto blue = cJSON_GetObjectItem(json, "blue")->valueint;
        auto alpha = cJSON_GetObjectItem(json, "alpha")->valueint;
    }
    cJSON_Delete(json);
    return 0;
}

}
