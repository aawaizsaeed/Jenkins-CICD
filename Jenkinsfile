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
        stage('Remote SSH') {
            steps {
                script {
                    // Define the SSH connection details
                    def remote = [:]
                    remote.name = 'server'
                    remote.host = '172.19.0.3'
                    remote.user = 'SSH_USER'
                    remote.password = 'SSH_PASSWORD' // Ensure this is securely managed
                    remote.allowAnyHosts = true

                    // Use the sshCommand step to run commands on the remote server
                    sshCommand remote: remote, command: "whoami"

                    sshCommand remote: remote, command: """
                        docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag} &&
                        docker stop ${CONTAINER_NAME} || true &&
                        docker rm ${CONTAINER_NAME} || true &&
                        docker run -d --name ${CONTAINER_NAME} -p 80:80 ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag} &&
                        echo "Deployment successful"
                    """

                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images (optional)
            sh 'docker image prune -af'
        }
    }
}
