FROM ethereum/client-go:alpine

RUN apk update && apk add \
    git perl && \
    git clone --recursive https://github.com/ethereum/solidity.git && \
    cd solidity && \
    git checkout `git tag | tail -n1` && \
    ./scripts/install_deps.sh && \
    mkdir build && cd build && \
    cmake .. && make -j4 && make install
# We should run the test

COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh"]
