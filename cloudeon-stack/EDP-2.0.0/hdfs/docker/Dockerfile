FROM hkccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu

ARG TARGETARCH
ENV HADOOP_HOME=/opt/hadoop \
    HADOOP_VERSION=3.3.6

RUN set -eux; \
    if [ "$TARGETARCH" = "arm64" ]; then \
        HADOOP_PKG=hadoop-${HADOOP_VERSION}-aarch64.tar.gz; \
    else \
        HADOOP_PKG=hadoop-${HADOOP_VERSION}.tar.gz; \
    fi; \
    wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/$HADOOP_PKG && \
    tar -zxvf $HADOOP_PKG -C /opt && \
    rm -f $HADOOP_PKG && \
    mv /opt/hadoop-* ${HADOOP_HOME}

WORKDIR $HADOOP_HOME
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
