FROM harbor.trscd.com.cn/trs-police/udh-jdk:8


USER hadoop

WORKDIR /home/hadoop/

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz && tar -zxvf hadoop-3.3.4.tar.gz -C /home/hadoop/ \
    && rm -f hadoop-3.3.4.tar.gz && mv hadoop-3.3.4  apache-hadoop


ENV HADOOP_HOME=/home/hadoop/apache-hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin







