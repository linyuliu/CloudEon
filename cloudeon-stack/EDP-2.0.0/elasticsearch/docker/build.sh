#!/bin/bash

docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t ccr.ccs.tencentyun.com/cloudeon/elasticsearch:7.16.3 --push .

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag ccr.ccs.tencentyun.com/cloudeon/elasticsearch_exporter:v1.7.0 \
  --output type=image,push=true \
  --set "buildkitd.dns=8.8.8.8" \
  - <<EOF
FROM prometheuscommunity/elasticsearch-exporter:v1.7.0
EOF
