# Prueba HDFS - Grupo 04
# Simulacion de falla de datanode2 para el dataset de 1 GB
# Ejecutar desde la carpeta raiz del repositorio.

$Dataset = "/grupo04/dataset_1GB/dataset_grupo04_1GB"
$Evid    = "evidencias\grupo04\dataset_1GB"

New-Item -ItemType Directory -Force -Path $Evid | Out-Null

Write-Host "=== FALLA DE DATANODE2 - DATASET 1 GB ==="

# Estado inicial (antes de la falla)
Write-Host ""
Write-Host "=== ESTADO INICIAL ==="
docker exec namenode hdfs dfsadmin -report | Select-String "Under replicated|Live datanodes|Dead datanodes"
docker exec namenode hdfs fsck $Dataset -files -blocks -locations 2>&1 |
    Out-File -Encoding utf8 "$Evid\fsck_1GB_antes.txt"
Write-Host "fsck guardado en $Evid\fsck_1GB_antes.txt"

# Detener solamente datanode2
Write-Host ""
$t0 = Get-Date
Write-Host "Deteniendo datanode2... Hora de la falla: $($t0.ToString('HH:mm:ss'))"
docker compose stop datanode2

Write-Host ""
Write-Host "=== ESTADO DE CONTENEDORES ==="
docker compose ps -a

# Monitoreo cada 5 s (maximo 4 minutos) hasta que el NameNode lo declare muerto
Write-Host ""
Write-Host "Esperando que el NameNode detecte datanode2 como muerto (aprox. 1-2 min)..."
$log = "$Evid\monitoreo_falla_1GB.txt"
"Hora de la falla: $($t0.ToString('HH:mm:ss'))" | Out-File -Encoding utf8 $log
for ($i = 0; $i -lt 48; $i++) {
    $estado = docker exec namenode hdfs dfsadmin -report 2>&1 |
        Select-String "Under replicated|Live datanodes|Dead datanodes"
    $linea = "$(Get-Date -Format 'HH:mm:ss') | " + (($estado | ForEach-Object { $_.Line.Trim() }) -join " | ")
    Write-Host $linea
    $linea | Out-File -Append -Encoding utf8 $log
    if ($estado -match "Dead datanodes \(1\)") {
        Write-Host "Deteccion: $((Get-Date) - $t0) despues de la falla"
        break
    }
    Start-Sleep -Seconds 5
}

# Estado del archivo y bloques durante la falla
Write-Host ""
Write-Host "=== ARCHIVO Y BLOQUES DURANTE LA FALLA ==="
docker exec namenode hdfs fsck $Dataset -files -blocks -locations 2>&1 |
    Out-File -Encoding utf8 "$Evid\fsck_1GB_durante.txt"
Get-Content "$Evid\fsck_1GB_durante.txt" | Select-String "Status|data-nodes|Under-replicated|Average block replication"

# Lectura del dataset (el MD5 debe coincidir con el original)
Write-Host ""
Write-Host "=== LECTURA DEL ARCHIVO ==="
docker exec namenode sh -c "hdfs dfs -cat $Dataset | md5sum"
Write-Host "MD5 original:"
docker exec namenode cat /tmp/md5_original.txt

Write-Host ""
Write-Host "=== DATANODE2 DETENIDO ==="
Write-Host "Cuando 'Under replicated blocks' sea 0, anota la hora: ese es el fin de la recuperacion."
Write-Host "Para ver donde se crearon las nuevas replicas, ejecuta:"
Write-Host "docker exec namenode hdfs fsck $Dataset -files -blocks -locations"
