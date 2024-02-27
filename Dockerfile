# Build go
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /etc/XrayR/ \
    && apk add wget \
    && wget -q -O /etc/XrayR/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat \
    && wget -q -O /etc/XrayR/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
COPY --from=builder /app/XrayR /usr/local/bin

ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/config.yml"]
