package com.hmdp.utils;

import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 只做登录校验，用户信息由 {@link RefreshTokenInterceptor} 提前放入 ThreadLocal。
 */
public class LoginInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        if (UserHolder.getUser() == null) {
            response.setStatus(401);
            return false;
        }
        System.out.println("LoginInterceptor 路径: " + request.getRequestURI());
        return true;
    }
}
