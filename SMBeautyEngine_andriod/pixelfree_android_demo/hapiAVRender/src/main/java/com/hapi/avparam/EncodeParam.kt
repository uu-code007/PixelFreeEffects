package com.hapi.avparam

import android.media.AudioFormat
import android.media.AudioFormat.*


class VideoEncodeParam(
    val frameWidth: Int,
    val frameHeight: Int,
    val videoBitRate: Int,
    val fps: Int,
    var minVideoBitRate: Int = -1,
    var maxVideoBitRate: Int = -1
) {
    init {
        if (maxVideoBitRate == -1) {
            maxVideoBitRate = videoBitRate;
        }
        if (minVideoBitRate == -1) {
            minVideoBitRate = videoBitRate
        }
    }
}

class AudioEncodeParam(
    val sampleRateInHz: Int,
    val channelConfig: ChannelConfig,
    val audioFormat: SampleFormat,
    val audioBitrate: Int,
    var minAudioBitRate: Int = -1,
    var maxAudioBitRate: Int = -1
) {
    init {
        if (maxAudioBitRate == -1) {
            maxAudioBitRate = audioBitrate;
        }
        if (minAudioBitRate == -1) {
            minAudioBitRate = audioBitrate
        }
    }
}

class EncodeParam(
    val videoEncodeParam: VideoEncodeParam? = null,
    val audioEncodeParam: AudioEncodeParam? = null
)

class AudioFrame(
    val sampleRateInHz: Int, val channelConfig: ChannelConfig, val audioFormat: SampleFormat,
    val data: ByteArray
)

class VideoFrame(
    val width: Int,
    val height: Int,
    val format: ImgFmt,
    val data: ByteArray,
    val rotationDegrees: Int = 0,
    val pixelStride: Int = 0,
    val rowPadding: Int = 0
) {
    var rowStride = 0
    var textureID = -1000
}

enum class ImgFmt(val fmt: Int) {
    IMAGE_FORMAT_RGBA(0x01),
    IMAGE_FORMAT_NV21(0x02),
    IMAGE_FORMAT_NV12(0x03),
    IMAGE_FORMAT_I420(0x04)
}

enum class ChannelConfig(val androidChannel: Int, val FFmpegChannel: Int, val count: Int) {
    LEFT(CHANNEL_IN_LEFT, AV_CH_FRONT_LEFT, 1),
    MONO(CHANNEL_IN_MONO, AV_CH_LAYOUT_MONO, 1),
    RIGHT(CHANNEL_IN_RIGHT, AV_CH_FRONT_RIGHT, 1),
    STEREO(CHANNEL_IN_STEREO, AV_CH_LAYOUT_STEREO, 2)
}

enum class SampleFormat(val androidFMT: Int, val ffmpegFMT: Int, val deep: Int) {
    ENCODING_PCM_8BIT(AudioFormat.ENCODING_PCM_8BIT, AV_SAMPLE_FMT_U8, 8),
    ENCODING_PCM_FLOAT(AudioFormat.ENCODING_PCM_FLOAT, AV_SAMPLE_FMT_FLT, 64),
    ENCODING_PCM_16BIT(AudioFormat.ENCODING_PCM_16BIT, AV_SAMPLE_FMT_S16, 16),
    ENCODING_PCM_32BIT(AudioFormat.ENCODING_PCM_32BIT, AV_SAMPLE_FMT_S32, 32)
}

val AV_SAMPLE_FMT_NONE = (-1)
val AV_SAMPLE_FMT_U8 = (0)  ///< unsigned 8 bits
val AV_SAMPLE_FMT_S16 = (1)   ///< signed 16 bits
val AV_SAMPLE_FMT_S32 = (2)   ///< signed 32 bits
val AV_SAMPLE_FMT_FLT = (3)   ///< float
val AV_SAMPLE_FMT_DBL = (4)   ///< double

val AV_SAMPLE_FMT_U8P = (6)   ///< unsigned 8 bits, planar
val AV_SAMPLE_FMT_S16P = (7)  ///< signed 16 bits, planar
val AV_SAMPLE_FMT_S32P = (8)  ///< signed 32 bits, planar
val AV_SAMPLE_FMT_FLTP = (9)  ///< float, planar
val AV_SAMPLE_FMT_DBLP = (10)  ///< double, planar
val AV_SAMPLE_FMT_S64 = (11)   ///< signed 64 bits
val AV_SAMPLE_FMT_S64P = (12)  ///< signed 64 bits, planar

val AV_SAMPLE_FMT_NB = (13)        ///< Number of sample formats. DO NOT USE if linking dynamically


val AV_CH_FRONT_LEFT = 0x00000001
val AV_CH_FRONT_RIGHT = 0x00000002
val AV_CH_FRONT_CENTER = 0x00000004
val AV_CH_LOW_FREQUENCY = 0x00000008
val AV_CH_BACK_LEFT = 0x00000010
val AV_CH_BACK_RIGHT = 0x00000020
val AV_CH_FRONT_LEFT_OF_CENTER = 0x00000040
val AV_CH_FRONT_RIGHT_OF_CENTER = 0x00000080
val AV_CH_BACK_CENTER = 0x00000100
val AV_CH_SIDE_LEFT = 0x00000200
val AV_CH_SIDE_RIGHT = 0x00000400
val AV_CH_TOP_CENTER = 0x00000800
val AV_CH_TOP_FRONT_LEFT = 0x00001000
val AV_CH_TOP_FRONT_CENTER = 0x00002000
val AV_CH_TOP_FRONT_RIGHT = 0x00004000
val AV_CH_TOP_BACK_LEFT = 0x00008000
val AV_CH_TOP_BACK_CENTER = 0x00010000
val AV_CH_TOP_BACK_RIGHT = 0x00020000
val AV_CH_STEREO_LEFT = 0x20000000  ///< Stereo downmix.
val AV_CH_STEREO_RIGHT = 0x40000000  ///< See AV_CH_STEREO_LEFT.


/**
 * @}
 * @defgroup channel_mask_c Audio channel layouts
 * @{
 * */
val AV_CH_LAYOUT_MONO = (AV_CH_FRONT_CENTER)
val AV_CH_LAYOUT_STEREO = (AV_CH_FRONT_LEFT or AV_CH_FRONT_RIGHT)
val AV_CH_LAYOUT_2POINT1 = (AV_CH_LAYOUT_STEREO or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_2_1 = (AV_CH_LAYOUT_STEREO or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_SURROUND = (AV_CH_LAYOUT_STEREO or AV_CH_FRONT_CENTER)
val AV_CH_LAYOUT_3POINT1 = (AV_CH_LAYOUT_SURROUND or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_4POINT0 = (AV_CH_LAYOUT_SURROUND or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_4POINT1 = (AV_CH_LAYOUT_4POINT0 or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_2_2 = (AV_CH_LAYOUT_STEREO or AV_CH_SIDE_LEFT or AV_CH_SIDE_RIGHT)
val AV_CH_LAYOUT_QUAD = (AV_CH_LAYOUT_STEREO or AV_CH_BACK_LEFT or AV_CH_BACK_RIGHT)
val AV_CH_LAYOUT_5POINT0 = (AV_CH_LAYOUT_SURROUND or AV_CH_SIDE_LEFT or AV_CH_SIDE_RIGHT)
val AV_CH_LAYOUT_5POINT1 = (AV_CH_LAYOUT_5POINT0 or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_5POINT0_BACK = (AV_CH_LAYOUT_SURROUND or AV_CH_BACK_LEFT or AV_CH_BACK_RIGHT)
val AV_CH_LAYOUT_5POINT1_BACK = (AV_CH_LAYOUT_5POINT0_BACK or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_6POINT0 = (AV_CH_LAYOUT_5POINT0 or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_6POINT0_FRONT =
    (AV_CH_LAYOUT_2_2 or AV_CH_FRONT_LEFT_OF_CENTER or AV_CH_FRONT_RIGHT_OF_CENTER)
val AV_CH_LAYOUT_HEXAGONAL = (AV_CH_LAYOUT_5POINT0_BACK or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_6POINT1 = (AV_CH_LAYOUT_5POINT1 or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_6POINT1_BACK = (AV_CH_LAYOUT_5POINT1_BACK or AV_CH_BACK_CENTER)
val AV_CH_LAYOUT_6POINT1_FRONT = (AV_CH_LAYOUT_6POINT0_FRONT or AV_CH_LOW_FREQUENCY)
val AV_CH_LAYOUT_7POINT0 = (AV_CH_LAYOUT_5POINT0 or AV_CH_BACK_LEFT or AV_CH_BACK_RIGHT)
val AV_CH_LAYOUT_7POINT0_FRONT =
    (AV_CH_LAYOUT_5POINT0 or AV_CH_FRONT_LEFT_OF_CENTER or AV_CH_FRONT_RIGHT_OF_CENTER)
val AV_CH_LAYOUT_7POINT1 = (AV_CH_LAYOUT_5POINT1 or AV_CH_BACK_LEFT or AV_CH_BACK_RIGHT)
val AV_CH_LAYOUT_7POINT1_WIDE =
    (AV_CH_LAYOUT_5POINT1 or AV_CH_FRONT_LEFT_OF_CENTER or AV_CH_FRONT_RIGHT_OF_CENTER)
val AV_CH_LAYOUT_7POINT1_WIDE_BACK =
    (AV_CH_LAYOUT_5POINT1_BACK or AV_CH_FRONT_LEFT_OF_CENTER or AV_CH_FRONT_RIGHT_OF_CENTER)
val AV_CH_LAYOUT_OCTAGONAL =
    (AV_CH_LAYOUT_5POINT0 or AV_CH_BACK_LEFT or AV_CH_BACK_CENTER or AV_CH_BACK_RIGHT)
//val AV_CH_LAYOUT_HEXADECAGONAL =
//    (AV_CH_LAYOUT_OCTAGONAL or AV_CH_WIDE_LEFT or AV_CH_WIDE_RIGHT or AV_CH_TOP_BACK_LEFT or AV_CH_TOP_BACK_RIGHT or AV_CH_TOP_BACK_CENTER or AV_CH_TOP_FRONT_CENTER or AV_CH_TOP_FRONT_LEFT or AV_CH_TOP_FRONT_RIGHT)
//val AV_CH_LAYOUT_STEREO_DOWNMIX = (AV_CH_STEREO_LEFT or AV_CH_STEREO_RIGHT)


