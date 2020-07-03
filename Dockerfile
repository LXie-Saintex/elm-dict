FROM codesimple/elm:0.19
COPY src/ src/
ADD elm.json .
ADD Makefile .
RUN elm make src/Main.elm --optimize --output=main.js

FROM node:current-slim
ADD package.json .
RUN npm install

COPY . .
EXPOSE 8080
CMD [ "npm", "start"]