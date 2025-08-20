FROM hub.oepkgs.net/openeuler/openeuler:22.03-lts-sp3

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone

ENV TZ=Asia/Shanghai
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0
ENV PATH=$PATH:$JAVA_HOME/bin

RUN  yum  -y install passwd shadow-utils wget net-tools vim perl which  nc zip unzip lsof bc hostname crontabs java-1.8.0-openjdk-devel && \
    wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.14.0/jmx_prometheus_javaagent-0.14.0.jar && mkdir -p /opt/jmx_exporter && mv  jmx_prometheus_javaagent-0.14.0.jar /opt/jmx_exporter/jmx_prometheus_javaagent-0.14.0.jar && \
    useradd -ms /bin/bash  hdfs  && \
    useradd -ms /bin/bash  yarn && \
    useradd -ms /bin/bash  hadoop && \
    useradd -ms /bin/bash  hive && \
    useradd -ms /bin/bash  spark && \
    useradd -ms /bin/bash  zookeeper && \
    useradd -ms /bin/bash  hbase && \
    useradd -ms /bin/bash  kyuubi  && \
    useradd -ms /bin/bash  doris  && \
    useradd -ms /bin/bash  flink  && \
    groupadd supergroup && \
    usermod  -aG supergroup  root && \
    usermod  -aG supergroup  hdfs && \
    usermod  -aG supergroup  yarn && \
    usermod  -aG supergroup  hadoop && \
    usermod  -aG supergroup  hive && \
    usermod  -aG supergroup  spark && \
    usermod  -aG supergroup  zookeeper && \
    usermod  -aG supergroup  hbase && \
    usermod  -aG supergroup  kyuubi && \
    usermod  -aG supergroup  doris && \
    usermod  -aG supergroup  flink && \
    echo 'root' |passwd --stdin root && \
    echo 'hdfs' |passwd --stdin hdfs && \
    echo 'yarn' |passwd --stdin yarn && \
    echo 'hadoop' |passwd --stdin hadoop && \
    echo 'hive' |passwd --stdin hive && \
    echo 'spark' |passwd --stdin spark && \
    echo 'zookeeper' |passwd --stdin zookeeper && \
    echo 'hbase' |passwd --stdin hbase && \
    echo 'kyuubi' |passwd --stdin kyuubi && \
    echo 'doris' |passwd --stdin doris && \
    echo 'flink' |passwd --stdin flink && \
    chmod  777 /home/*
