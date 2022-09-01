//
// Created by 1 on 2022/3/28.
//

#include "OpenSLRender.h"


OpenSLRender::OpenSLRender() {
}

void OpenSLRender::init() {
    LOGCATE("OpenSLRender::Init");

    auto CreateEngine = [this]() -> SLresult {
        SLresult result = SL_RESULT_SUCCESS;
        do {
            result = slCreateEngine(&m_EngineObj, 0, nullptr, 0, nullptr, nullptr);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateEngine slCreateEngine fail. result=%d", result);
                break;
            }

            result = (*m_EngineObj)->Realize(m_EngineObj, SL_BOOLEAN_FALSE);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateEngine Realize fail. result=%d", result);
                break;
            }

            result = (*m_EngineObj)->GetInterface(m_EngineObj, SL_IID_ENGINE, &m_EngineEngine);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateEngine GetInterface fail. result=%d", result);
                break;
            }

        } while (false);
        return result;
    };

    auto CreateOutputMixer = [this]() -> SLresult {
        SLresult result = SL_RESULT_SUCCESS;
        do {
            const SLInterfaceID mids[1] = {SL_IID_ENVIRONMENTALREVERB};
            const SLboolean mreq[1] = {SL_BOOLEAN_FALSE};

            result = (*m_EngineEngine)->CreateOutputMix(m_EngineEngine, &m_OutputMixObj, 1, mids,
                                                        mreq);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateOutputMixer CreateOutputMix fail. result=%d", result);
                break;
            }

            result = (*m_OutputMixObj)->Realize(m_OutputMixObj, SL_BOOLEAN_FALSE);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateOutputMixer CreateOutputMix fail. result=%d", result);
                break;
            }
        } while (false);

        return result;
    };

    auto CreateAudioPlayer = [this]() -> SLresult {
        SLDataLocator_AndroidSimpleBufferQueue android_queue = {
                SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE,
                2};
        SLDataFormat_PCM pcm = {
                SL_DATAFORMAT_PCM,//format type
                (SLuint32) 2,//channel count
                SL_SAMPLINGRATE_44_1,//44100hz
                SL_PCMSAMPLEFORMAT_FIXED_16,// bits per sample
                SL_PCMSAMPLEFORMAT_FIXED_16,// container size
                SL_SPEAKER_FRONT_LEFT | SL_SPEAKER_FRONT_RIGHT,// channel mask
                SL_BYTEORDER_LITTLEENDIAN // endianness
        };
        SLDataSource slDataSource = {&android_queue, &pcm};
        SLDataLocator_OutputMix outputMix = {SL_DATALOCATOR_OUTPUTMIX, m_OutputMixObj};
        SLDataSink slDataSink = {&outputMix, nullptr};
        const SLInterfaceID ids[3] = {SL_IID_BUFFERQUEUE, SL_IID_EFFECTSEND, SL_IID_VOLUME};
        const SLboolean req[3] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};
        SLresult result;

        do {
            result = (*m_EngineEngine)->CreateAudioPlayer(m_EngineEngine, &m_AudioPlayerObj,
                                                          &slDataSource, &slDataSink, 3, ids, req);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer CreateAudioPlayer fail. result=%d",
                        result);
                break;
            }

            result = (*m_AudioPlayerObj)->Realize(m_AudioPlayerObj, SL_BOOLEAN_FALSE);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer Realize fail. result=%d", result);
                break;
            }

            result = (*m_AudioPlayerObj)->GetInterface(m_AudioPlayerObj, SL_IID_PLAY,
                                                       &m_AudioPlayerPlay);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer GetInterface fail. result=%d", result);
                break;
            }

            result = (*m_AudioPlayerObj)->GetInterface(m_AudioPlayerObj, SL_IID_BUFFERQUEUE,
                                                       &m_BufferQueue);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer GetInterface fail. result=%d", result);
                break;
            }
            result = (*m_BufferQueue)->RegisterCallback(m_BufferQueue, AudioPlayerCallback, this);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer RegisterCallback fail. result=%d", result);
                break;
            }
            result = (*m_AudioPlayerObj)->GetInterface(m_AudioPlayerObj, SL_IID_VOLUME,
                                                       &m_AudioPlayerVolume);
            if (result != SL_RESULT_SUCCESS) {
                LOGCATE("OpenSLRender::CreateAudioPlayer GetInterface fail. result=%d", result);
                break;
            }
        } while (false);
        return result;
    };

    int result = -1;
    do {
        result = CreateEngine();
        if (result != SL_RESULT_SUCCESS) {
            LOGCATE("OpenSLRender::Init CreateEngine fail. result=%d", result);
            break;
        }
        result = CreateOutputMixer();
        if (result != SL_RESULT_SUCCESS) {
            LOGCATE("OpenSLRender::Init CreateOutputMixer fail. result=%d", result);
            break;
        }
        result = CreateAudioPlayer();
        if (result != SL_RESULT_SUCCESS) {
            LOGCATE("OpenSLRender::Init CreateAudioPlayer fail. result=%d", result);
            break;
        }
        m_thread = new std::thread(CreateSLWaitingThread, this);

    } while (false);

    if (result != SL_RESULT_SUCCESS) {
        LOGCATE("OpenSLRender::Init fail. result=%d", result);
    }
}

//todo 重采样
void OpenSLRender::RenderAudioFrame(AudioFrame *inputFrame) {
    if (m_AudioPlayerPlay) {
        //temp resolution, when queue size is too big.
        if (GetAudioFrameQueueSize() >= MAX_QUEUE_BUFFER_SIZE || m_Exit) {
            return;
        }
        std::unique_lock<std::mutex> lock(m_Mutex);
        auto *outPutFrame = new AudioFrame();
        int outAudioSampleRate = 44100;
        AVSampleFormat out_sample_fmt = AV_SAMPLE_FMT_S16;
        int outAudioChannelLayout = AV_CH_LAYOUT_STEREO;
        outPutFrame->audioSampleRate = outAudioSampleRate;
        outPutFrame->out_sample_fmt = out_sample_fmt;
        outPutFrame->audioChannelLayout = outAudioChannelLayout;

        if (inputFrame->audioSampleRate != outPutFrame->audioSampleRate
            || inputFrame->audioChannelLayout != outPutFrame->audioChannelLayout
            || inputFrame->out_sample_fmt != outPutFrame->out_sample_fmt
                ) {
            //只适配byte 8位 每个通道有多少数据
            int input_nb_samples = inputFrame->dataSize / inputFrame->getChannelCount() /
                                   (av_get_bytes_per_sample(inputFrame->out_sample_fmt));

            if (m_pSwrCtx == nullptr) {
                m_pSwrCtx = swr_alloc();
                //todo 重新初始化
                m_pSwrCtx = swr_alloc_set_opts(m_pSwrCtx,
                                               outPutFrame->audioChannelLayout,
                                               outPutFrame->out_sample_fmt,
                                               outPutFrame->audioSampleRate,

                                               inputFrame->audioChannelLayout,
                                               inputFrame->out_sample_fmt,
                                               inputFrame->audioSampleRate,

                                               0,
                                               0);//输入格式

                swr_init(m_pSwrCtx);
                //  lastInputAudioFrameKey = frameKey;
            }

            int64_t delay = swr_get_delay(m_pSwrCtx, inputFrame->audioSampleRate);
            int64_t out_count = av_rescale_rnd(
                    input_nb_samples + delay, //本次要处理的数据个数
                    outPutFrame->audioSampleRate,
                    inputFrame->audioSampleRate,
                    AV_ROUND_UP);

            av_samples_alloc(&(outPutFrame->data),
                             NULL,
                             outPutFrame->getChannelCount(),
                             out_count,
                             outPutFrame->out_sample_fmt,
                             0);
            int out_samples = swr_convert(m_pSwrCtx, &(outPutFrame->data), out_count,
                                          (const uint8_t **) &(inputFrame->data),
                                          input_nb_samples);
            outPutFrame->dataSize =
                    out_samples * (av_get_bytes_per_sample(outPutFrame->out_sample_fmt)) *
                    outPutFrame->getChannelCount();
        } else {
            outPutFrame->copyNewObjFrom(inputFrame);
        }
        m_AudioFrameQueue.push(outPutFrame);
        m_Cond.notify_all();
        lock.unlock();
    }
}

OpenSLRender::~OpenSLRender() {
    LOGCATE("OpenSLRender::UnInit");

    if (m_AudioPlayerPlay) {
        (*m_AudioPlayerPlay)->SetPlayState(m_AudioPlayerPlay, SL_PLAYSTATE_STOPPED);
        m_AudioPlayerPlay = nullptr;
    }

    std::unique_lock<std::mutex> lock(m_Mutex);
    m_Exit = true;
    m_Cond.notify_all();
    lock.unlock();

    if (m_AudioPlayerObj) {
        (*m_AudioPlayerObj)->Destroy(m_AudioPlayerObj);
        m_AudioPlayerObj = nullptr;
        m_BufferQueue = nullptr;
    }

    if (m_OutputMixObj) {
        (*m_OutputMixObj)->Destroy(m_OutputMixObj);
        m_OutputMixObj = nullptr;
    }

    if (m_EngineObj) {
        (*m_EngineObj)->Destroy(m_EngineObj);
        m_EngineObj = nullptr;
        m_EngineEngine = nullptr;
    }

    lock.lock();
    for (int i = 0; i < m_AudioFrameQueue.size(); ++i) {
        AudioFrame *audioFrame = m_AudioFrameQueue.front();
        m_AudioFrameQueue.pop();
        delete audioFrame;
    }
    lock.unlock();

    if (m_thread != nullptr) {
        m_thread->join();
        delete m_thread;
        m_thread = nullptr;
    }
    if (m_pSwrCtx) {
        swr_free(&m_pSwrCtx);
    }
    m_pSwrCtx = nullptr;
    //  AudioGLRender::ReleaseInstance();
}


void OpenSLRender::StartRender() {
    while (GetAudioFrameQueueSize() < MAX_QUEUE_BUFFER_SIZE && !m_Exit) {
        std::unique_lock<std::mutex> lock(m_Mutex);
        m_Cond.wait_for(lock, std::chrono::milliseconds(10));
        //m_Cond.wait(lock);
        lock.unlock();
    }
    (*m_AudioPlayerPlay)->SetPlayState(m_AudioPlayerPlay, SL_PLAYSTATE_PLAYING);
    AudioPlayerCallback(m_BufferQueue, this);
}

void OpenSLRender::HandleAudioFrameQueue() {
    LOGCATE("OpenSLRender::HandleAudioFrameQueue QueueSize=%lu", m_AudioFrameQueue.size());
    if (m_AudioPlayerPlay == nullptr) return;

    while (GetAudioFrameQueueSize() < MAX_QUEUE_BUFFER_SIZE && !m_Exit) {
        std::unique_lock<std::mutex> lock(m_Mutex);
        m_Cond.wait_for(lock, std::chrono::milliseconds(10));
    }

    std::unique_lock<std::mutex> lock(m_Mutex);
    AudioFrame *audioFrame = m_AudioFrameQueue.front();
    if (nullptr != audioFrame && m_AudioPlayerPlay) {
        SLresult result = (*m_BufferQueue)->Enqueue(m_BufferQueue, audioFrame->data,
                                                    (SLuint32) audioFrame->dataSize);
        if (result == SL_RESULT_SUCCESS) {
            LOGCATE("OpenSLRender::HandleAudioFrameQueue  SL_RESULT_SUCCESS  QueueSize=%lu",
                    m_AudioFrameQueue.size());
        } else {
            LOGCATE("OpenSLRender::HandleAudioFrameQueue  fail  QueueSize=%lu",
                    m_AudioFrameQueue.size());
        }
        m_AudioFrameQueue.pop();
        delete audioFrame;
    }
    lock.unlock();
}

void OpenSLRender::CreateSLWaitingThread(OpenSLRender *openSlRender) {
    openSlRender->StartRender();
}

void OpenSLRender::AudioPlayerCallback(SLAndroidSimpleBufferQueueItf bufferQueue, void *context) {
    auto *openSlRender = static_cast<OpenSLRender *>(context);
    openSlRender->HandleAudioFrameQueue();
}

int OpenSLRender::GetAudioFrameQueueSize() {
    std::unique_lock<std::mutex> lock(m_Mutex);
    return m_AudioFrameQueue.size();
}

void OpenSLRender::ClearAudioCache() {
    std::unique_lock<std::mutex> lock(m_Mutex);
    for (int i = 0; i < m_AudioFrameQueue.size(); ++i) {
        AudioFrame *audioFrame = m_AudioFrameQueue.front();
        m_AudioFrameQueue.pop();
        delete audioFrame;
    }
}
