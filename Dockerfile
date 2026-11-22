# Build stage
FROM eclipse-temurin:27-jdk-alpine AS build
WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw
RUN ./mvnw dependency:go-offline

COPY src ./src
RUN ./mvnw clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:27-jre-alpine
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=build --chown=spring:spring /app/target/finance-0.0.1-SNAPSHOT.jar app.jar

ENV JAVA_OPTS="-Xms256M -Xmx512M -XX:+UseSerialGC"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
