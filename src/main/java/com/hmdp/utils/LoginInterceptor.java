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
        if (isPublicRead(request)) {
            return true;
        }
        if (UserHolder.getUser() == null) {
            response.setStatus(401);
            return false;
        }
        return true;
    }

    private boolean isPublicRead(HttpServletRequest request) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) {
            return false;
        }
        String uri = request.getRequestURI();
        return uri.startsWith("/shop/")
                || uri.startsWith("/shop-type/")
                || uri.startsWith("/voucher/list/")
                || "/blog/hot".equals(uri)
                || (uri.startsWith("/blog/") && uri.matches("/blog/\\d+"))
                || (uri.startsWith("/blog/likes/") && uri.matches("/blog/likes/\\d+"))
                || (uri.startsWith("/blog-comments/of/blog/") && uri.matches("/blog-comments/of/blog/\\d+"));
    }
}
