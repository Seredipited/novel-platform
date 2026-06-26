package com.novel.common.exception;

import com.novel.common.result.Result;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        log.warn("Business exception: {}", e.getMessage());
        return Result.error(e.getCode(), e.getMessage());
    }

    @ExceptionHandler(ExpiredJwtException.class)
    public Result<?> handleExpiredJwtException(ExpiredJwtException e) {
        log.warn("Token expired: {}", e.getMessage());
        return Result.error(401, "登录已过期，请重新登录");
    }

    @ExceptionHandler(JwtException.class)
    public Result<?> handleJwtException(JwtException e) {
        log.warn("Invalid token: {}", e.getMessage());
        return Result.error(401, "认证失败，请重新登录");
    }

    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        log.error("System exception: ", e);
        return Result.error("服务器繁忙，请稍后重试");
    }
}
