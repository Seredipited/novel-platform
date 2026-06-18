@echo off
chcp 65001 >nul
"D:\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p112233 --default-character-set=utf8mb4 -e "DROP DATABASE IF EXISTS novel_platform; CREATE DATABASE novel_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
"D:\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p112233 --default-character-set=utf8mb4 novel_platform -e "source d:/IDEA/ssm/novel-platform/sql/init.sql"
if %ERRORLEVEL% equ 0 (
    echo SUCCESS!
) else (
    echo FAILED! Errorlevel=%ERRORLEVEL%
)
pause
