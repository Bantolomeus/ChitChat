package com.bantolomeus.chitchat

import org.apache.log4j.Logger
import org.springframework.web.socket.TextMessage
import org.springframework.web.socket.WebSocketSession
import org.springframework.web.socket.handler.TextWebSocketHandler

class EchoWebSocketHandler: TextWebSocketHandler() {

    override fun handleTextMessage(session: WebSocketSession?, message: TextMessage?) {
        Logger.getLogger(this.javaClass).info(message)
        session?.sendMessage(message)
    }
}
