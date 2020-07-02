FROM node:current-slim

COPY package.json .
RUN npm install

CMD [ "make", "serve"]
COPY . . 