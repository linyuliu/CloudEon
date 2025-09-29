FROM hkccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu

ARG HADOOP_VERSION=3.3.6
# Docker will automatically provide TARGETARCH: amd64 or arm64
ARG TARGETARCH

ENV HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    PATH=$PATH:/opt/hadoop/bin:/opt/hadoop/sbin

WORKDIR /opt

# Select Hadoop package based on architecture
RUN apt-get update && apt-get install -y wget tar gzip \
 && if [ "$TARGETARCH" = "arm64" ]; then \
        wget -O hadoop-${HADOOP_VERSION}.tar.gz \
          https://mirrors.huaweicloud.com/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}-aarch64.tar.gz ; \
    else \
        wget -O hadoop-${HADOOP_VERSION}.tar.gz \
          https://mirrors.huaweicloud.com/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz ; \
    fi \
 && tar -zxvf hadoop-${HADOOP_VERSION}.tar.gz \
 && mv hadoop-${HADOOP_VERSION}* ${HADOOP_HOME} \
 && rm -f hadoop-${HADOOP_VERSION}.tar.gz \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR $HADOOP_HOME