FROM node
MAINTAINER "Sylvain Laurent <s@6120.eu>"

ADD eth-netstats /usr/src/eth-netstats
WORKDIR /usr/src/eth-netstats

RUN npm install && \
    npm install -g grunt-cli && \
    grunt

EXPOSE 3000
CMD ["npm","start"]
