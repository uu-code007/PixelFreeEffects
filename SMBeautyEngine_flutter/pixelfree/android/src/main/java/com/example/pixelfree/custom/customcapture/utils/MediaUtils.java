package com.example.custom.customcapture.utils;

import android.media.MediaCodec;
import android.media.MediaFormat;

import com.example.custom.customcapture.exceptions.SetupException;
import com.example.custom.customcapture.extractor.Extractor;
import com.example.custom.customcapture.extractor.RangeExtractorAdvancer;


public class MediaUtils {
    public static final String KEY_ROTATION = "rotation-degrees";

    public static boolean hasEosFlag(int flags) {
        return (flags & MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0;
    }

    public static MediaFormat retriveMediaFormat(String videoPath, boolean selectVideo) throws SetupException {
        MediaFormat mediaFormat;
        Extractor   extractor = new Extractor(selectVideo, videoPath, new RangeExtractorAdvancer());
        try {
            extractor.setup();
            mediaFormat = extractor.getMediaFormat();
        } finally {
            extractor.release();
        }
        return mediaFormat;
    }

    public static void checkState(boolean expression, Object errorMessage) {
        if (!expression) {
            throw new IllegalStateException(String.valueOf(errorMessage));
        }
    }
}
