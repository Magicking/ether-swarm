FROM alpine:3.4

RUN \
  apk add --update go git make gcc musl-dev perl && \
  git clone --depth 1 https://github.com/ethereum/go-ethereum && \
  ( cd go-ethereum && make geth ) && \
  cp go-ethereum/build/bin/geth /geth && \
  git clone --recursive https://github.com/ethereum/solidity.git && \
  ( cd solidity && \
  git checkout `git tag | tail -n1` && \
  ./scripts/install_deps.sh && \
  mkdir build && cd build && \
  cmake .. && make -j4 && make install ) && \
  apk del go git make gcc musl-dev && \
  rm -rf /go-ethereum && rm -rf /var/cache/apk/* 
# We should run the test

EXPOSE 8545
EXPOSE 8546
EXPOSE 30303

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
