# Prueba HDFS - Grupo 04
# Preparacion del dataset de 10 GB

$HdfsDir = "/grupo04/dataset_10GB"
$Dataset = "/grupo04/dataset_10GB/dataset_grupo04_10GB"

Write-Host "=== PREPARACION DEL DATASET DE 10 GB - GRUPO 04 ==="

# Crear el directorio del Grupo 4 si no existe
Write-Host ""
Write-Host "Creando directorio HDFS..."
docker exec namenode hdfs dfs -mkdir -p $HdfsDir

# Verificar el directorio
Write-Host ""
Write-Host "=== DIRECTORIO DEL GRUPO 04 ==="
docker exec namenode hdfs dfs -ls /grupo04

# Verificar el factor de replicacion
Write-Host ""
Write-Host "=== FACTOR DE REPLICACION ==="
docker exec namenode hdfs getconf -confKey dfs.replication

# Eliminar un dataset anterior si existe
Write-Host ""
Write-Host "Eliminando dataset anterior si existe..."
docker exec namenode hdfs dfs -rm -f $Dataset

# Crear el dataset de 10 GB directamente en HDFS
Write-Host ""
Write-Host "Generando dataset de 10 GB..."
docker exec namenode sh -c 'dd if=/dev/zero bs=1M count=10240 2>/dev/null | hdfs dfs -put - /grupo04/dataset_10GB/dataset_grupo04_10GB'

# Verificar que el dataset fue creado
Write-Host ""
Write-Host "=== DATASET CREADO ==="
docker exec namenode hdfs dfs -ls -h $HdfsDir

# Analizar bloques, replicas y ubicaciones
Write-Host ""
Write-Host "=== BLOQUES Y REPLICAS ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations

Write-Host ""
Write-Host "=== PREPARACION FINALIZADA ==="