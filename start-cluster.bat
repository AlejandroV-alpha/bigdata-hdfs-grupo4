@echo off
echo ==============================================
echo  Despliegue de Cluster Hadoop HDFS - Grupo 04
echo ==============================================

rem 1. Crear red virtual de Docker si no existe
docker network inspect hadoop_network >nul 2>&1
if %errorlevel% neq 0 (
    echo [+] Creando red virtual hadoop_network...
    docker network create hadoop_network
) else (
    echo [*] Red virtual hadoop_network ya existe.
)

rem 2. Construir imagen base de Hadoop 3.3.6
echo [+] Construyendo imagen base hadoop-base:3.3.6...
docker build -t hadoop-base:3.3.6 .
if %errorlevel% neq 0 (
    echo [!] Error al construir la imagen base.
    pause
    exit /b %errorlevel%
)

rem 3. Levantar servicios con Docker Compose
echo [+] Levantando servicios del cluster...
docker compose up -d
if %errorlevel% neq 0 (
    docker-compose up -d
)

echo ==============================================
echo Cluster iniciado con exito.
echo NameNode Web UI: http://localhost:9870
echo YARN ResourceManager: http://localhost:8089
echo ==============================================
pause
