FROM golang:1.22-alpine as builder
WORKDIR /app
COPY main.go go.mod go.sum ./
RUN set -ex \
    && apk add --no-cache --virtual .build-deps gcc libc-dev \
    && go build --ldflags '-extldflags "-static"' -o docker-volume-sshfs \
    && apk del .build-deps

FROM alpine:3.20.2
RUN apk update && apk add sshfs
RUN mkdir -p /run/docker/plugins /mnt/state /mnt/volumes
COPY --from=builder /app/docker-volume-sshfs .
CMD ["docker-volume-sshfs"]
