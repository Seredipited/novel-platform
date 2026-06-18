@echo off
echo === Testing user-service directly (8081) ===
curl.exe -s -X POST http://localhost:8081/user/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"123456\"}"
echo.
echo === Testing via Gateway (8080) ===
curl.exe -s -X POST http://localhost:8080/api/user/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"123456\"}"
echo.
pause
