# Base Java 11
FROM eclipse-temurin:11-jdk AS jdk

# Python 3.11 sobre Debian Bookworm para mayor estabilidad
FROM python:3.11-bookworm

USER root

# --------------------------------------------------------
# DEPENDENCIAS DEL SISTEMA
# --------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    perl \
    tar \
    gzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------
# JAVA
# --------------------------------------------------------
ENV JAVA_HOME=/opt/java/openjdk

COPY --from=jdk /opt/java/openjdk /opt/java/openjdk

# --------------------------------------------------------
# HADOOP
# --------------------------------------------------------
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_URL=https://downloads.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH=$HADOOP_HOME/bin/:$PATH

RUN set -x \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz*

RUN ln -s $HADOOP_HOME/etc/hadoop /etc/hadoop
RUN mkdir -p $HADOOP_HOME/logs
RUN mkdir -p /hadoop-data

# --------------------------------------------------------
# CONFIGURACION HADOOP
# --------------------------------------------------------
COPY conf/core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY conf/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY conf/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml
COPY conf/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml