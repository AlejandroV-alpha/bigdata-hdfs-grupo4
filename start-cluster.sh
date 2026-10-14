#!/bin/bash
set -e

echo "=== Despliegue de Cluster Hadoop HDFS - Grupo 04 ==="

# 1. Crear red de docker si no existe
if ! docker network inspect hadoop_network >/dev/null 2>&1; then
    echo "[+] Creando red virtual hadoop_network..."
    docker network create hadoop_network
else
    echo "[*] Red virtual hadoop_network ya existe."
fi

# 2. Construir imagen base de Hadoop 3.3.6
echo "[+] Construyendo imagen base hadoop-base:3.3.6..."
docker build -t hadoop-base:3.3.6 .

# 3. Levantar servicios con Docker Compose
echo "[+] Levantando servicios del cluster..."
if docker compose version >/dev/null 2>&1; then
    docker compose up -d
else
    docker-compose up -d
fi

echo "=================================================="
echo "Cluster iniciado con exito."
echo "NameNode Web UI: http://localhost:9870"
echo "YARN ResourceManager: http://localhost:8089"
echo "=================================================="