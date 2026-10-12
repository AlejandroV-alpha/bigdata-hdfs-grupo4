# Prueba HDFS - Grupo 04
# Recuperacion de datanode2 despues de la prueba de fallo (dataset de 1 GB)
# Ejecutar desde la carpeta raiz del repositorio.

$Dataset = "/grupo04/dataset_1GB/dataset_grupo04_1GB"
$Evid    = "evidencias\grupo04\dataset_1GB"

New-Item -ItemType Directory -Force -Path $Evid | Out-Null

Write-Host "=== RECUPERACION DE DATANODE2 - DATASET 1 GB ==="

# Estado de replicacion antes de reiniciar el nodo
Write-Host ""
Write-Host "=== ESTADO DE REPLICACION (nodo aun detenido) ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations 2>&1 |
    Out-File -Encoding utf8 "$Evid\fsck_1GB_despues_falla.txt"
Get-Content "$Evid\fsck_1GB_despues_falla.txt" | Select-String "Status|data-nodes|Under-replicated|Average block replication"
Write-Host "Si hay 0 bloques subreplicados y replicacion promedio 2.0, las replicas ya se recuperaron automaticamente."

# Restaurar datanode2
Write-Host ""
Write-Host "Iniciando datanode2..."
docker compose start datanode2

Write-Host ""
Write-Host "Esperando 60 segundos para que el nodo se registre..."
Start-Sleep -Seconds 60

Write-Host ""
Write-Host "=== ESTADO DE CONTENEDORES ==="
docker compose ps

Write-Host ""
Write-Host "=== DATANODES ACTIVOS ==="
docker exec namenode hdfs dfsadmin -report | Select-String "Under replicated|Live datanodes|Dead datanodes"

# Estado final del archivo
Write-Host ""
Write-Host "=== ESTADO FINAL DEL ARCHIVO ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations 2>&1 |
    Out-File -Encoding utf8 "$Evid\fsck_1GB_final.txt"
Get-Content "$Evid\fsck_1GB_final.txt" | Select-String "Status|data-nodes|Over-replicated|Under-replicated|Average block replication"

# Integridad final
Write-Host ""
Write-Host "=== INTEGRIDAD FINAL ==="
docker exec namenode sh -c "hdfs dfs -cat $Dataset | md5sum"

# Log del NameNode como evidencia
docker logs namenode 2>&1 | Out-File -Encoding utf8 "$Evid\namenode_log_1GB.txt"

Write-Host ""
Write-Host "=== RECUPERACION FINALIZADA ==="
