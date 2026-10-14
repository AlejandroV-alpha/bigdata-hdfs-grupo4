# Tolerancia a fallos y replicación de datos en HDFS

## 1. Objetivo

Implementar un entorno distribuido Hadoop HDFS compuesto por un NameNode y tres DataNodes, con un factor de replicación de 2, para analizar la tolerancia a fallos mediante pruebas con datasets de 1 GB y 10 GB.

El objetivo es comprobar cómo HDFS mantiene la disponibilidad de los archivos cuando uno de los DataNodes falla, identificar los bloques y réplicas afectados y verificar la recuperación automática de las réplicas después de la falla.

La práctica permite comparar el comportamiento del sistema antes, durante y después de la interrupción de un nodo, utilizando comandos de HDFS y evidencias obtenidas durante los experimentos.

## 2. Requerimientos

Para realizar la práctica se utilizaron los siguientes componentes y recursos:

| Requerimiento | Descripción |
|---|---|
| NameNode | Un nodo encargado de administrar los metadatos y la ubicación de los bloques. |
| DataNodes | Tres nodos encargados de almacenar los bloques y sus réplicas. |
| Factor de replicación | Dos copias por bloque. |
| Dataset 1 | Archivo de 1 GB para la primera prueba de tolerancia a fallos. |
| Dataset 2 | Archivo de 10 GB para la segunda prueba. |
| Plataforma | Hadoop 3.3.6 ejecutado mediante contenedores Docker. |
| Java | Java 11. |
| Configuración | Archivos XML de configuración de Hadoop y archivo `docker-compose.yml`. |
| Pruebas | Registro del estado inicial, caída de un DataNode, disponibilidad del archivo y recuperación de las réplicas. |
| Evidencias | Capturas de pantalla, resultados de comandos y archivos de registro almacenados en el repositorio. |

Los resultados se organizan por grupo y tamaño del dataset para facilitar la revisión y comparación de los experimentos.

## 3. Arquitectura e identificación del grupo

La implementación corresponde al **Grupo 4** y utiliza Docker para ejecutar un entorno Hadoop distribuido. El clúster está compuesto por un NameNode y tres DataNodes conectados mediante una red Docker compartida denominada `hadoop_network`.

El NameNode administra los metadatos, conoce la ubicación de los bloques y coordina la replicación. Los tres DataNodes almacenan físicamente los bloques de los archivos y sus réplicas.

También se incluyen componentes de YARN para la administración de recursos y la ejecución de trabajos distribuidos.

Los datasets utilizados se identifican mediante los siguientes directorios de HDFS:

- `/grupo04/dataset_1GB/`
- `/grupo04/dataset_10GB/`

El factor de replicación se establece en 2 mediante el archivo `conf/hdfs-site.xml`.

### 3.1 Componentes principales

| Componente | Función |
|---|---|
| NameNode | Administra los metadatos y la ubicación de los bloques. |
| DataNode 1 | Almacena bloques y réplicas. |
| DataNode 2 | Almacena bloques y réplicas. |
| DataNode 3 | Almacena bloques y réplicas. |
| ResourceManager | Administra los recursos de YARN. |
| NodeManager | Gestiona los recursos y las tareas del nodo de trabajo. |
| HistoryServer | Permite consultar el historial de trabajos. |

### 3.2 Diagrama de arquitectura

```mermaid
flowchart TB
    U["Cliente / usuario"]

    subgraph D["Entorno Docker: hadoop_network"]
        NN["NameNode<br/>Metadatos y ubicación de bloques"]
        DN1["DataNode 1<br/>Bloques y réplicas"]
        DN2["DataNode 2<br/>Bloques y réplicas"]
        DN3["DataNode 3<br/>Bloques y réplicas"]
        RM["ResourceManager<br/>Administración de recursos"]
        NM["NodeManager<br/>Gestión de tareas"]
        HS["HistoryServer<br/>Historial de trabajos"]
    end

    U --> NN
    NN <--> DN1
    NN <--> DN2
    NN <--> DN3
    RM --> NM
    NM --> DN1
    NM --> DN2
    NM --> DN3
    HS --> RM
```

### 3.3 Organización del proyecto

La estructura principal del repositorio es la siguiente:

```text
alejandrov-alpha-bigdata-hdfs-grupo4/
├── README.md
├── docker-compose.yml
├── Dockerfile
├── start-cluster.sh
├── conf/
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   ├── mapred-site.xml
│   └── yarn-site.xml
├── datanode/
├── historyserver/
├── namenode/
├── nodemanager/
├── resourcemanager/
├── scripts/
│   └── grupo04/
│       ├── dataset_1GB/
│       └── dataset_10GB/
└── evidencias/
    └── grupo04/
        ├── dataset_1GB/
        └── dataset_10GB/
```

## 4. Instalación y configuración

### 4.1 Requisitos previos

- Docker Desktop instalado y funcionando.
- Docker Compose disponible.
- Git para administrar el repositorio.
- Recursos suficientes de memoria y almacenamiento para ejecutar los contenedores y generar los datasets.

### 4.2 Configuración de Hadoop

La configuración del entorno se encuentra en la carpeta `conf/`:

- `core-site.xml`: define la dirección de acceso a HDFS mediante `hdfs://namenode:8020`.
- `hdfs-site.xml`: define los directorios de almacenamiento y el factor de replicación.
- `mapred-site.xml`: configura la ejecución de trabajos MapReduce mediante YARN.
- `yarn-site.xml`: configura los servicios y recursos de YARN.

En `conf/hdfs-site.xml` se establece el factor de replicación:

```xml
<property>
    <name>dfs.replication</name>
    <value>2</value>
</property>
```

Esto indica que HDFS debe mantener dos copias de cada bloque del archivo.

### 4.3 Inicio del entorno

Desde la carpeta raíz del proyecto, iniciar los servicios con:

```bash
docker compose up -d --build
```

Verificar el estado de los contenedores:

```bash
docker compose ps
```

Comprobar los DataNodes reconocidos por HDFS:

```bash
docker exec namenode hdfs dfsadmin -report
```

Consultar el factor de replicación:

```bash
docker exec namenode hdfs getconf -confKey dfs.replication
```

El resultado esperado es:

```text
2
```

### 4.4 Interfaces de administración

- NameNode: http://localhost:9870
- ResourceManager: http://localhost:8089
- HistoryServer: http://localhost:8188

Estas interfaces permiten consultar el estado de los servicios y apoyar la verificación del entorno.

---

## 5. Prueba de fallo: dataset de 1 GB

Las evidencias correspondientes a esta prueba se encuentran en:

```text
evidencias/grupo04/dataset_1GB/
```

### 5.1 Estado inicial

Antes de realizar la prueba de tolerancia a fallos, se verificó que el clúster Hadoop estuviera funcionando correctamente y que los tres DataNodes se encontraran activos.

Se utilizó el siguiente comando:

```bash
docker exec namenode hdfs dfsadmin -report
```

El clúster se encontraba operativo, con tres DataNodes activos y disponibles para almacenar bloques y sus respectivas réplicas.

También se verificó que HDFS tuviera configurado un factor de replicación igual a 2 mediante:

```bash
docker exec namenode hdfs getconf -confKey dfs.replication
```

El resultado fue `2`, lo que significa que HDFS debe mantener dos copias de cada bloque del archivo.

### 5.2 Distribución de bloques y réplicas

El dataset utilizado para la prueba fue `dataset_grupo04_1GB`, almacenado en el directorio de HDFS:

```text
/grupo04/dataset_1GB/dataset_grupo04_1GB
```

El archivo tiene un tamaño de 1.073.741.824 bytes y se encuentra dividido en 8 bloques de aproximadamente 128 MiB, con un factor de replicación de 2.

Para consultar la ubicación de los bloques y sus réplicas se ejecutó:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_1GB -files -blocks -locations
```

El resultado permitió identificar la distribución de los bloques entre los tres DataNodes del clúster:

- `datanode1`: `172.23.0.5`
- `datanode2`: `172.23.0.4`
- `datanode3`: `172.23.0.3`

Cada bloque tenía dos réplicas distribuidas entre los DataNodes. Esta redundancia permite que los datos sigan disponibles si uno de los nodos deja de funcionar, siempre que exista otra copia accesible de cada bloque.

### 5.3 Falla del DataNode

Para simular una falla se detuvo el contenedor `datanode2`, sin detener el NameNode ni los otros dos DataNodes.

Se utilizó el comando:

```bash
docker stop datanode2
```

La detención se realizó aproximadamente a las 12:40 a. m.

Después de detener el contenedor, HDFS necesitó un tiempo para detectar que el nodo había dejado de enviar sus señales de comunicación periódicas, conocidas como *heartbeats*.

Una vez detectada la falla, el NameNode marcó el DataNode como muerto. El reporte de HDFS registró dos DataNodes activos y uno muerto, confirmando que el clúster había detectado correctamente la pérdida del nodo.

Para verificar el estado de los nodos se ejecutó:

```bash
docker exec namenode hdfs dfsadmin -report
```

### 5.4 Estado durante la falla

Después de detener `datanode2`, se verificó el estado del archivo mediante:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_1GB -files -blocks -locations
```

También se comprobó que el archivo siguiera siendo legible mediante el cálculo de su hash MD5:

```bash
docker exec namenode bash -c "hdfs dfs -cat /grupo04/dataset_1GB/dataset_grupo04_1GB | md5sum"
```

El resultado obtenido fue:

```text
d4ee41e7d8325d7a30bce787b5257830
```

El hash coincidió con el valor original del archivo, lo que confirmó que los datos continuaban disponibles y podían leerse correctamente a pesar de la falla del DataNode.

Los bloques que tenían una réplica en `datanode2` conservaron su otra copia en alguno de los DataNodes que permanecieron activos. Por esta razón, la falla no provocó la pérdida del archivo.

**Observación:** el análisis `fsck` realizado aproximadamente a las 12:43 a. m. se efectuó cuando HDFS ya había recuperado las réplicas faltantes. Por ello, el estado temporal de subreplicación no quedó registrado en esa captura, aunque el proceso de recuperación sí se produjo.

### 5.5 Recuperación

Después de detectar que `datanode2` había dejado de funcionar, el NameNode identificó las réplicas que faltaban y comenzó automáticamente el proceso de replicación hacia los DataNodes disponibles.

Para comprobar el progreso de la recuperación se utilizó:

```bash
docker exec namenode hdfs dfsadmin -report
```

Se verificó el número de bloques subreplicados mediante el reporte y se observó que HDFS había recuperado las réplicas necesarias. El número de bloques subreplicados llegó a cero antes de transcurridos tres minutos desde la falla, según los registros de la prueba.

Posteriormente, se consultó nuevamente la ubicación de los bloques:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_1GB -files -blocks -locations
```

El resultado confirmó que el archivo se encontraba en estado `HEALTHY`, con los 8 bloques disponibles y un promedio de replicación de 2.0. Las nuevas réplicas quedaron distribuidas entre `datanode1` y `datanode3`.

Una vez comprobada la recuperación automática, se inició nuevamente el DataNode detenido:

```bash
docker start datanode2
```

Finalmente, se verificó que los tres DataNodes estuvieran activos y que el archivo continuara íntegro mediante un nuevo cálculo de su hash MD5.

### 5.6 Análisis

La prueba demostró que HDFS puede mantener la disponibilidad de los datos ante la falla de un DataNode. El dataset de 1 GB estaba dividido en 8 bloques, cada uno con dos réplicas.

Al detener `datanode2`, el archivo continuó accesible porque los bloques conservaban otras copias en los nodos activos. La verificación del MD5 confirmó que los datos se mantuvieron íntegros.

Finalmente, HDFS recuperó automáticamente las réplicas faltantes y, al reiniciar `datanode2`, el clúster volvió a contar con tres DataNodes activos.

Esto demuestra que la replicación permite proteger la información y mantener su disponibilidad ante fallos.

---

## 6. Prueba de fallo: dataset de 10 GB

Las evidencias correspondientes a esta prueba se encuentran en:

```text
evidencias/grupo04/dataset_10GB/
```

### 6.1 Estado inicial

Antes de realizar la prueba de fallo con el dataset de 10 GB, se verificó el estado del clúster Hadoop.

Mediante `docker compose ps` se comprobó que el NameNode y los tres DataNodes se encontraban activos y en estado `healthy`:

- NameNode: activo.
- DataNode1: activo.
- DataNode2: activo.
- DataNode3: activo.

Posteriormente, se verificó el estado directamente desde HDFS mediante:

```bash
docker exec namenode hdfs dfsadmin -report
```

El reporte confirmó la existencia de tres DataNodes activos:

```text
Live datanodes (3)
```

Los tres DataNodes presentaron estado normal (`Decommission Status: Normal`), por lo que el clúster se encontraba disponible para iniciar la prueba de tolerancia a fallos.

#### Evidencias

Estado inicial del clúster:

![Estado inicial del clúster](evidencias/grupo04/dataset_10GB/02_cluster_estado_inicial_grupo04.png)

DataNodes activos reconocidos por HDFS:

![DataNodes activos en HDFS](evidencias/grupo04/dataset_10GB/03_hdfs_datanodes_inicial_grupo04.png)

### 6.2 Distribución de bloques y réplicas

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

El resultado confirmó un tamaño de 10 GB y un factor de replicación de 2.

Para analizar la distribución de bloques y réplicas se utilizó:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_10GB/dataset_grupo04_10GB -files -blocks -locations
```

El análisis mostró los siguientes resultados:

- Tamaño del archivo: 10 GiB.
- Número total de bloques: 80.
- Tamaño por bloque: aproximadamente 128 MiB.
- Factor de replicación: 2.
- Promedio de replicación: 2.0.
- DataNodes activos: 3.
- Bloques subreplicados: 0.
- Bloques perdidos: 0.
- Bloques corruptos: 0.
- Estado del sistema de archivos: `HEALTHY`.

Cada bloque del archivo posee dos réplicas distribuidas entre los tres DataNodes del clúster. Esto permite que el archivo continúe disponible aunque uno de los DataNodes falle.

#### Evidencias

Directorio HDFS correspondiente al Grupo 4:

![Directorio HDFS Grupo 4](evidencias/grupo04/dataset_10GB/04_directorio_hdfs_grupo04.png)

Factor de replicación configurado:

![Factor de replicación](evidencias/grupo04/dataset_10GB/05_factor_replicacion_grupo04.png)

Dataset de 10 GB creado en HDFS:

![Dataset 10 GB](evidencias/grupo04/dataset_10GB/06_dataset_10GB_creado_grupo04.png)

Distribución inicial de bloques y réplicas:

![Distribución inicial de bloques](evidencias/grupo04/dataset_10GB/07_distribucion_bloques_inicial_grupo04.png)

Resumen inicial de HDFS:

![Resumen inicial FSCK](evidencias/grupo04/dataset_10GB/08_fsck_resumen_inicial_grupo04.png)

### 6.3 Falla del DataNode

Para simular una falla dentro del clúster se detuvo únicamente `datanode1`, manteniendo activos el NameNode, `datanode2` y `datanode3`.

Se utilizó el comando:

```bash
docker compose stop datanode1
```

Posteriormente, se verificó el estado de los contenedores mediante:

```bash
docker compose ps -a
```

El resultado mostró que `datanode1` se encontraba detenido, mientras que los otros dos DataNodes continuaban en estado `healthy`.

Después de esperar a que el NameNode detectara la ausencia de *heartbeats* del nodo detenido, se ejecutó:

```bash
docker exec namenode hdfs dfsadmin -report
```

HDFS reportó:

```text
Live datanodes (2)
Dead datanodes (1)
```

Esto confirmó que la caída de `datanode1` había sido detectada correctamente por HDFS.

#### Evidencias

DataNode1 detenido:

![DataNode1 detenido](evidencias/grupo04/dataset_10GB/09_datanode1_detenido_grupo04.png)

DataNode detectado como muerto por HDFS:

![DataNode muerto en HDFS](evidencias/grupo04/dataset_10GB/10_hdfs_datanode_muerto_grupo04.png)

### 6.4 Estado durante la falla

Con `datanode1` detenido se volvió a ejecutar el análisis del dataset:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_10GB/dataset_grupo04_10GB -files -blocks -locations
```

El resultado mostró:

- DataNodes activos: 2.
- Número total de bloques: 80.
- Bloques subreplicados: 50.
- Factor de replicación objetivo: 2.
- Promedio de replicación: 1.375.
- Réplicas faltantes: 50.
- Bloques perdidos: 0.
- Bloques corruptos: 0.
- Estado del archivo: `HEALTHY`.

Los bloques afectados continuaban disponibles, pero 50 de ellos poseían temporalmente una sola réplica viva.

Para varios bloques, HDFS indicó:

```text
Target Replicas is 2 but found 1 live replica(s)
```

A pesar de esta situación, ningún bloque se perdió.

Para comprobar que el dataset seguía siendo accesible durante la falla se ejecutó:

```bash
docker exec namenode sh -c 'hdfs dfs -cat /grupo04/dataset_10GB/dataset_grupo04_10GB | wc -c'
```

El resultado fue:

```text
10737418240
```

Esto confirmó que los 10 GiB del archivo pudieron ser leídos completamente aunque `datanode1` se encontrara detenido.

#### Evidencias

Bloques subreplicados durante la falla:

![Bloques subreplicados](evidencias/grupo04/dataset_10GB/11_bloques_subreplicados_grupo04.png)

Resumen de FSCK durante la falla:

![FSCK durante la falla](evidencias/grupo04/dataset_10GB/12_fsck_durante_falla_grupo04.png)

Dataset legible durante la falla:

![Dataset legible durante la falla](evidencias/grupo04/dataset_10GB/13_dataset_legible_durante_falla_grupo04.png)

### 6.5 Recuperación

Después de detectar la falla, HDFS inició automáticamente el proceso de recuperación de las réplicas faltantes utilizando los dos DataNodes que permanecían activos.

Se volvió a ejecutar:

```bash
docker exec namenode hdfs fsck /grupo04/dataset_10GB/dataset_grupo04_10GB -files -blocks -locations
```

En la primera medición durante la falla existían:

```text
Under-replicated blocks: 50
Average block replication: 1.375
Missing replicas: 50
```

Posteriormente, sin iniciar todavía `datanode1`, HDFS mostró:

```text
Under-replicated blocks: 0
Average block replication: 2.0
Missing replicas: 0
```

Esto demuestra que HDFS reconstruyó automáticamente las réplicas faltantes entre `datanode2` y `datanode3`, recuperando nuevamente el factor de replicación configurado en `2`.

La primera medición con bloques subreplicados se realizó aproximadamente a las `00:17:06 UTC`, mientras que a las `00:26:13 UTC` el proceso ya se encontraba finalizado.

Por lo tanto, la recuperación fue confirmada dentro de un intervalo de aproximadamente 9 minutos, aunque no se registró el instante exacto en el que finalizó.

Después de comprobar la recuperación automática se restauró `datanode1` mediante:

```bash
docker compose start datanode1
```

Posteriormente, `docker compose ps` confirmó que el nodo volvió a estado `healthy`.

Finalmente, se verificó nuevamente el clúster:

```bash
docker exec namenode hdfs dfsadmin -report
```

El resultado volvió a mostrar:

```text
Live datanodes (3)
```

Al regresar al clúster, `datanode1` apareció inicialmente con cero bloques. Esto ocurrió porque HDFS ya había reconstruido las réplicas necesarias en `datanode2` y `datanode3`, por lo que no necesitaba mover nuevamente los bloques al nodo recuperado para cumplir el factor de replicación.

#### Evidencias

Replicación recuperada automáticamente:

![Replicación recuperada](evidencias/grupo04/dataset_10GB/14_replicacion_recuperada_grupo04.png)

DataNode1 restaurado:

![DataNode1 restaurado](evidencias/grupo04/dataset_10GB/15_datanode1_restaurado_grupo04.png)

Tres DataNodes nuevamente activos:

![Tres DataNodes restaurados](evidencias/grupo04/dataset_10GB/16_hdfs_tres_datanodes_restaurados_grupo04.png)

### 6.6 Análisis

La prueba permitió observar el funcionamiento de la tolerancia a fallos de HDFS sobre un dataset de 10 GB.

Antes de la falla, el archivo estaba dividido en 80 bloques de aproximadamente 128 MiB, cada uno con un factor de replicación de 2 y distribuido entre tres DataNodes.

Al detener `datanode1`, HDFS detectó posteriormente la pérdida del nodo y el clúster pasó de tres a dos DataNodes activos.

Como consecuencia, 50 de los 80 bloques quedaron temporalmente subreplicados, debido a que una de sus dos copias se encontraba en el nodo detenido. Sin embargo:

- Ningún bloque se perdió.
- Ningún bloque quedó corrupto.
- El archivo continuó en estado `HEALTHY`.
- Los 10 GiB del dataset pudieron seguir siendo leídos completamente.

Posteriormente, HDFS utilizó las copias disponibles en los DataNodes supervivientes para crear nuevas réplicas. De esta forma, los bloques subreplicados pasaron de 50 a 0 y el promedio de replicación regresó de 1.375 a 2.0.

Cuando `datanode1` fue restaurado, HDFS volvió a reconocer tres DataNodes activos. Sin embargo, las réplicas del dataset ya habían sido reconstruidas en `datanode2` y `datanode3`, por lo que el nodo recuperado no necesitó recibir inmediatamente nuevamente los bloques.

La prueba demuestra que la replicación permite a HDFS mantener la disponibilidad de la información ante la falla de un DataNode y recuperar automáticamente el nivel de redundancia configurado.

#### Evidencia final

Estado final del dataset:

![Estado final del dataset](evidencias/grupo04/dataset_10GB/17_fsck_estado_final_grupo04.png)

El estado final mostró:

- DataNodes activos: 3.
- Bloques totales: 80.
- Bloques subreplicados: 0.
- Factor de replicación: 2.
- Promedio de replicación: 2.0.
- Bloques perdidos: 0.
- Réplicas faltantes: 0.
- Estado: `HEALTHY`.

---

## 7. Comparación: dataset de 1 GB vs. dataset de 10 GB

| Característica | Dataset 1 GB | Dataset 10 GB |
|---|---|---|
| Tamaño | 1 GiB | 10 GiB |
| Número de bloques | 8 | 80 |
| Factor de replicación | 2 | 2 |
| DataNode afectado | `datanode2` | `datanode1` |
| Bloques afectados | Los que tenían réplicas en `datanode2` | 50 bloques subreplicados |
| Bloques disponibles después de la falla | 8 de 8 | 80 de 80 |
| ¿Archivo accesible? | Sí | Sí |
| ¿Existieron bloques subreplicados? | Sí, temporalmente; no se capturó el número exacto | Sí, 50 |
| Tiempo de recuperación | Menos de 3 minutos, según los registros de la prueba | Recuperación confirmada dentro de un intervalo de aproximadamente 9 minutos |
| Nuevas réplicas | Redistribuidas entre `datanode1` y `datanode3` | Redistribuidas entre `datanode2` y `datanode3` |

### Análisis comparativo

La prueba de 1 GB permitió comprobar el funcionamiento básico de la replicación y la disponibilidad del archivo después de la caída de un DataNode. El archivo continuó siendo accesible y su integridad fue verificada mediante el hash MD5.

En la prueba de 10 GB, el número de bloques aumentó de 8 a 80. Esto permitió observar con mayor detalle el efecto de la falla: 50 bloques quedaron temporalmente subreplicados cuando se detuvo `datanode1`.

En ambos casos, el archivo continuó disponible porque cada bloque afectado conservaba al menos una réplica accesible. Posteriormente, HDFS recuperó las réplicas necesarias para restablecer el factor de replicación configurado en 2.

Los resultados muestran que HDFS puede mantener la disponibilidad de los datos ante la falla de un DataNode y recuperar automáticamente las réplicas faltantes, siempre que se conserve al menos una copia accesible de cada bloque.

---

## 8. Preguntas de análisis y exposición

### Pregunta 1. ¿Por qué HDFS puede continuar proporcionando el archivo aunque un DataNode haya fallado?

HDFS puede continuar proporcionando el archivo porque mantiene varias réplicas de cada bloque. En nuestra práctica, el factor de replicación configurado es 2. Por ello, cuando falla un DataNode, los bloques que tienen otra réplica en un nodo activo siguen disponibles para su lectura. En las pruebas realizadas, los archivos de 1 GB y 10 GB continuaron siendo accesibles durante la falla.

### Pregunta 2. ¿Qué habría ocurrido si el factor de replicación hubiera sido 1?

Si el factor de replicación hubiera sido 1, cada bloque tendría una sola copia. Si fallara el DataNode que almacena uno de esos bloques, dicho bloque dejaría de estar disponible mientras el nodo no pudiera proporcionar sus datos. Si no existiera otra copia recuperable, el archivo podría quedar incompleto o perderse, porque HDFS no tendría una réplica adicional para recuperar ese bloque.

### Pregunta 3. ¿Qué habría ocurrido si hubieran fallado dos DataNodes simultáneamente?

Si fallaran dos DataNodes simultáneamente, el archivo podría continuar disponible únicamente si todos sus bloques conservaran al menos una réplica accesible en el DataNode restante. Con un factor de replicación de 2, algunos bloques podrían quedar sin ninguna copia disponible si sus dos réplicas estuvieran distribuidas entre los nodos que fallaron. En ese caso, el archivo podría quedar inaccesible o incompleto. El resultado dependería de la distribución de las réplicas antes de las fallas.

### Pregunta 4. ¿Por qué un factor de replicación de 2 no significa necesariamente que existan dos copias completas del archivo en dos DataNodes?

Un factor de replicación de 2 significa que cada bloque del archivo debe tener dos copias, no que existan dos copias completas del archivo almacenadas en dos DataNodes diferentes.

Como HDFS divide los archivos en bloques y distribuye sus réplicas entre los nodos, un archivo puede estar repartido entre varios DataNodes. Por ejemplo, el dataset de 1 GB se dividió en 8 bloques, con 2 réplicas por bloque.

### Pregunta 5. ¿Cuál es la relación entre tamaño de bloque y número de bloques?

La relación entre el tamaño del bloque y el número de bloques es inversamente proporcional: cuanto mayor sea el tamaño del bloque, menor será la cantidad de bloques necesarios para almacenar un archivo, y viceversa.

En nuestras pruebas, con bloques de aproximadamente 128 MiB, el dataset de 1 GiB se dividió en 8 bloques, mientras que el de 10 GiB se dividió en 80 bloques.

### Pregunta 6. ¿Por qué el dataset de 10 GB permite observar un comportamiento más representativo de un sistema distribuido que el dataset de 1 GB?

El dataset de 10 GB permite observar un comportamiento más representativo de un sistema distribuido porque contiene más bloques y, por tanto, permite analizar una mayor cantidad de réplicas distribuidas entre los DataNodes.

En la prueba, la falla de `datanode1` provocó que 50 bloques quedaran temporalmente subreplicados, aunque los 80 bloques siguieron disponibles y el archivo permaneció accesible. Esto permitió observar con mayor claridad la recuperación automática de las réplicas por parte de HDFS.

### Pregunta 7. ¿Qué sucede con los bloques que tenían una réplica en el DataNode que falló?

Cuando un DataNode falla, los bloques que tenían una réplica guardada en ese nodo pierden temporalmente una de sus copias y quedan subreplicados.

En nuestra prueba con el dataset de 10 GB, al detener `datanode1`, 50 de los 80 bloques quedaron con una sola réplica disponible. Aun así, el archivo se pudo seguir leyendo porque esos bloques todavía tenían otra copia en alguno de los DataNodes que seguían funcionando.

Después, HDFS detectó esa falta de réplicas y creó nuevas copias en los nodos disponibles hasta volver a cumplir el factor de replicación 2.

### Pregunta 8. ¿Quién administra la ubicación y replicación de los bloques: el cliente, el DataNode o el NameNode?

El encargado es el `NameNode`.

El NameNode mantiene la información sobre qué bloques forman cada archivo, en qué DataNodes están guardados y cuántas réplicas existen de cada uno.

Los DataNodes son los que almacenan físicamente los bloques, pero las decisiones sobre su ubicación y replicación son administradas por el NameNode.

### Pregunta 9. ¿Qué diferencia existe entre disponibilidad del archivo y cumplimiento del factor de replicación después de una falla?

La disponibilidad significa que el archivo todavía puede ser leído porque sigue existiendo al menos una copia disponible de cada bloque.

En cambio, cumplir el factor de replicación significa que cada bloque tiene la cantidad de copias configurada en HDFS.

En nuestra prueba, después de detener `datanode1`, el archivo seguía disponible, pero 50 bloques quedaron temporalmente con una sola réplica, aunque el factor configurado era 2.

Por eso, un archivo puede seguir disponible aunque, durante un tiempo, no se esté cumpliendo completamente el factor de replicación.

---

## 9. Evidencias

Las evidencias de la práctica se organizan por grupo y tamaño del dataset.

### 9.1 Evidencias del dataset de 1 GB

Ubicación:

```text
evidencias/grupo04/dataset_1GB/
```

Los archivos de evidencia registran el estado de HDFS antes, durante y después de la falla, además del monitoreo del proceso:

- `fsck_1GB_antes.txt`
- `fsck_1GB_durante.txt`
- `fsck_1GB_despues_falla.txt`
- `fsck_1GB_final.txt`
- `monitoreo_falla_1GB.txt`

Estas evidencias permiten revisar la distribución de los bloques, la disponibilidad del archivo, la recuperación de las réplicas y el estado final del sistema.

### 9.2 Evidencias del dataset de 10 GB

Ubicación:

```text
evidencias/grupo04/dataset_10GB/
```

En estas evidencias se registró el estado inicial del clúster, la distribución de bloques y réplicas, la caída de `datanode1`, la aparición de bloques subreplicados, la lectura completa del archivo durante la falla, la recuperación automática de las réplicas y el estado final del sistema.

### 9.3 Scripts utilizados

Los scripts para preparar los datasets, simular las fallas y recuperar los DataNodes se encuentran en:

```text
scripts/grupo04/dataset_1GB/
scripts/grupo04/dataset_10GB/
```

Para el dataset de 1 GB se incluyen los scripts de preparación, falla de `datanode2` y recuperación de `datanode2`.

Para el dataset de 10 GB se incluyen los scripts de preparación, falla de `datanode1` y recuperación de `datanode1`.

---

## 10. Conclusiones

### 10.1 Conclusión del dataset de 1 GB

La prueba con el dataset de 1 GB demostró que HDFS puede mantener los datos disponibles ante la falla de un DataNode gracias a la replicación. Aunque se detuvo `datanode2`, el archivo continuó siendo accesible y su integridad se verificó mediante el hash MD5.

Posteriormente, HDFS recuperó automáticamente las réplicas faltantes y el archivo volvió a estar en estado `HEALTHY`. Esto demuestra que la replicación ayuda a prevenir la pérdida de información y a mantener la disponibilidad de los datos ante fallos.

### 10.2 Conclusión del dataset de 10 GB

En la prueba realizada con el dataset de 10 GB se pudo comprobar que HDFS mantiene disponible la información incluso cuando uno de los DataNodes deja de funcionar, siempre que exista otra réplica de los bloques afectados.

Al detener `datanode1`, 50 de los 80 bloques quedaron temporalmente subreplicados. Sin embargo, ninguno de los bloques se perdió y el archivo continuó siendo accesible, por lo que fue posible leer los 10 GiB completos durante la falla.

También se observó que HDFS recuperó automáticamente las réplicas faltantes utilizando los DataNodes que permanecían activos. Después de este proceso, los bloques subreplicados volvieron a cero y el promedio de replicación regresó a 2.0.

Esta prueba permitió comprobar de forma práctica cómo la replicación de HDFS ayuda a mantener la disponibilidad de los datos y a recuperar automáticamente la redundancia cuando ocurre la falla de un DataNode.

### 10.3 Conclusión general

La práctica permitió comprobar el funcionamiento de la tolerancia a fallos y la replicación de datos en Hadoop HDFS mediante experimentos con datasets de 1 GB y 10 GB.

En ambos experimentos se observó que el archivo podía continuar disponible después de detener un DataNode, siempre que cada bloque afectado conservara otra réplica accesible. En el caso del dataset de 1 GB, la integridad se comprobó mediante el hash MD5. En el dataset de 10 GB, se verificó que los 80 bloques seguían disponibles y que era posible leer el archivo completo durante la falla.

También se comprobó que HDFS detecta la caída de un nodo e inicia la recuperación de las réplicas necesarias para alcanzar el factor de replicación configurado. En la prueba de 10 GB, los bloques subreplicados pasaron de 50 a cero y el promedio de replicación regresó a 2.0.

En conclusión, HDFS proporciona mecanismos para mantener la disponibilidad de los datos y recuperar la redundancia ante fallos de nodos. Sin embargo, la disponibilidad depende de que exista al menos una copia accesible de cada bloque.

La comparación entre los dos datasets permitió observar que un archivo de mayor tamaño contiene más bloques y permite analizar con mayor detalle la distribución de las réplicas y el proceso de recuperación del sistema.

---

## 11. Repositorio y entrega

El proyecto incluye los archivos de configuración de Hadoop, los contenedores definidos en `docker-compose.yml`, los scripts de prueba, las evidencias de los experimentos, el diagrama de arquitectura y el análisis de resultados.

Repositorio:

`alejandrov-alpha-bigdata-hdfs-grupo4`

Para registrar los cambios del README en Git, ejecutar desde la carpeta raíz del proyecto:

```bash
git add README.md
git commit -m "Completar README y diagrama de arquitectura"
git push
```
