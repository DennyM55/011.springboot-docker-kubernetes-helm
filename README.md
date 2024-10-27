## **Project Overview:**
This project involved **containerizing a Spring Boot application** using **Docker**, deploying it on a **local Kubernetes cluster** with **Minikube**, and automating the deployment using **Helm charts**.

---

# **1. Spring Boot Application Setup**

### What is Spring Boot?
Spring Boot is a Java framework that simplifies creating web applications. It provides a default configuration to build REST APIs or microservices quickly.

### Steps we followed:
1. **Create a new Spring Boot project** using **IntelliJ IDEA**.
    - We used `pom.xml` (Maven) for dependencies.
    - The **`@RestController`** exposed a simple `/hello` endpoint:
      ```java
      @RestController
      public class HelloController {
          @GetMapping("/hello")
          public String hello() {
              return "Updated message from Helm!";
          }
      }
      ```

2. **Build the Spring Boot JAR**:
    - We used Maven to build the project:
      ```bash
      mvn clean package
      ```
    - The result was a **JAR file**: `target/demo-0.0.1-SNAPSHOT.jar`.

---

# **2. Dockerizing the Spring Boot Application**

### What is Docker?
Docker allows us to package the application, along with all its dependencies, into a **container** so it runs consistently across different environments.

### Steps we followed:
1. **Create a Dockerfile**:
   ```dockerfile
   # Use an OpenJDK image
   FROM azul/zulu-openjdk:17
   
   # Set working directory inside container
   WORKDIR /app

   # Copy JAR file from Maven build output to the container
   COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

   # Expose port 8080
   EXPOSE 8080

   # Define the command to run the app
   ENTRYPOINT ["java", "-jar", "app.jar"]
   ```

2. **Build the Docker Image**:
   ```bash
   docker build -t denmax007/springboot-docker-app:v2 .
   ```

3. **Tag the Image as `latest`**:
   ```bash
   docker tag denmax007/springboot-docker-app:v2 denmax007/springboot-docker-app:latest
   ```

4. **Push the Image to Docker Hub**:
   ```bash
   docker push denmax007/springboot-docker-app:v2
   docker push denmax007/springboot-docker-app:latest
   ```

---

# **3. Setting Up Minikube (Local Kubernetes)**

### What is Minikube?
Minikube is a tool that lets you run a **Kubernetes cluster locally** on your machine.

### Steps we followed:
1. **Start Minikube**:
   ```bash
   minikube start
   ```

2. **Verify Minikube Cluster**:
   ```bash
   minikube status
   kubectl cluster-info
   ```

3. **Delete old resources to avoid conflicts**:
   ```bash
   kubectl delete pods --all
   kubectl delete svc --all
   ```

---

# **4. Deploying with Helm**

### What is Helm?
Helm is a package manager for Kubernetes that allows you to **automate deployments** using charts.

### Helm Chart Structure:
```
springboot-chart/
│
├── Chart.yaml               # Chart metadata (version, name, etc.)
├── values.yaml              # Configurations passed to templates
├── templates/               # Kubernetes resource templates
│   ├── deployment.yaml      # Template for Deployment
│   ├── service.yaml         # Template for Service
│   └── configmap.yaml       # Environment variables
```

1. **`Chart.yaml`**:
   ```yaml
   apiVersion: v2
   name: springboot-chart
   version: 0.1.0
   description: A Helm chart for deploying Spring Boot app
   ```

2. **`values.yaml`**:
   ```yaml
   image:
     repository: denmax007/springboot-docker-app
     tag: latest
     pullPolicy: Always

   env:
     APP_MESSAGE: "Updated message from Helm!"

   replicaCount: 2

   service:
     type: LoadBalancer
     port: 80
   ```

3. **`templates/deployment.yaml`**:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: {{ include "springboot-chart.fullname" . }}
   spec:
     replicas: {{ .Values.replicaCount }}
     selector:
       matchLabels:
         app: {{ include "springboot-chart.name" . }}
     template:
       metadata:
         labels:
           app: {{ include "springboot-chart.name" . }}
       spec:
         containers:
           - name: {{ .Chart.Name }}
             image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
             env:
               - name: APP_MESSAGE
                 value: "{{ .Values.env.APP_MESSAGE }}"
             ports:
               - containerPort: 8080
   ```

4. **Deploy using Helm**:
    - First, uninstall any old Helm release:
      ```bash
      helm uninstall springboot-app
      ```
    - Install the new Helm chart:
      ```bash
      helm install springboot-app . --set image.tag=v2 --set image.pullPolicy=Always
      ```

---

# **5. Verify Deployment**

1. **Check all resources**:
   ```bash
   kubectl get all
   ```

2. **Port-forward to access the app locally**:
   ```bash
   kubectl port-forward svc/springboot-app-springboot-chart 8080:80
   ```

3. **Test the service**:
   ```bash
   curl http://localhost:8080/hello
   ```

   **Expected Output**:
   ```
   Updated message from Helm!
   ```

---

# **6. Troubleshooting Tips**

1. **If the old message persists**, ensure:
    - **Docker image is rebuilt** and pushed properly.
    - **Helm chart uses the correct image tag**.
    - No **old pods or services** are still running.

2. **Delete old pods or services if needed**:
   ```bash
   kubectl delete pods --all
   kubectl delete svc --all
   ```

---

# **Summary of What We Achieved**

- **Developed a Spring Boot Application** and built it into a **Docker container**.
- **Pushed the container image to Docker Hub** and ensured the latest version is available.
- **Deployed the application using Helm on Minikube**, automating the setup.
- **Successfully accessed the app locally using port-forwarding**.

---
