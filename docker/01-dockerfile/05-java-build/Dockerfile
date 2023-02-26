FROM adoptopenjdk/maven-openjdk11 
WORKDIR /build
RUN apt-get update && apt-get install -y git 
RUN git clone https://github.com/brainupgrade-in/request-logger.git 
RUN cd /build/request-logger && mvn clean package
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar","/build/request-logger/target/app.war"]
# docker build -t java-build .
# /build/request-logger/target/app.jar
# docker run -e spring.datasource.url=...... -e spring.profiles.active=prod -e spring.datasource.password=.... -d brainupgrde/springbootapp 
# jsypt ..
# application-prod.properties
