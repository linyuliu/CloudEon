# JDK 8 Ubuntu Docker Image - Priority Build

This document describes the optimized JDK 8 Ubuntu Docker image with multi-architecture support and improved environment variable handling.

## Quick Start - Priority Build

To build only the JDK 8 Ubuntu image with priority:

```bash
./build-jdk8-ubuntu.sh
```

This will build the multi-architecture image (`linux/amd64` and `linux/arm64`) and push it to the registry.

## Changes Made

### 🔧 Fixed Environment Variables
- **Dynamic JAVA_HOME Detection**: Now properly detects JAVA_HOME across architectures
- **Consistent Path Setup**: Creates symlink `/usr/lib/jvm/default-java` for reliable access
- **Multi-arch Support**: Works correctly on both AMD64 and ARM64 platforms

### 🚀 Removed Source Switching
- **Single Package Installation**: Consolidated all `apt-get` commands into one RUN statement
- **Mirror Optimization**: Uses faster mirrors (Aliyun for x86_64, USTC for ARM64)
- **Reduced Layers**: Optimized Dockerfile structure for faster builds

### 🌐 Multi-Architecture Support
- **Fixed Repository Issues**: Proper mirror selection for different architectures
- **Certificate Handling**: Added `--no-check-certificate` for Maven downloads
- **ARM64 Compatibility**: Resolved connectivity issues with Ubuntu ports repository

## Build Scripts

### Priority Build Script: `build-jdk8-ubuntu.sh`
Builds only the JDK 8 Ubuntu image with priority:
- Multi-platform build (amd64 + arm64)
- Automatic testing and verification
- Detailed logging and error handling

### Full Build Script: `build-all.sh`
Builds all components with JDK 8 Ubuntu first:
```bash
./build-all.sh base    # Build all base images (JDK 8 Ubuntu first)
./build-all.sh all     # Build everything (JDK 8 Ubuntu prioritized)
```

## Image Details

- **Registry**: `ccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu`
- **Base**: Ubuntu 22.04
- **Java**: OpenJDK 8
- **Platforms**: linux/amd64, linux/arm64
- **Features**: 
  - Multi-arch JAVA_HOME detection
  - JMX monitoring support
  - MySQL client included
  - Chinese timezone (Asia/Shanghai)

## Environment Variables

The image properly sets up the following environment variables:

```bash
TZ=Asia/Shanghai
JAVA_HOME=/usr/lib/jvm/default-java  # Symlinked to actual JDK path
PATH=$JAVA_HOME/bin:$PATH
FREEMARKER_GENERATOR_CLI_HOME=/opt/freemarker-generator-cli
```

## Usage

Pull and run the image:

```bash
# Pull the multi-arch image
docker pull ccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu

# Run with Java version check
docker run --rm ccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu java -version

# Run with environment check
docker run --rm ccr.ccs.tencentyun.com/cloudeon/jdk:8-ubuntu bash -c 'source /etc/environment && echo "JAVA_HOME: $JAVA_HOME"'
```

## Testing

The build script includes automatic testing:

1. **Build Verification**: Confirms successful multi-platform build
2. **Java Version Check**: Verifies OpenJDK 8 installation
3. **Environment Test**: Confirms JAVA_HOME is properly set
4. **Cross-platform**: Tests both AMD64 and ARM64 (when available)

## Troubleshooting

### Network Issues
If you encounter network connectivity issues:
- The script automatically handles registry login
- Uses reliable mirrors for package installation
- Includes certificate bypass for Maven downloads

### Architecture Issues
- JAVA_HOME is detected dynamically for each platform
- Symlinks provide consistent access paths
- Multi-platform buildx is automatically configured

## Migration Notes

This optimized version addresses the following issues from the original:

1. ❌ **Old**: Multiple `apt-get update` calls (source switching)
   ✅ **New**: Single consolidated package installation

2. ❌ **Old**: Hardcoded JAVA_HOME paths
   ✅ **New**: Dynamic detection with architecture support

3. ❌ **Old**: Repository connectivity issues on ARM64
   ✅ **New**: Optimized mirrors for better reliability

4. ❌ **Old**: No priority build option
   ✅ **New**: Dedicated priority build script