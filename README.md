# Build
```
docker build -t chnchenjie/highcharts-export-server-v4 .
```

# Run
```
docker run -d -p 8080:8080/tcp \
    --cap-add=SYS_ADMIN \
    --name highcharts-export-server-v4 \
    chnchenjie/highcharts-export-server-v4
```
or
```
docker-compose up --build
```

# [Dockerfile](https://github.com/highcharts/node-export-server/issues/527#issuecomment-2288880160)
```
# building on https://github.com/puppeteer/puppeteer/blob/main/docker/Dockerfile
FROM ghcr.io/puppeteer/puppeteer:23.0.2

ENV HIGHCHARTS_VERSION="11.4.7"

USER root 
RUN npm install highcharts-export-server@4.0.2 -g 

WORKDIR /

EXPOSE 8080
ENTRYPOINT ["highcharts-export-server", "--enableServer", "1", "--port", "8080"]
```