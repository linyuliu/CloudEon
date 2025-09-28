#!/bin/bash

docker pull rancher/helm-controller:v0.16.5
docker tag rancher/helm-controller:v0.16.5 ccr.ccs.tencentyun.com/cloudeon/helm-controller:v0.16.5

docker pull rancher/klipper-helm:v0.9.3-build20241008
docker tag rancher/klipper-helm:v0.9.3-build20241008 ccr.ccs.tencentyun.com/cloudeon/helm-controller:klipper-helm-v0.9.3-build20241008

