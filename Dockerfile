FROM codesimple/elm:0.19
COPY src/ src/
ADD elm.json .
RUN elm make src/Main.elm --optimize --output=main.js

FROM node:current-slim
ADD package.json .
RUN npm install --only=prod

COPY . .
CMD [ "npm", "start"]