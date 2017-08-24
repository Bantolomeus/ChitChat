package com.bantolomeus.chitchat.controller

import com.bantolomeus.chitchat.model.Greeting
import com.bantolomeus.chitchat.model.Message
import org.springframework.messaging.handler.annotation.MessageMapping
import org.springframework.messaging.handler.annotation.SendTo
import org.springframework.stereotype.Controller

@Controller
class MessageController {

    @MessageMapping("/hello")
    @SendTo("/topic/message")
    fun greeting(message: Message): Greeting {
        return Greeting("Hello, " + message.name + "!")
    }
}