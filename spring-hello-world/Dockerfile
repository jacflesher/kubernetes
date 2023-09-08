FROM openjdk:17-jdk-alpine
EXPOSE 8080
ARG JAR_FILE=./spring-hello-world.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
