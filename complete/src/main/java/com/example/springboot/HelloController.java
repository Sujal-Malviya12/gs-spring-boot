package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

  
  @GetMapping("/")
public String index() {
  try {
    Thread.sleep(200); // simulate slow processing (200ms)
  } catch (InterruptedException e) {
    Thread.currentThread().interrupt();
  }
  return "Greetings from Spring Boot!";
}


}
