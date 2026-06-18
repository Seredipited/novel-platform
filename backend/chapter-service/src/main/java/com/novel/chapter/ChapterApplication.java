package com.novel.chapter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication(scanBasePackages = "com.novel")
@EnableDiscoveryClient
@EnableFeignClients
public class ChapterApplication {
    public static void main(String[] args) {
        SpringApplication.run(ChapterApplication.class, args);
    }
}
