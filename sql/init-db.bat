@echo off
echo ========================================
echo 初始化 novel_platform 数据库
echo ========================================
"D:\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p112233 < "d:\IDEA\ssm\novel-platform\sql\init.sql"
if %ERRORLEVEL% equ 0 (
    echo.
    echo 数据库初始化成功!
) else (
    echo.
    echo 数据库初始化失败，请检查:
    echo   1. MySQL 服务是否启动
    echo   2. root 密码是否为 112233
    echo   3. MySQL 路径是否正确
)
echo.
pause
