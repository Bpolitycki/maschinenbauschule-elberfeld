# Use eclipse-temurin as the base image
FROM eclipse-temurin:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y make wget && \
    rm -rf /var/lib/apt/lists/*

# Set working directory (optional)
WORKDIR /app

# Keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
