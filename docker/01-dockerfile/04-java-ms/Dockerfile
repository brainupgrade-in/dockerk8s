FROM openjdk:8-jre-alpine
COPY target/springbootapp.jar app.jar
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar","app.jar"]
# docker build -t spring-app .
# docker run -p 8080:8080 spring-app