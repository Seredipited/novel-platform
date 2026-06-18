package com.novel.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.novel.user.entity.User;
import java.util.Map;

public interface UserService extends IService<User> {
    String login(String username, String password);
    void register(String username, String password, String nickname);
    User getByUsername(String username);
    Map<String, Object> getUserProfile(Long userId);
    void updateProfile(User user);
}
