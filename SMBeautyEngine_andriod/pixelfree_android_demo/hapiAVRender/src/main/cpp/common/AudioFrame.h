//
// Created by 1 on 2022/3/28.
//

#ifndef HAPIPLAY_AUDIOFRAME_H
#define HAPIPLAY_AUDIOFRAME_H

#include <cstdint>
#include <cstdlib>

extern "C"
{
#include <libavutil/samplefmt.h>
#include <libavutil/channel_layout.h>
}

class AudioFrame {
public:
    AudioFrame() = default;

    ~AudioFrame() {
        if (this->data)
            free(this->data);
        this->data = nullptr;
    }

    AVSampleFormat out_sample_fmt;
    int64_t audioChannelLayout;
    int audioSampleRate;

    uint8_t *data = nullptr;
    int dataSize = 0;

    int getChannelCount() {
        // return 0;
        return av_get_channel_layout_nb_channels(audioChannelLayout);
    }

    int getSampleDeep() {
        int sampleDeep = 0;
        switch (out_sample_fmt) {
            case AV_SAMPLE_FMT_NONE :
                sampleDeep = 0;
                break;
            case AV_SAMPLE_FMT_U8:
                sampleDeep = 8;
                break;          ///< unsigned 8 bits
            case AV_SAMPLE_FMT_S16:
                sampleDeep = 16;
                break;       ///< signed 16 bits
            case AV_SAMPLE_FMT_S32:
                sampleDeep = 32;
                break;         ///< signed 32 bits
            case AV_SAMPLE_FMT_FLT:
                sampleDeep = 0;
                break;         ///< float
            case AV_SAMPLE_FMT_DBL:
                sampleDeep = 0;
                break;         ///< double

            case AV_SAMPLE_FMT_U8P:
                sampleDeep = 8;
                break;        ///< unsigned 8 bits, planar
            case AV_SAMPLE_FMT_S16P:
                sampleDeep = 16;
                break;        ///< signed 16 bits, planar
            case AV_SAMPLE_FMT_S32P:
                sampleDeep = 32;
                break;        ///< signed 32 bits, planar
            case AV_SAMPLE_FMT_FLTP:
                sampleDeep = 0;
                break;       ///< float, planar
            case AV_SAMPLE_FMT_DBLP:
                sampleDeep = 0;
                break;        ///< double, planar
            case AV_SAMPLE_FMT_S64:
                sampleDeep = 64;
                break;         ///< signed 64 bits
            case AV_SAMPLE_FMT_S64P:
                sampleDeep = 64;
                break;       ///< signed 64 bits, planar

            case AV_SAMPLE_FMT_NB  :
                sampleDeep = 0;
                break;         ///< Number of sample formats. DO NOT USE if linking dynamically
        }
        return sampleDeep;
    }


    void copyNewObjFrom(AudioFrame *target) {
        this->audioChannelLayout = target->audioChannelLayout;
        this->out_sample_fmt = target->out_sample_fmt;
        this->audioSampleRate = target->audioSampleRate;

        this->dataSize = target->dataSize;
        this->data = static_cast<uint8_t *>(malloc(target->dataSize));
        memcpy(this->data, target->data, dataSize);
    }
};


#endif //HAPIPLAY_AUDIOFRAME_H
