#!/bin/bash
# ==============================================================================
# Script: 00_inicializar_hdfs_grupo04.sh
# Rol: Persona 1 - Infraestructura y Consolidacion
# Descripcion: Inicializa las rutas reglamentarias de HDFS para el Grupo 04
# ==============================================================================
set -e

echo "=================================================="
echo "  Inicializacion de Directorios HDFS - Grupo 04   "
echo "=================================================="

echo "[1/4] Verificando conectividad con el NameNode..."
if ! docker exec namenode hdfs dfsadmin -report >/dev/null 2>&1; then
    echo "[!] ERROR: El contenedor 'namenode' no responde o no esta iniciado."
    exit 1
fi
echo "[+] NameNode operativo y respondiendo."

echo "[2/4] Verificando factor de replicacion global..."
REPL=$(docker exec namenode hdfs getconf -confKey dfs.replication)
echo "[+] dfs.replication = $REPL (Requerido: >= 2)"

echo "[3/4] Creando estructura de directorios /grupo04/ en HDFS..."
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_1GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_10GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/resultados
docker exec namenode hdfs dfs -mkdir -p /grupo04/evidencias

echo "[4/4] Listando estructura HDFS creada:"
docker exec namenode hdfs dfs -ls /grupo04

echo "=================================================="
echo "  Inicializacion de HDFS completada con exito!    "
echo "=================================================="
