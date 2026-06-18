@echo off
echo === Service Port Status ===
for %%p in (8080 8081 8082 8083) do (
  netstat -ano | findstr "LISTENING" | findstr ":%%p " >nul
  if errorlevel 1 (echo %%p : NOT RUNNING) else (echo %%p : RUNNING)
)
