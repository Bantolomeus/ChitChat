package com.bantolomeus.chitchat

import org.springframework.boot.SpringApplication
import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class ChitchatApplication

fun main(args: Array<String>) {
    SpringApplication.run(ChitchatApplication::class.java, *args)
}
