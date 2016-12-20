FROM alpine:3.4

ADD go-ethereum /go-ethereum
RUN \
  apk add --update go git make gcc musl-dev perl && \
  ( cd /go-ethereum && rm -rf .git && make geth ) && \
  cp /go-ethereum/build/bin/geth /geth && \
  apk del go git make gcc musl-dev && \
  rm -rf /go-ethereum && \
  rm -rf /var/cache/apk/* 
# We should run the test

EXPOSE 8545
EXPOSE 8546
EXPOSE 30303

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
