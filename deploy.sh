#!/bin/bash

# Variables
IMAGE_NAME="python-app"
DOCKER_REGISTRY="172.17.0.3:5000"
IMAGE_TAG="latest-${BUILD_NUMBER}"
CONTAINER_NAME="python-app-container"

# Pull the latest image
docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

# Stop and remove existing container if it exists
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

# Run a new container from the pulled image
docker run -d --name ${CONTAINER_NAME} -p 80:80 ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

# Wait for a few seconds to ensure the application is up and running
#sleep 10

# Check the application with curl
#wget http://localhost:80/ || { echo "Health check failed"; exit 1; }

echo "Deployment successful"
