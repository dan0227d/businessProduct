package com.example.demo.exception;

import java.sql.SQLException;

import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.example.demo.dto.ErrorResponse;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDatabaseException(
            DataAccessException ex) {

        SQLException sqlException = findSQLException(ex);

        if (sqlException != null
                && "45000".equals(sqlException.getSQLState())) {

            String message = sqlException.getMessage();

            HttpStatus status = HttpStatus.BAD_REQUEST;

            if (message.contains("不存在")) {
                status = HttpStatus.NOT_FOUND;
            } else if (message.contains("無法刪除")) {
                status = HttpStatus.CONFLICT;
            }

            return ResponseEntity.status(status)
                    .body(new ErrorResponse(status.value(), message));
        }

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(500, "資料庫操作失敗"));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception ex) {

        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse(500, "伺服器發生錯誤"));
    }

    private SQLException findSQLException(Throwable ex) {

        Throwable cause = ex;

        while (cause != null) {

            if (cause instanceof SQLException sqlException) {
                return sqlException;
            }

            cause = cause.getCause();
        }

        return null;
    }
}