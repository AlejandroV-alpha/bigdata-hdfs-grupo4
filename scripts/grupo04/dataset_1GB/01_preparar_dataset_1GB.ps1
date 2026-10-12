# Prueba HDFS - Grupo 04
# Preparacion del dataset de 1 GB

$HdfsDir  = "/grupo04/dataset_1GB"
$Dataset  = "/grupo04/dataset_1GB/dataset_grupo04_1GB"
$LocalTmp = "/tmp/dataset_grupo04_1GB"
$Evid     = "evidencias\grupo04\dataset_1GB"

New-Item -ItemType Directory -Force -Path $Evid | Out-Null

Write-Host "=== PREPARACION DEL DATASET DE 1 GB - GRUPO 04 ==="

# Crear directorios del Grupo 04
Write-Host ""
Write-Host "Creando directorios HDFS..."
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_1GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_10GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/resultados
docker exec namenode hdfs dfs -mkdir -p /grupo04/evidencias
docker exec namenode hdfs dfs -ls /grupo04

# Verificar el factor de replicacion
Write-Host ""
Write-Host "=== FACTOR DE REPLICACION ==="
docker exec namenode hdfs getconf -confKey dfs.replication

# Verificar que los 3 DataNodes estan activos
Write-Host ""
Write-Host "=== DATANODES ACTIVOS ==="
docker exec namenode hdfs dfsadmin -report | Select-String "Live datanodes|Dead datanodes"

# Generar el archivo de 1 GB con datos aleatorios dentro del NameNode
Write-Host ""
Write-Host "Generando dataset de 1 GB (datos aleatorios)..."
docker exec namenode sh -c "dd if=/dev/urandom of=$LocalTmp bs=1M count=1024"
docker exec namenode ls -lh $LocalTmp

# Hash original para comprobar integridad
Write-Host ""
Write-Host "=== MD5 ORIGINAL ==="
docker exec namenode sh -c "md5sum $LocalTmp | tee /tmp/md5_original.txt"

# Subir a HDFS con replicacion 2
Write-Host ""
Write-Host "Subiendo el dataset a HDFS (replicacion 2)..."
docker exec namenode hdfs dfs -D dfs.replication=2 -put -f $LocalTmp $HdfsDir/

# Verificar que fue creado
Write-Host ""
Write-Host "=== DATASET CREADO ==="
docker exec namenode hdfs dfs -ls -h $HdfsDir

# Bloques, replicas y ubicaciones
Write-Host ""
Write-Host "=== BLOQUES Y REPLICAS ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations

# Integridad desde HDFS
Write-Host ""
Write-Host "=== MD5 DESDE HDFS (debe coincidir con el original) ==="
docker exec namenode sh -c "hdfs dfs -cat $Dataset | md5sum"

Write-Host ""
Write-Host "=== PREPARACION FINALIZADA ==="
