FROM openjdk:8-jre-alpine

MAINTAINER rajesh@unigps.in

COPY target/spring-db.jar app.jar
RUN java -jar app.jar  #build time
ENTRYPOINT ["/usr/bin/java", "-jar","app.jar"]
