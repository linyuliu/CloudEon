#!/bin/bash

# Login to Tencent Cloud Registry
echo "${DOCKER_PASSWORD:-qwer123.}" | docker login ccr.ccs.tencentyun.com --username=100014663870 --password-stdin

# Create multi-platform builder  
docker buildx create --use --name multi-platform-builder \
  --driver docker-container 2>/dev/null || true

# Build and push multi-platform SeaTunnel images
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t ccr.ccs.tencentyun.com/cloudeon/seatunnel:2.3.7 --push .

docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile_web -t ccr.ccs.tencentyun.com/cloudeon/seatunnel-web:1.0.1 --push .
