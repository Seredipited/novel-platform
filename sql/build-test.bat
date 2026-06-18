@echo off
chcp 65001 >nul
cd /d D:\IDEA\ssm\novel-platform\backend
call mvnw.cmd clean compile -pl ai-service -am -DskipTests > build-log.txt 2>&1
echo BUILD EXIT CODE: %ERRORLEVEL% >> build-log.txt
type build-log.txt
