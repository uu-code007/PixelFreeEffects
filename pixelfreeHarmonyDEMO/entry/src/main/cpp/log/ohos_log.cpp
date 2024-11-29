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
#include "ohos_log.h"
#include <stdio.h>
#include <hilog/log.h>

bool OHOS_LOG_ON = true;//log开关、默认关
void __ohos2_log_print(enum PFLogLevel level, const char* tag, const char* fmt, ...)
{
    if (!OHOS_LOG_ON) {
        return;
    }
    char buf[OHOS2_LOG_BUF_SIZE] = { 0 };
    va_list arg;
    va_start(arg, fmt);
    vsnprintf(buf, OHOS2_LOG_BUF_SIZE, fmt, arg);

    switch(level) {
        case IL_INFO:
             OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, tag, "%{public}s", buf);
             break;
        case IL_DEBUG:
             OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, tag, "%{public}s", buf);
             break;
        case IL_WARN:
            OH_LOG_Print(LOG_APP, LOG_WARN, LOG_DOMAIN, tag, "%{public}s", buf);
             break;
        case IL_ERROR:
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, tag, "%{public}s", buf);
            break;
        case IL_FATAL:
            OH_LOG_Print(LOG_APP, LOG_FATAL, LOG_DOMAIN, tag, "%{public}s", buf);
             break;
        default:
             OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, tag, "%{public}s", buf);
             break;
    }
    va_end(arg);
}

void __ohos2_log_print_debug(enum PFLogLevel level, const char* tag, const char* file, int line, const char* fmt, ...)
{
    if (!OHOS_LOG_ON) {
        return;
    }
    char buf[OHOS2_LOG_BUF_SIZE] = { 0 };
    va_list arg;
    va_start(arg, fmt);
    vsnprintf(buf, OHOS2_LOG_BUF_SIZE, fmt, arg);

    switch(level) {
        case IL_INFO:
             OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
        case IL_DEBUG:
             OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
        case IL_WARN:
             OH_LOG_Print(LOG_APP, LOG_WARN, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
        case IL_ERROR:
             OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
        case IL_FATAL:
             OH_LOG_Print(LOG_APP, LOG_FATAL, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
        default:
             OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, tag, "%{public}s:%{public}d %{public}s", file, line, buf);
             break;
    }
    va_end(arg);
}