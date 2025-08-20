

docker build -f Dockerfile -t hadoop:3.3.4 .
docker tag  hadoop:3.3.4  registry.cn-hangzhou.aliyuncs.com/udh/hadoop:3.3.4
docker push registry.cn-hangzhou.aliyuncs.com/udh/hadoop:3.3.4

#docker tag  hadoop:3.3.4  registry.mufankong.top/udh/hadoop:3.3.4
#docker push  registry.mufankong.top/udh/hadoop:3.3.4



docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t harbor.trscd.com.cn/baseapp/udh-hadoop:3.3.4 --push .
