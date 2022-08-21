FROM openjdk:8-jre-alpine

LABEL MAINTAINER info@brainupgrade.in

COPY target/springbootapp.jar app.jar

EXPOSE 8080 

ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar","app.jar"]
# docker build -t spring-app .
# docker run -p 8080:8080 spring-app