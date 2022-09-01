package com.hapi.avparam

enum class CodingStatus  (val intStatus: Int) {

    STATE_UNKNOWN(-1),
    STATE_DECODING(0),
    STATE_PAUSE(1),
    STATE_STOP(2),
//    STATE_FINISH(3);

}

