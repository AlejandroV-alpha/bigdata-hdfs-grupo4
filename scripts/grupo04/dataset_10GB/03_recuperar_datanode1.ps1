# Prueba HDFS - Grupo 04
# Recuperacion de datanode1 despues de la prueba de fallo

$Dataset = "/grupo04/dataset_10GB/dataset_grupo04_10GB"

Write-Host "=== RECUPERACION DE DATANODE1 - DATASET 10 GB ==="

# Verificar primero el estado de replicacion
Write-Host ""
Write-Host "=== ESTADO DE REPLICACION ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations

Write-Host ""
Write-Host "Si HDFS muestra 0 bloques subreplicados y replicacion promedio 2.0,"
Write-Host "significa que las replicas ya fueron recuperadas automaticamente."

# Restaurar datanode1
Write-Host ""
Write-Host "Iniciando datanode1..."
docker compose start datanode1

Write-Host ""
Write-Host "Esperar entre 30 y 60 segundos para que el nodo vuelva a estar disponible."

# Mostrar comandos finales de comprobacion
Write-Host ""
Write-Host "Despues de esperar, ejecutar:"
Write-Host "docker compose ps"

Write-Host ""
Write-Host "Verificar que HDFS reconoce nuevamente los 3 DataNodes:"
Write-Host "docker exec namenode hdfs dfsadmin -report"

Write-Host ""
Write-Host "Verificar el estado final del dataset:"
Write-Host "docker exec namenode hdfs fsck $Dataset -files -blocks -locations"

Write-Host ""
Write-Host "=== RECUPERACION INICIADA ==="