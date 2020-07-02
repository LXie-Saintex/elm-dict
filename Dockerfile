FROM node:current-slim

ENV app /usr/src/app/
WORKDIR ${app}

COPY package.json .
RUN npm install

FROM codesimple/elm:0.19
COPY elm.json .

COPY . .
EXPOSE 8080
CMD [ "make", "serve"]
COPY . . 