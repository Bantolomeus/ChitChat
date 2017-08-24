package com.bantolomeus.chitchat.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.socket.config.annotation.WebSocketConfigurer
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry

@Configuration
class WebSocketConfig: WebSocketConfigurer{


    override fun registerWebSocketHandlers(registry: WebSocketHandlerRegistry?) {
//        registry.addHandler()

    }

}
