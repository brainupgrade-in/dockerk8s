FROM adoptopenjdk/maven-openjdk11  AS BUILD
WORKDIR /build
RUN apt-get update && apt-get install -y git 
RUN git clone https://github.com/brainupgrade-in/request-logger.git 
RUN cd /build/request-logger && mvn clean package


FROM openjdk:8-jre-alpine
MAINTAINER info@brainupgrade.in
COPY --from=build /build/request-logger/target/app.jar app.jar
ENTRYPOINT ["/usr/bin/java", "-Djava.security.egd=file:/dev/./urandom", "-jar","app.jar"]
