# ==============================================================================
# Script: 00_inicializar_hdfs_grupo04.ps1
# Rol: Persona 1 - Infraestructura y Consolidacion
# Descripcion: Inicializa las rutas reglamentarias de HDFS para el Grupo 04
#              y comprueba el estado operativo del cluster y la replicacion.
# ==============================================================================

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Inicializacion de Directorios HDFS - Grupo 04   " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Comprobar NameNode activo
Write-Host "`n[1/4] Verificando conectividad con el NameNode..." -ForegroundColor Yellow
$report = docker exec namenode hdfs dfsadmin -report 2>$null
if (-not $?) {
    Write-Host "[!] ERROR: El contenedor 'namenode' no responde o no esta iniciado." -ForegroundColor Red
    Write-Host "    Asegurese de haber ejecutado .\start-cluster.bat antes de este script." -ForegroundColor Red
    exit 1
}
Write-Host "[+] NameNode operativo y respondiendo." -ForegroundColor Green

# 2. Comprobar factor de replicacion configurado
Write-Host "`n[2/4] Verificando factor de replicacion global..." -ForegroundColor Yellow
$replication = docker exec namenode hdfs getconf -confKey dfs.replication
Write-Host "[+] dfs.replication = $replication (Requerido: >= 2)" -ForegroundColor Green

# 3. Crear directorios reglamentarios para el Grupo 04
Write-Host "`n[3/4] Creando estructura de directorios /grupo04/ en HDFS..." -ForegroundColor Yellow
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_1GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/dataset_10GB
docker exec namenode hdfs dfs -mkdir -p /grupo04/resultados
docker exec namenode hdfs dfs -mkdir -p /grupo04/evidencias
Write-Host "[+] Directorios creados correctamente:" -ForegroundColor Green
Write-Host "    - /grupo04/dataset_1GB"
Write-Host "    - /grupo04/dataset_10GB"
Write-Host "    - /grupo04/resultados"
Write-Host "    - /grupo04/evidencias"

# 4. Listar contenido de /grupo04
Write-Host "`n[4/4] Listando estructura HDFS creada:" -ForegroundColor Yellow
docker exec namenode hdfs dfs -ls /grupo04

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Inicializacion de HDFS completada con exito!    " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
