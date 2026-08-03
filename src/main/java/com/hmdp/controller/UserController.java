package com.hmdp.controller;

import cn.hutool.json.JSONUtil;
import com.hmdp.dto.LoginFormDTO;
import com.hmdp.dto.Result;
import com.hmdp.entity.UserInfo;
import com.hmdp.service.IUserInfoService;
import com.hmdp.service.IUserService;
import com.hmdp.utils.UserHolder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Resource
    private IUserService userService;

    @Resource
    private IUserInfoService userInfoService;

    @PostMapping("code")
    public Result sendCode(@RequestParam("phone") String phone) {
        return userService.sendCode(phone);
    }

    @PostMapping("/login")
    public Result login(@RequestBody LoginFormDTO loginForm) {
        return userService.login(loginForm);
    }

    @PostMapping("/logout")
    public Result logout(@RequestHeader("authorization") String token) {
        return userService.logout(token);
    }

    @GetMapping("/me")
    public Result me() {
        return Result.ok(UserHolder.getUser());
    }

    @GetMapping("/info/{id}")
    public Result info(@PathVariable("id") Long userId) {
        UserInfo info = userInfoService.getById(userId);
        if (info == null) {
            // 没有详情，说明是第一次查看
            return Result.ok();
        }
        info.setCreateTime(null);
        info.setUpdateTime(null);
        return Result.ok(info);
    }
}
