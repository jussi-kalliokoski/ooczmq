use czmq
import czmq

import structs/ArrayList

Tee : class {
    loop: Loop
    pullSocket: Socket
    pushSockets: ArrayList<Socket>
    readCallback: LoopCallback

    init: func ~withPushSockets (=loop, =pullSocket, =pushSockets) {
        readCallback = loop addEvent(pullSocket, ZMQ POLLIN, |loop, item| pump())
    }

    init: func ~withoutPushSockets (=loop, =pullSocket) {
        pushSockets = ArrayList<Socket> new()
        readCallback = loop addEvent(pullSocket, ZMQ POLLIN, |loop, item| pump())
    }
    
    pump: func () {
        frame := pullSocket recvFrameNoWait()
        if(frame) {
            list := ArrayListIterator new(pushSockets)
            while (list hasNext?()) {
                pushSocket := list next()
                pushSocket sendFrame(frame)
            }
        }
    }

    destroy: func () {
        loop removeEvent(readCallback)
    }
}
