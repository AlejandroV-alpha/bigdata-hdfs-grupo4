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

Se utilizó el directorio correspondiente al Grupo 4:

```text
/grupo04/dataset_10GB
```

Se verificó que HDFS estuviera configurado con un factor de replicación igual a `2` mediante:

```bash
docker exec namenode hdfs getconf -confKey dfs.replication
```

El comando devolvió:

```text
2
```

Posteriormente, se creó directamente en HDFS un dataset de 10 GB con el nombre:

```text
/grupo04/dataset_10GB/dataset_grupo04_10GB
```

El archivo fue generado mediante:

```bash
docker exec namenode sh -c 'dd if=/dev/zero bs=1M count=10240 2>/dev/null | hdfs dfs -put - /grupo04/dataset_10GB/dataset_grupo04_10GB'
```

Se comprobó su existencia y tamaño mediante:

```bash
docker exec namenode hdfs dfs -ls -h /grupo04/dataset_10GB
```

El resultado confirmó un tamaño de **10 GB** y un factor de replicación de **2**.

Para analizar la distribución de bloques y réplicas se utilizó:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_10GB/dataset_grupo04_10GB -files -blocks -locations
```

El análisis mostró los siguientes resultados:

- Tamaño del archivo: **10 GB**
- Número total de bloques: **80**
- Tamaño promedio por bloque: **128 MB**
- Factor de replicación: **2**
- Promedio de replicación: **2.0**
- DataNodes activos: **3**
- Bloques subreplicados: **0**
- Bloques perdidos: **0**
- Bloques corruptos: **0**
- Estado del sistema de archivos: **HEALTHY**

Cada bloque del archivo posee dos réplicas distribuidas entre los tres DataNodes del clúster. Esto permite que el archivo continúe disponible aunque uno de los DataNodes falle.

#### Evidencias

Directorio HDFS correspondiente al Grupo 4:

![Directorio HDFS Grupo 4](evidencias/grupo04/dataset_10GB/04_directorio_hdfs_grupo04.png)

Factor de replicación configurado:

![Factor de replicacion](evidencias/grupo04/dataset_10GB/05_factor_replicacion_grupo04.png)

Dataset de 10 GB creado en HDFS:

![Dataset 10 GB](evidencias/grupo04/dataset_10GB/06_dataset_10GB_creado_grupo04.png)

Distribución inicial de bloques y réplicas:

![Distribucion inicial de bloques](evidencias/grupo04/dataset_10GB/07_distribucion_bloques_inicial_grupo04.png)

Resumen inicial de HDFS:

![Resumen inicial FSCK](evidencias/grupo04/dataset_10GB/08_fsck_resumen_inicial_grupo04.png)

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
