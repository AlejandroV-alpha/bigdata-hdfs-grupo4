# Prueba HDFS - Grupo 04
# Simulacion de falla de datanode1 para el dataset de 10 GB

$Dataset = "/grupo04/dataset_10GB/dataset_grupo04_10GB"

Write-Host "=== FALLA DE DATANODE1 - DATASET 10 GB ==="

# Detener solamente datanode1
Write-Host ""
Write-Host "Deteniendo datanode1..."
docker compose stop datanode1

# Verificar que el nodo fue detenido
Write-Host ""
Write-Host "=== ESTADO DE CONTENEDORES ==="
docker compose ps -a

Write-Host ""
Write-Host "Esperar hasta que el NameNode detecte datanode1 como muerto."
Write-Host "Esto puede tardar aproximadamente 10 minutos."

# Verificar estado de los DataNodes
Write-Host ""
Write-Host "Cuando haya pasado el tiempo de deteccion, ejecutar:"
Write-Host "docker exec namenode hdfs dfsadmin -report"

# Analizar bloques durante la falla
Write-Host ""
Write-Host "Para comprobar los bloques subreplicados, ejecutar:"
Write-Host "docker exec namenode hdfs fsck $Dataset -files -blocks -locations"

# Comprobar lectura del dataset
Write-Host ""
Write-Host "Para comprobar que el archivo sigue siendo legible, ejecutar:"
Write-Host "docker exec namenode sh -c 'hdfs dfs -cat /grupo04/dataset_10GB/dataset_grupo04_10GB | wc -c'"

Write-Host ""
Write-Host "=== DATANODE1 DETENIDO ==="