/*
 * Copyright (C) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <hilog/log.h>

#ifndef mp4parser_ohos_log_H
#define mp4parser_ohos_log_H
#define LOG_TAG "pixelfree"
enum PFLogLevel {
    IL_INFO,
    IL_DEBUG,
    IL_WARN,
    IL_ERROR,
    IL_FATAL
};

#define LOGD(...) __ohos2_log_print(IL_DEBUG ,LOG_TAG, __VA_ARGS__)
#define LOGI(...) __ohos2_log_print(IL_INFO ,LOG_TAG, __VA_ARGS__)
#define LOGW(...) __ohos2_log_print(IL_WARN ,LOG_TAG, __VA_ARGS__)
#define LOGE(...) __ohos2_log_print(IL_ERROR ,LOG_TAG,__VA_ARGS__)
#define LOGF(...) __ohos2_log_print(IL_FATAL ,LOG_TAG,__VA_ARGS__)

#define OHOS2_LOG_BUF_SIZE (4096)
#ifdef __cplusplus
extern "C" {
#endif
extern bool OHOS_LOG_ON;//log开关、默认关
void __ohos2_log_print(enum PFLogLevel level, const char* tag, const char* fmt, ...);
void __ohos2_log_print_debug(enum PFLogLevel level, const char* tag,const char* file,int line, const char* fmt, ...);
#ifdef __cplusplus
}
#endif
#endif