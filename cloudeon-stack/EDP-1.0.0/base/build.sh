docker buildx create --use --name multi-platform-builder \
  --driver docker-container \
  --driver-opt '"env.no_proxy=localhost,127.0.0.1,registry.cn-guangzhou.aliyuncs.com"'

docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t c --push .
