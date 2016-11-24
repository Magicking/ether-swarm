FROM node
MAINTAINER "Sylvain Laurent <s@6120.eu>"

# Install dependency packages
RUN apt-get update && \
    apt-get install -y git-core

# Install browser-solidity
RUN mkdir -p /usr/src/browser-solidity
WORKDIR /usr/src/browser-solidity

#COPY set-default-docker-endpoint.patch /tmp/
RUN git clone https://github.com/ethereum/browser-solidity.git .
#RUN git clone https://github.com/ethereum/browser-solidity.git . && \
#    git apply /tmp/set-default-docker-endpoint.patch

RUN npm install && \
    npm run build

EXPOSE 8080
CMD ["npm","run","serve"]
