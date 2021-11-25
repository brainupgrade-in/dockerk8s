FROM openjdk:8-jre-alpine
MAINTAINER info@brainupgrade.in
COPY --from=java-build /build/request-logger/target/app.jar app.jar
ENTRYPOINT ["/usr/bin/java", "-Djava.security.egd=file:/dev/./urandom", "-jar","app.jar"]
# docker build -t java-run .
# docker run -p 8080:8080 java-run