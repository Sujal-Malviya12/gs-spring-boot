package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  @GetMapping("/")
public String index() throws InterruptedException {
    Thread.sleep(300); // intentional slowdown for perf gating
    return "Greetings from Spring Boot!";
}


}
