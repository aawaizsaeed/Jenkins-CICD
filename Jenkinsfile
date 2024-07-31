pipeline {
    agent any
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    def branchName = params.BRANCH
                    echo "Checking out branch: ${branchName}"

                    checkout([$class: 'GitSCM',
                        branches: [[name: "*/${branchName}"]],
                        userRemoteConfigs: [[url: '${MY_CODE}']]
                    ])
                }
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
                        docker.image("${IMAGE_NAME}:${imageTag}").push()
                    }
                }
            }
        }
        stage('Pull Docker Image') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    sh "docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
                }
            }
        }
        stage('SSH to Remote Machine') {
            steps {
                sshPublisher(
                    publishers: [
                        sshPublisherDesc(
                            configName: 'ubuntu-ssh',  // Configuration name for SSH (defined below)
                            transfers: [
                                sshTransfer(
                                    sourceFiles: '',
                                    remoteDirectory: '',
                                     execCommand: """
                                echo "Pulling Docker image..."
                                docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest-${env.BUILD_NUMBER} &&
                                
                                echo "Stopping existing container..."
                                docker stop ${CONTAINER_NAME} || true &&
                                
                                echo "Removing existing container..."
                                docker rm ${CONTAINER_NAME} || true &&
                                
                                echo "Running new container..."
                                docker run -d --name ${CONTAINER_NAME} -p 6000:80 ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest-${env.BUILD_NUMBER} &&
                                
                                echo "Deployment successful"
                            """,
                            usePromotionTimestamp: false,
                            verbose: true
                                )
                            ],
                            usePromotionTimestamp: false,
                            verbose: true
                        )
                    ]
                )
            }
        }
    }

    post {
        always {
            // Clean up Docker images (optional)
            cleanWs()
        }
    }
}
