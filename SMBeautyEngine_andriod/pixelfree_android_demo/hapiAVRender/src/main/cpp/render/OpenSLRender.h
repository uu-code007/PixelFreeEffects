//
// Created by 1 on 2022/3/28.
//

#ifndef HAPIPLAY_OPENSLRENDER_H
#define HAPIPLAY_OPENSLRENDER_H


#include <cstdint>
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <queue>
#include <string>
#include <thread>
#include "AudioFrame.h"
#include <LogUtil.h>
#include <unistd.h>
extern "C"
{
#include <libswresample/swresample.h>
}

#define MAX_QUEUE_BUFFER_SIZE 3

class OpenSLRender {
public:
    OpenSLRender();
    ~OpenSLRender();
    void init();
    void ClearAudioCache();
    void RenderAudioFrame(AudioFrame *inputFrame);

private:
    int GetAudioFrameQueueSize();

    void StartRender();

    void HandleAudioFrameQueue();

    static void CreateSLWaitingThread(OpenSLRender *openSlRender);

    static void AudioPlayerCallback(SLAndroidSimpleBufferQueueItf bufferQueue, void *context);

    SLObjectItf m_EngineObj = nullptr;
    SLEngineItf m_EngineEngine = nullptr;
    SLObjectItf m_OutputMixObj = nullptr;
    SLObjectItf m_AudioPlayerObj = nullptr;
    SLPlayItf m_AudioPlayerPlay = nullptr;
    SLVolumeItf m_AudioPlayerVolume = nullptr;
    SLAndroidSimpleBufferQueueItf m_BufferQueue;
    std::queue<AudioFrame *> m_AudioFrameQueue;
    std::thread *m_thread = nullptr;
    std::mutex m_Mutex;
    std::condition_variable m_Cond;
    volatile bool m_Exit = false;
    SwrContext *m_pSwrCtx = nullptr;
};

#endif //HAPIPLAY_OPENSLRENDER_H
