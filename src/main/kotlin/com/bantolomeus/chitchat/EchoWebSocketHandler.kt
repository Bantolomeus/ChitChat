package com.bantolomeus.chitchat

import org.apache.log4j.Logger
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler
import java.util.concurrent.CopyOnWriteArrayList

/*
* @param <E> the type of elements held in this collection
*/
class EchoWebSocketHandler(var sessions: CopyOnWriteArrayList<Any>): TextWebSocketHandler() {

    override fun handleTextMessage(session: WebSocketSession?, message: TextMessage?) {
        Logger.getLogger(this.javaClass).info(message)
        session?.sendMessage(message)
    }

    override fun afterConnectionEstablished(session: WebSocketSession?) {
        sessions.add(session)
    }
}
