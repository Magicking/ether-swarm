FROM alpine:3.4

ADD go-ethereum /go-ethereum
RUN \
  apk add --update go git make gcc musl-dev perl && \
  ( cd /go-ethereum && rm -rf .git && build/env.sh go run build/ci.go install ./cmd/bootnode ) && \
  cp /go-ethereum/build/bin/bootnode /bootnode && \
  apk del go git make gcc musl-dev && \
  rm -rf /go-ethereum && \
  rm -rf /var/cache/apk/*

EXPOSE 30303

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
