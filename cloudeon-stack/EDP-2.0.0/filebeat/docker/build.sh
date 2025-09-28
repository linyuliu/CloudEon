#!/bin/bash

docker pull docker.elastic.co/beats/filebeat:7.16.3
docker tag docker.elastic.co/beats/filebeat:7.16.3  ccr.ccs.tencentyun.com/cloudeon/filebeat:7.16.3

