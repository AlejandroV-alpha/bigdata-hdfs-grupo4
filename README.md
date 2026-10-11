# bigdata-hdfs-grupo4

# Tolerancia a fallos y replicacion de datos en HDFS

## 1. Objetivo
Persona 1

## 2. Requerimientos
Persona 1

## 3. Arquitectura e identificacion del grupo
Persona 1

## 4. Instalacion y configuracion
Persona 1

## 5. Prueba de fallo - Dataset 1 GB
Persona 2

### 5.1 Estado inicial

### 5.2 Distribucion de bloques y replicas

### 5.3 Falla del DataNode

### 5.4 Estado durante la falla

### 5.5 Recuperacion

### 5.6 Analisis

## 6. Prueba de fallo - Dataset 10 GB
Persona 3

### 6.1 Estado inicial

Antes de realizar la prueba de fallo con el dataset de 10 GB, se verificó el estado del clúster Hadoop.

Mediante `docker compose ps` se comprobó que el NameNode y los tres DataNodes se encontraban activos y en estado `healthy`:

- NameNode → Activo
- DataNode1 → Activo
- DataNode2 → Activo
- DataNode3 → Activo

Posteriormente, se verificó el estado directamente desde HDFS mediante:

```bash
docker exec namenode hdfs dfsadmin -report
```

El reporte confirmó la existencia de **3 DataNodes activos**:

```text
Live datanodes (3)
```

Los tres DataNodes presentaron estado normal (`Decommission Status: Normal`), por lo que el clúster se encontraba disponible para iniciar la prueba de tolerancia a fallos.

#### Evidencias

Estado inicial del clúster:

![Estado inicial del cluster](evidencias/grupo04/dataset_10GB/02_cluster_estado_inicial_grupo04.png)

DataNodes activos reconocidos por HDFS:

![DataNodes activos en HDFS](evidencias/grupo04/dataset_10GB/03_hdfs_datanodes_inicial_grupo04.png)

### 6.2 Distribucion de bloques y replicas

### 6.3 Falla del DataNode

### 6.4 Estado durante la falla

### 6.5 Recuperacion

### 6.6 Analisis

## 7. Comparacion 1 GB vs 10 GB
Persona 2 y 3

## 8. Preguntas de analisis y exposicion
Personas 1, 2 y 3

## 9. Evidencias
Cada persona coloca las suyas.

## 10. Conclusion
Entre los tres.

## 11. Estructura del repositorio
Persona 1