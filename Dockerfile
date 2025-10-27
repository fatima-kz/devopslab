# Use Maven with OpenJDK 8 to build the application
FROM maven:3.6.3-openjdk-8-slim AS build

# Set working directory
WORKDIR /app

# Copy Maven wrapper and pom.xml first (for better layer caching)
COPY pom.xml .
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Use OpenJDK 8 runtime for the final image
FROM openjdk:8-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built WAR file from the build stage
COPY --from=build /app/target/TodoDemo-0.0.1-SNAPSHOT.war app.jar

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]