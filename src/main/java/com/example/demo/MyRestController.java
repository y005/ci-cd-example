package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MyRestController {
  @GetMapping("/api/v1/test")
  public String start() {
    return "hello world";
  }
}
