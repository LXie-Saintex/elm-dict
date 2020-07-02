FROM node:current-slim
ADD package.json .
RUN npm install

FROM codesimple/elm:0.19
ADD elm.json .

COPY . .
EXPOSE 8080
CMD [ "make", "dev"]