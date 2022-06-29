FROM node:alpine

MAINTAINER "info@brainupgrade.in"

WORKDIR /app

COPY  main.js /app
COPY package.json /app

RUN ["npm","install"]
ENTRYPOINT ["npm"]
CMD ["start"]

EXPOSE 3000
