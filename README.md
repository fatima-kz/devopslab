# DevOps Lab - MySQL Spring Boot Todo Application

A simple Todo list application using Spring Boot with the following options:

- Spring JPA and MySQL for data persistence
- Thymeleaf template for the rendering.
- Docker containerization for easy deployment

## Quick Start with Docker

1. **Prerequisites**: Make sure you have Docker and Docker Compose installed
2. **Run the application**:
   ```bash
   docker-compose up -d
   ```
3. **Access the application**: Open your browser to http://localhost:8081

## Manual Setup (Alternative)

### Configure MySQL

1. Create a database in your MySQL instance.
2. Update the application.properties file in the `src/main/resources` folder with the URL, username and password for your MySQL instance. The table schema for the Todo objects will be created for you in the database.

### Build and run the sample

1. `mvnw package`
2. `java -jar target/TodoDemo-0.0.1-SNAPSHOT.jar`
3. Open a web browser to http://localhost:8080

As you add and update tasks in the app you can verify the changes in the database through the MySQL console using simple statements like 
`select * from todo_item`.

## Docker Configuration

This project includes:
- `Dockerfile` for building the Spring Boot application
- `docker-compose.yml` for running the complete stack (app + MySQL)
- `.dockerignore` for optimizing builds
