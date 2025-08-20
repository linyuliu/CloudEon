
FROM harbor.trscd.com.cn/trs-police/udh-jdk:8

ARG BUILD_DATE
ARG CLOUDEON_VERSION=v1.3.0

ENV CLOUDEON_HOME	/usr/local/cloudeon

WORKDIR ${CLOUDEON_HOME}

# 时区
ENV TZ Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN mkdir -p ${CLOUDEON_HOME}

ADD target/cloudeon-assembly-v1.3.0-release.tar.gz .

RUN mv cloudeon-assembly-*   cloudeon-assembly

# 健康检查
HEALTHCHECK CMD curl -X GET -f http://localhost:7700 || exit 1

EXPOSE 7700


ENTRYPOINT ["/bin/bash", "/usr/local/cloudeon/cloudeon-assembly/bin/server.sh","start"]
