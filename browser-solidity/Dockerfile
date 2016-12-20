FROM node
MAINTAINER "Sylvain Laurent <s@6120.eu>"

ADD browser-solidity /usr/src/browser-solidity
ADD set-default-docker-endpoint.patch /tmp/
#ADD set-default-docker-endpoint.patch /tmp/set-default-docker-endpoint.patch
WORKDIR /usr/src/browser-solidity
RUN patch -p1 < /tmp/set-default-docker-endpoint.patch

RUN npm install && \
    npm run build

EXPOSE 8080
CMD ["npm","run","serve"]
