FROM alpine:3.4

ADD go-ethereum /go-ethereum
ADD eth-net-intelligence-api /usr/src/eth-net-intelligence-api
RUN \
  apk add --update go git make gcc musl-dev perl nodejs python curl && \
  ( cd /go-ethereum && rm -rf .git && make geth ) && \
  cp /go-ethereum/build/bin/geth /geth && \
  ( cd /usr/src/eth-net-intelligence-api && npm install && \
    npm install -g pm2 ) && \
  apk del go git make gcc musl-dev && \
  rm -rf /go-ethereum && \
  rm -rf /var/cache/apk/* 

COPY app.json /app.json

EXPOSE 8545
EXPOSE 8546
EXPOSE 30303

COPY entrypoint.sh /
COPY start-ethereum.sh /
ENTRYPOINT [ "/entrypoint.sh"]
