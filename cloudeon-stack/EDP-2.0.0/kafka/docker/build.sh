#!/bin/bash

# Login to Tencent Cloud Registry
echo "${DOCKER_PASSWORD:-qwer123.}" | docker login hkccr.ccs.tencentyun.com --username=100014663870 --password-stdin

# Create multi-platform builder  
docker buildx create --use --name multi-platform-builder \
  --driver docker-container 2>/dev/null || true

# Build and push multi-platform Kafka image
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t hkccr.ccs.tencentyun.com/cloudeon/kafka:2.8.2 --push .
