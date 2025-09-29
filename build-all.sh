#!/bin/bash

# Master build script for CloudEon multi-platform Docker images
# Usage: ./build-all.sh [component|all]
# Examples:
#   ./build-all.sh all        # Build all components
#   ./build-all.sh base       # Build only base images
#   ./build-all.sh hadoop     # Build only Hadoop
#   ./build-all.sh spark      # Build only Spark

set -e

COMPONENT=${1:-all}
REGISTRY=${REGISTRY:-hkccr.ccs.tencentyun.com/cloudeon}
DOCKER_PASSWORD=${DOCKER_PASSWORD:-qwer123.}

BASE_DIR="/home/runner/work/CloudEon/CloudEon/cloudeon-stack/EDP-2.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

setup_buildx() {
    log "Setting up Docker Buildx for multi-platform builds"
    docker buildx create --use --name multi-platform-builder \
      --driver docker-container 2>/dev/null || true
}

login_registry() {
    log "Logging into Tencent Cloud Container Registry"
    echo "${DOCKER_PASSWORD}" | docker login hkccr.ccs.tencentyun.com --username=100014663870 --password-stdin
}

build_component() {
    local component=$1
    local path=$2
    local tag=$3
    local dockerfile=${4:-Dockerfile}
    
    if [ ! -d "$path" ]; then
        error "Component directory $path not found"
        return 1
    fi
    
    log "Building $component with tag $tag"
    cd "$path"
    
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -f "$dockerfile" \
        -t "$REGISTRY/$tag" \
        --push .
    
    if [ $? -eq 0 ]; then
        log "Successfully built and pushed $component"
    else
        error "Failed to build $component"
        return 1
    fi
}

build_base() {
    log "Building base JDK images"
    local base_path="$BASE_DIR/base"
    
    build_component "JDK 8 Ubuntu" "$base_path" "jdk:8-ubuntu" "Dockerfile_ubuntu_jdk8"
    build_component "JDK Latest" "$base_path" "jdk:latest" "Dockerfile"  
    build_component "JDK 17" "$base_path" "jdk:17" "DockerfileJdk17"
}

build_hadoop() {
    log "Building Hadoop image"
    build_component "Hadoop" "$BASE_DIR/hdfs/docker" "hadoop:3.3.6"
}

build_bigdata_components() {
    log "Building big data components"
    
    # Components that depend on Hadoop
    local hadoop_components=(
        "spark:spark:3.2.3"
        "hbase:hbase:2.4.16"
        "hive:hive:3.1.3"
        "flink:flink:1.15.4"
        "dolphinscheduler:dolphinscheduler:3.1.9"
    )
    
    # Components that depend on JDK only
    local jdk_components=(
        "kafka:kafka:2.8.2"
        "zookeeper:zookeeper:3.7.1"
        "elasticsearch:elasticsearch:7.17.15"
        "trino:trino:424"
    )
    
    for comp in "${hadoop_components[@]}"; do
        IFS=':' read -r dir name version <<< "$comp"
        build_component "$name" "$BASE_DIR/$dir/docker" "$name:$version" || warn "Failed to build $name"
    done
    
    for comp in "${jdk_components[@]}"; do
        IFS=':' read -r dir name version <<< "$comp"
        build_component "$name" "$BASE_DIR/$dir/docker" "$name:$version" || warn "Failed to build $name"
    done
    
    # Special cases
    build_component "Kyuubi" "$BASE_DIR/kyuubi/docker" "kyuubi:1.7.0" || warn "Failed to build Kyuubi"
    build_component "SeaTunnel" "$BASE_DIR/seatunnel/docker" "seatunnel:2.3.7" || warn "Failed to build SeaTunnel"
    build_component "Doris" "$BASE_DIR/doris/docker" "doris:2.1.8.1" || warn "Failed to build Doris"
}

main() {
    log "Starting CloudEon multi-platform build process"
    log "Component: $COMPONENT"
    log "Registry: $REGISTRY"
    
    setup_buildx
    login_registry
    
    case "$COMPONENT" in
        "base")
            build_base
            ;;
        "hadoop"|"hdfs")
            build_hadoop
            ;;
        "spark")
            build_component "Spark" "$BASE_DIR/spark/docker" "spark:3.2.3"
            ;;
        "hbase")
            build_component "HBase" "$BASE_DIR/hbase/docker" "hbase:2.4.16"
            ;;
        "kafka")
            build_component "Kafka" "$BASE_DIR/kafka/docker" "kafka:2.8.2"
            ;;
        "zookeeper")
            build_component "ZooKeeper" "$BASE_DIR/zookeeper/docker" "zookeeper:3.7.1"
            ;;
        "hive")
            build_component "Hive" "$BASE_DIR/hive/docker" "hive:3.1.3"
            ;;
        "flink")
            build_component "Flink" "$BASE_DIR/flink/docker" "flink:1.15.4"
            ;;
        "all")
            log "Building all components in dependency order"
            build_base
            sleep 30  # Allow base images to be available
            build_hadoop  
            sleep 30  # Allow Hadoop image to be available
            build_bigdata_components
            ;;
        *)
            error "Unknown component: $COMPONENT"
            echo "Available components: all, base, hadoop, spark, hbase, hive, flink, kafka, zookeeper"
            exit 1
            ;;
    esac
    
    log "Build process completed!"
}

main "$@"