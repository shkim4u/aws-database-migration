# 애플리케이션 빌드 스테이지
#FROM maven:3.3.9-jdk-8 AS build
FROM public.ecr.aws/docker/library/maven:3.9.4-amazoncorretto-11 AS build
WORKDIR /app

# 빌드 성능 개선
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn -f pom.xml clean package

# 컨테이너 이미지 빌드 스테이지
# 하지만 아래 소스 이미지가 최선일까요?
#FROM tomcat:9-jdk11
FROM public.ecr.aws/docker/library/tomcat:9.0-jre11

COPY --from=build /app/target/\*.war /usr/local/tomcat/webapps/travelbuddy.war
# (Optional) Make the "/travelbuddy/" path to root "/" with root healthcheck.
#COPY --from=build /app/target/\*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080

CMD ["catalina.sh", "run"]
