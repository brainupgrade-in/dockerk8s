FROM adoptopenjdk/maven-openjdk11  
WORKDIR /build
RUN apt-get update && apt-get install -y git 
RUN git clone https://github.com/brainupgrade-in/request-logger.git 
RUN cd /build/request-logger && mvn clean package
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar","/build/request-logger/target/app.jar"]
# docker build -t java-build .
# /build/request-logger/target/app.jar