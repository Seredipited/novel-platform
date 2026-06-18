package com.novel.user.controller;

import com.novel.common.result.Result;
import com.novel.common.util.JwtUtil;
import com.novel.user.entity.User;
import com.novel.user.service.UserService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private UserService userService;

    @PostMapping("/login")
    public Result<Map<String, String>> login(@RequestBody Map<String, String> params) {
        String token = userService.login(params.get("username"), params.get("password"));
        return Result.success(java.util.Collections.singletonMap("token", token));
    }

    @PostMapping("/register")
    public Result<?> register(@RequestBody Map<String, String> params) {
        userService.register(params.get("username"), params.get("password"), params.get("nickname"));
        return Result.success();
    }

    @GetMapping("/profile")
    public Result<Map<String, Object>> profile(@RequestHeader("Authorization") String auth) {
        String token = auth.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        return Result.success(userService.getUserProfile(userId));
    }

    @PutMapping("/profile")
    public Result<?> updateProfile(@RequestHeader("Authorization") String auth, @RequestBody User user) {
        String token = auth.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        user.setId(userId);
        userService.updateProfile(user);
        return Result.success();
    }
}
