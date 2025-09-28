#!/bin/bash

# Login to Tencent Cloud Registry
echo "${DOCKER_PASSWORD:-qwer123.}" | docker login ccr.ccs.tencentyun.com --username=100014663870 --password-stdin

# Create multi-platform builder  
docker buildx create --use --name multi-platform-builder \
  --driver docker-container 2>/dev/null || true

# Check if machine supports AVX2 instruction set
echo "Checking AVX2 support..."
cat /proc/cpuinfo | grep avx2

echo "Building standard Doris image with AVX2 support (AMD64+ARM64)"
# Build standard Doris with AVX2 support for both architectures
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t ccr.ccs.tencentyun.com/cloudeon/doris:2.1.8.1 --push .

echo "Building Doris NOAVX2 image (AMD64 only)"
# Build Doris without AVX2 support - only for x86 architecture  
docker buildx build --platform linux/amd64 --build-arg NOAVX2='NOAVX2' -f Dockerfile -t ccr.ccs.tencentyun.com/cloudeon/doris:2.1.8.1-noavx2 --push .
