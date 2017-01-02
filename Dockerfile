#
#  Dockerfile for running testapp1
#
FROM alpine:3.3
MAINTAINER Harry Metske <harry.metske@rabobank.nl>
RUN apk --update add openjdk8-jre
ADD configserver-0.0.9.jar /app.jar
ENV LANG en_US.UTF-8
ENV CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom
EXPOSE 8080
CMD ["java","-jar", "/app.jar"]
