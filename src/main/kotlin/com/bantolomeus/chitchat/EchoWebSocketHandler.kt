package com.bantolomeus.chitchat

import org.apache.log4j.Logger
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler
import java.util.concurrent.CopyOnWriteArrayList

class EchoWebSocketHandler: TextWebSocketHandler() {

    private var sessions: CopyOnWriteArrayList<WebSocketSession> = CopyOnWriteArrayList()

    override fun handleTextMessage(session: WebSocketSession?, message: TextMessage?) {
        Logger.getLogger(this.javaClass).info(message)
        sessions
                .filter { it.isOpen }
                .forEach { it.sendMessage(message) }
    }

    override fun afterConnectionEstablished(session: WebSocketSession?) {
        sessions.add(session)
    }
}
