pipeline {
    agent any
    environment {
        DOCKER_REGISTRY = "localhost:5000"
        IMAGE_NAME = "python-app"
    stages {
        stage('Clone Code from GitHub') {
            steps {
                git url: 'https://github.com/aawaizsaeed/Jenkins-CICD.git', branch: 'main'
            }
        }
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Automatically tag the Docker image with the Jenkins build number
                    def buildNumber = env.BUILD_NUMBER
                    def dockerImageTag = "${REGISTRY}/${APP_NAME}:${buildNumber}"
                    // Build the Docker image
                    sh "docker build -t ${dockerImageTag} ."
                }
            }
        }
    }
}
