# CloudEon Multi-Platform Docker Build Migration

This document describes the migration from Alibaba Cloud registry to Tencent Cloud private registry with multi-platform support (AMD64 + ARM64).

## Overview

### Changes Made

1. **Registry Migration**: All Docker images now use `ccr.ccs.tencentyun.com/cloudeon` instead of `registry.cn-guangzhou.aliyuncs.com/bigdata200`
2. **Multi-Platform Support**: All builds now support both `linux/amd64` and `linux/arm64` architectures  
3. **Hadoop Version Update**: Upgraded from Hadoop 3.3.4 to 3.3.6 for ARM64 compatibility
4. **Automated CI/CD**: Added GitHub Actions workflow for automated builds
5. **Master Build Script**: Created unified build script for all components

### Registry Details

- **Registry**: `ccr.ccs.tencentyun.com/cloudeon`  
- **Username**: `100014663870`
- **Password**: Set via `DOCKER_PASSWORD` environment variable (default: `qwer123.`)

## Quick Start

### 1. Set Environment Variables

```bash
export DOCKER_PASSWORD="qwer123."
```

### 2. Build All Components

```bash
# Build all components in dependency order
./build-all.sh all

# Build specific component
./build-all.sh base     # Build base JDK images
./build-all.sh hadoop   # Build Hadoop
./build-all.sh spark    # Build Spark
```

### 3. Using GitHub Actions

The repository now includes automated CI/CD pipeline that triggers on:
- Push to `dev2.0` branch with changes in `cloudeon-stack/EDP-2.0.0/**/docker/**`
- Manual workflow dispatch
- Pull requests

## Component Details

### Base Images

| Component | Registry Tag | Platforms | Description |
|-----------|-------------|-----------|-------------|
| JDK 8 Ubuntu | `ccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu` | amd64, arm64 | Ubuntu 22.04 + OpenJDK 8 |
| JDK Latest | `ccr.ccs.tencentyun.com/cloudeon/jdk:latest` | amd64, arm64 | OpenEuler 24.03 + OpenJDK 8 |
| JDK 17 | `ccr.ccs.tencentyun.com/cloudeon/jdk:17` | amd64, arm64 | OpenEuler + OpenJDK 17 |

### Big Data Components  

| Component | Registry Tag | Version | Platforms | Base Image |
|-----------|-------------|---------|-----------|------------|
| Hadoop | `ccr.ccs.tencentyun.com/cloudeon/hadoop:3.3.6` | 3.3.6 | amd64, arm64 | jdk:latest |
| Spark | `ccr.ccs.tencentyun.com/cloudeon/spark:3.2.3` | 3.2.3 | amd64, arm64 | hadoop:3.3.6 |
| HBase | `ccr.ccs.tencentyun.com/cloudeon/hbase:2.4.16` | 2.4.16 | amd64, arm64 | hadoop:3.3.6 |
| Hive | `ccr.ccs.tencentyun.com/cloudeon/hive:3.1.3` | 3.1.3 | amd64, arm64 | hadoop:3.3.6 |
| Flink | `ccr.ccs.tencentyun.com/cloudeon/flink:1.15.4` | 1.15.4 | amd64, arm64 | hadoop:3.3.6 |
| Kafka | `ccr.ccs.tencentyun.com/cloudeon/kafka:2.8.2` | 2.8.2 | amd64, arm64 | jdk:latest |
| ZooKeeper | `ccr.ccs.tencentyun.com/cloudeon/zookeeper:3.7.1` | 3.7.1 | amd64, arm64 | jdk:latest |
| Trino | `ccr.ccs.tencentyun.com/cloudeon/trino:424` | 424 | amd64, arm64 | jdk:17 |

### Special Cases

#### Doris
- **Standard**: `ccr.ccs.tencentyun.com/cloudeon/doris:2.1.8.1` (amd64, arm64)
- **No AVX2**: `ccr.ccs.tencentyun.com/cloudeon/doris:2.1.8.1-noavx2` (amd64 only)

#### SeaTunnel  
- **Core**: `ccr.ccs.tencentyun.com/cloudeon/seatunnel:2.3.7`
- **Web**: `ccr.ccs.tencentyun.com/cloudeon/seatunnel-web:1.0.1`

## Build Process

### Dependencies

The build process follows this dependency order:

1. **Base Images** (`jdk:8-ubuntu`, `jdk:latest`, `jdk:17`)
2. **Hadoop** (`hadoop:3.3.6`) - depends on `jdk:latest`  
3. **Hadoop-based components** - depend on `hadoop:3.3.6`
4. **JDK-only components** - depend on base JDK images

### Individual Component Builds

Each component has its own `build.sh` script in its docker directory:

```bash
cd cloudeon-stack/EDP-2.0.0/spark/docker
./build.sh
```

All build scripts include:
- Registry login with environment variable support
- Multi-platform buildx setup  
- Platform-aware builds (linux/amd64,linux/arm64)

## Architecture-Specific Considerations

### ARM64 Support
- **Hadoop 3.3.6**: First version with official ARM64 support (upgraded from 3.3.4)
- **Java Paths**: Fixed hardcoded amd64 paths to use `$(dpkg --print-architecture)`
- **Doris NOAVX2**: Limited to amd64 only (AVX2 is x86-specific)

### Known Limitations
1. Doris NOAVX2 variant only supports amd64 (AVX2 instruction set is x86-specific)
2. Some components may have longer build times on ARM64
3. Cross-platform builds require Docker Buildx

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   ```bash
   export DOCKER_PASSWORD="your-password"
   echo "$DOCKER_PASSWORD" | docker login ccr.ccs.tencentyun.com --username=100014663870 --password-stdin
   ```

2. **Buildx Not Available**  
   ```bash
   docker buildx create --use --name multi-platform-builder --driver docker-container
   ```

3. **Platform Not Supported**
   - Check if the base image supports your target platform
   - Some images may be amd64-only due to upstream limitations

### Debug Commands

```bash
# Check available builders
docker buildx ls

# Inspect multi-platform image
docker buildx imagetools inspect ccr.ccs.tencentyun.com/cloudeon/hadoop:3.3.6

# Test cross-platform locally
docker run --rm --platform linux/arm64 ccr.ccs.tencentyun.com/cloudeon/jdk:latest java -version
```

## Migration Notes

### Breaking Changes
- Registry URLs changed from `registry.cn-guangzhou.aliyuncs.com/bigdata200` to `ccr.ccs.tencentyun.com/cloudeon`
- Hadoop version upgraded from 3.3.4 to 3.3.6
- All builds now require Docker Buildx

### Compatibility
- Images maintain the same functionality and API
- Version tags remain the same for most components
- Environment variables and configurations unchanged

## GitHub Actions Workflow

The automated CI/CD pipeline includes:

- **Path-based triggers**: Only builds changed components
- **Dependency management**: Builds base images first
- **Multi-platform builds**: Uses GitHub-hosted runners with Buildx
- **Caching**: Leverages GitHub Actions cache for faster builds
- **Manual triggers**: Supports building specific components

### Secrets Required

Add these secrets to your GitHub repository:

- `DOCKER_PASSWORD`: Tencent Cloud Container Registry password

## Next Steps

1. **Test Builds**: Validate multi-platform images work correctly
2. **Update Documentation**: Update deployment guides with new registry URLs
3. **Monitoring**: Set up monitoring for automated builds
4. **Security**: Consider using token-based authentication instead of password