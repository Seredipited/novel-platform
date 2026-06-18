@echo off
docker logs nacos > %TEMP%\nacos_log.txt 2>&1
type %TEMP%\nacos_log.txt
