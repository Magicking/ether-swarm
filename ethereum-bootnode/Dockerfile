FROM alpine:3.4

RUN \
  apk add --update go git make gcc musl-dev perl && \
  mkdir -pv /go/src/github.com/ethereum && \
  git clone --depth 1 https://github.com/ethereum/go-ethereum /go/src/github.com/ethereum/go-ethereum && \
 ( cd /go/src/github.com/ethereum/go-ethereum/ && \
  GOPATH=/go go get -v golang.org/x/net/context && \
  GOPATH=/go go build -o /bootnode ./cmd/bootnode/main.go ) && \
  apk del go git make gcc musl-dev && \
  rm -rf /go-ethereum && rm -rf /var/cache/apk/* 

EXPOSE 30303

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
