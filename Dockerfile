FROM node:8.5.0

RUN npm -g config set user root
RUN npm install -g elm elm-test
ENV NODE_PATH ${NODE_PATH}:/src/lib

WORKDIR /src
