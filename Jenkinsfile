pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "localhost:5001"
        IMAGE_NAME = "python-app"
    }

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
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    docker.build("${IMAGE_NAME}:${imageTag}")
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
