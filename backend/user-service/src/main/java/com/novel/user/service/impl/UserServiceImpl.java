package com.novel.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.novel.common.exception.BusinessException;
import com.novel.common.util.JwtUtil;
import com.novel.user.entity.User;
import com.novel.user.mapper.UserMapper;
import com.novel.user.service.UserService;
import org.springframework.stereotype.Service;
import org.springframework.util.DigestUtils;

import java.util.HashMap;
import java.util.Map;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public String login(String username, String password) {
        User user = getByUsername(username);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        String md5Pwd = DigestUtils.md5DigestAsHex(password.getBytes());
        if (!user.getPassword().equals(md5Pwd)) {
            throw new BusinessException("密码错误");
        }
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId());
        claims.put("username", user.getUsername());
        return JwtUtil.generateToken(claims);
    }

    @Override
    public void register(String username, String password, String nickname) {
        if (getByUsername(username) != null) {
            throw new BusinessException("用户名已存在");
        }
        User user = new User();
        user.setUsername(username);
        user.setPassword(DigestUtils.md5DigestAsHex(password.getBytes()));
        user.setNickname(nickname == null ? username : nickname);
        user.setAvatar("default_avatar.png");
        save(user);
    }

    @Override
    public User getByUsername(String username) {
        return getOne(new LambdaQueryWrapper<User>().eq(User::getUsername, username));
    }

    @Override
    public Map<String, Object> getUserProfile(Long userId) {
        User user = getById(userId);
        if (user == null) throw new BusinessException("用户不存在");
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", user.getId());
        profile.put("username", user.getUsername());
        profile.put("nickname", user.getNickname());
        profile.put("email", user.getEmail());
        profile.put("avatar", user.getAvatar());
        profile.put("bio", user.getBio());
        profile.put("gender", user.getGender());
        profile.put("createTime", user.getCreateTime());
        return profile;
    }

    @Override
    public void updateProfile(User user) {
        User existing = getById(user.getId());
        if (existing == null) throw new BusinessException("用户不存在");
        existing.setNickname(user.getNickname());
        existing.setEmail(user.getEmail());
        existing.setAvatar(user.getAvatar());
        existing.setBio(user.getBio());
        existing.setGender(user.getGender());
        updateById(existing);
    }
}
