package com.hapi.avparam

enum class ConnectedStatus(val intStatus: Int) {
    CONNECTED_STATUS_NULL(1),
    CONNECTED_STATUS_START(2),
    CONNECTED_STATUS_CONNECTED(3),
    CONNECTED_STATUS_CONNECT_FAIL(4),
    CONNECTED_STATUS_TIMEOUT_PACKET(5),
    CONNECTED_STATUS_TIMEOUT_RESET(6),
    CONNECTED_STATUS_OFFLINE(7),
    CONNECTED_STATUS_CLOSE(8)

};

fun Int.toConnectedStatus(): ConnectedStatus {
    ConnectedStatus.values().forEach {
        if(it.intStatus==this){
            return it;
        }
    }
    return ConnectedStatus.CONNECTED_STATUS_NULL;
}
interface MuxerConnectCallBack {
    fun onConnectedStatus(status: ConnectedStatus, msg: String?="")
}