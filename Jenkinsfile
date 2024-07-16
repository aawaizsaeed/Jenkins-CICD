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
                    sh "docker images"
                }
            }
        }
        stage('Tag Docker Image') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    sh "docker tag ${IMAGE_NAME}:${imageTag} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    docker.withRegistry("http://${DOCKER_REGISTRY}") {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}").push()
                    }
                }
            }
        }
        stage('Deploy Docker Container') {
            steps {
                script {
                    sh "chmod +x ./deploy.sh"
                    sh './deploy.sh'
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    sh "docker rmi ${IMAGE_NAME}:${imageTag}"
                    sh "docker image prune -f"
                    sh "docker images"
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
