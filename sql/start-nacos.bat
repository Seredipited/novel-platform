@echo off
docker rm -f nacos 2>nul
docker run -d --name nacos --restart=unless-stopped ^
  -p 18848:8848 -p 19848:9848 -p 19849:9849 ^
  -e MODE=standalone ^
  -e PREFER_HOST_MODE=hostname ^
  -e NACOS_AUTH_ENABLE=false ^
  -e SPRING_DATASOURCE_PLATFORM=mysql ^
  -e MYSQL_SERVICE_HOST=host.docker.internal ^
  -e MYSQL_SERVICE_PORT=3306 ^
  -e MYSQL_SERVICE_DB_NAME=nacos_config ^
  -e MYSQL_SERVICE_USER=root ^
  -e MYSQL_SERVICE_PASSWORD=112233 ^
  -e MYSQL_SERVICE_DB_PARAM=characterEncoding=utf8^&connectTimeout=1000^&socketTimeout=3000^&autoReconnect=true^&useSSL=false^&serverTimezone=UTC^&allowPublicKeyRetrieval=true ^
  -v C:\Users\chenhao.com\nacos\data:/home/nacos/data ^
  -v C:\Users\chenhao.com\nacos\logs:/home/nacos/logs ^
  nacos/nacos-server:v2.2.3

ping -n 15 127.0.0.1 >nul
echo === Nacos Logs ===
docker logs nacos 2>&1 | findstr /i "storage mysql nacos started"
echo === Container Status ===
docker ps --filter name=nacos --format "{{.Status}}"
