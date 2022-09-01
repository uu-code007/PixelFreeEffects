/*
 * Copyright (C) 2021 Thibault B.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.hapi.avparam

import java.nio.ByteBuffer

/**
 * Frame internal representation.
 */
data class EncodeFrame(

    var frameNulType: Int,

    var infoStatus: Int,
    /**
     * Contains an audio or video frame data.
     */
    var buffer: ByteBuffer,

    /**
     * Frame mime type
     */
    val mimeType: String,

    /**
     * Presentation timestamp in µs
     */
    var pts: Long,

    /**
     * Decoded timestamp in µs (not used).
     */
    var dts: Long? = null,

    /**
     * [Boolean.true] if frame is a key frame (I-frame for AVC/HEVC and audio frames)
     */
    val isKeyFrame: Boolean = false,

    /**
     * Contains extra frame description.
     * For AAC, it contains ADTS.
     */
    val extra: ByteBuffer? = null


)