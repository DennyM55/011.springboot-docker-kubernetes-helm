# Use an official OpenJDK as a base image
FROM azul/zulu-openjdk:17

# Set the working directory in the container
WORKDIR /app

# Copy the built JAR file from Maven target directory to the container
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the port the application will run on
EXPOSE 8080

# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
