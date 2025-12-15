# Stage 1: Download dependencies (better caching)
FROM maven:3.8.6-openjdk-8 AS dependencies
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Stage 2: Build application
FROM maven:3.8.6-openjdk-8 AS build
WORKDIR /app
COPY pom.xml .
COPY --from=dependencies /root/.m2 /root/.m2
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 3: Runtime
FROM eclipse-temurin:8-jre-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=build /app/target/TodoDemo-0.0.1-SNAPSHOT.war app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]