package com.vendorflow.controller;

import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AIController {

    @PostMapping("/generate-caption")
    public Map<String, String> generateCaption() {
        // Mock implementation for MVP. In reality, we'd send the image to Gemini/OpenAI API.
        Map<String, String> response = new HashMap<>();
        response.put("caption", "🌟 Step out in style! This gorgeous piece is exactly what your wardrobe needs. Perfect for any occasion. Grab yours before it's gone! ✨ #Fashion #Trending #MustHave");
        response.put("keywords", "Fashion, Trending, Dress, OOTD");
        return response;
    }
}
