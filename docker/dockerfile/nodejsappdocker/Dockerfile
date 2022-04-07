FROM node:alpine

MAINTAINER "info@brainupgrade.in"

WORKDIR /app

COPY  main.js package.json .

RUN ["npm","install"]
CMD ["npm", "start"]

EXPOSE 8000
