//
// Created by wlanjie on 2020/7/4.
//

#ifndef TRINITY_APP_PARSE_CONFIG_H
#define TRINITY_APP_PARSE_CONFIG_H

extern "C" {
#include "cJSON.h"
};

#include "extra_effect.h"

namespace trinity {

class ParseConfig {
 public:
    static int ParseEffectConfig(char* config);
    static int ParseExtraEffectConfig(char* config, SubExtraEffect* effect);
};

}

#endif  //TRINITY_APP_PARSE_CONFIG_H
