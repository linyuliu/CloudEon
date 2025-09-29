#!/bin/bash

# Priority build script for jdk8_ubuntu image
# Usage: ./build-jdk8-ubuntu.sh

set -e

REGISTRY=${REGISTRY:-ccr.ccs.tencentyun.com/cloudeon}
DOCKER_PASSWORD=${DOCKER_PASSWORD:-qwer123.}
BASE_DIR="/home/runner/work/CloudEon/CloudEon/cloudeon-stack/EDP-2.0.0"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Setup buildx for multi-platform
setup_buildx() {
    log "Setting up Docker Buildx for multi-platform builds"
    docker buildx create --use --name jdk8-ubuntu-builder \
      --driver docker-container 2>/dev/null || true
}

# Login to registry
login_registry() {
    log "Logging into Tencent Cloud Container Registry"
    echo "${DOCKER_PASSWORD}" | docker login ccr.ccs.tencentyun.com --username=100014663870 --password-stdin
}

# Build jdk8_ubuntu with priority
build_jdk8_ubuntu() {
    log "🚀 PRIORITY BUILD: JDK 8 Ubuntu Multi-Architecture Image"
    local base_path="$BASE_DIR/base"
    
    if [ ! -d "$base_path" ]; then
        error "Base directory $base_path not found"
        return 1
    fi
    
    log "Building JDK 8 Ubuntu with tag jdk:8-ubuntu"
    cd "$base_path"
    
    # Build for both platforms
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -f Dockerfile_ubuntu_jdk8 \
        -t "$REGISTRY/jdk:8-ubuntu" \
        --push .
    
    if [ $? -eq 0 ]; then
        log "✅ Successfully built and pushed JDK 8 Ubuntu multi-arch image"
        log "Image: $REGISTRY/jdk:8-ubuntu"
        log "Platforms: linux/amd64, linux/arm64"
    else
        error "❌ Failed to build JDK 8 Ubuntu image"
        return 1
    fi
}

# Test built image
test_image() {
    log "Testing built image locally (amd64 only)"
    
    # Pull and test the image
    docker pull --platform linux/amd64 "$REGISTRY/jdk:8-ubuntu" || {
        warn "Could not pull from registry, testing local build instead"
        docker buildx build \
            --platform linux/amd64 \
            -f Dockerfile_ubuntu_jdk8 \
            -t test-jdk8-ubuntu \
            --load .
        
        log "Testing Java version:"
        docker run --rm test-jdk8-ubuntu java -version
        
        log "Testing JAVA_HOME environment:"
        docker run --rm test-jdk8-ubuntu bash -c 'source /etc/environment && echo "JAVA_HOME: $JAVA_HOME"'
        return
    }
    
    log "Testing Java version:"
    docker run --rm "$REGISTRY/jdk:8-ubuntu" java -version
    
    log "Testing JAVA_HOME environment:"
    docker run --rm "$REGISTRY/jdk:8-ubuntu" bash -c 'source /etc/environment && echo "JAVA_HOME: $JAVA_HOME"'
}

main() {
    log "🎯 JDK 8 Ubuntu Priority Build Script"
    log "Registry: $REGISTRY"
    log "Target: jdk:8-ubuntu"
    log "Platforms: linux/amd64, linux/arm64"
    echo
    
    setup_buildx
    login_registry
    build_jdk8_ubuntu
    test_image
    
    log "🎉 JDK 8 Ubuntu build process completed!"
    log "You can now use: docker pull $REGISTRY/jdk:8-ubuntu"
}

main "$@"