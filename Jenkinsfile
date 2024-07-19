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
        stage('Pull Docker Image') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    sh "docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}"
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
        stage('Update CSV') {
            steps {
                script {
                    def commitId = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    def currentTime = sh(script: 'date +"%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
                    def csvFilePath = 'build_info.csv'
                    def branch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    
                    sh """
                        if [ ! -f ${csvFilePath} ]; then
                            echo "Time,Branch,Commit ID,Build Number" > ${csvFilePath}
                        fi
                        echo "${currentTime},${branch},${commitId},${env.BUILD_NUMBER}" >> ${csvFilePath}
                    """
                }
            }
        }
    }

    post {
        always {
            slackSend(
                channel: '#random', 
                color: '#439FE0', 
                message: "Build status for ${env.JOB_NAME} - ${currentBuild.currentResult}: Latest Pipeline status ${env.BUILD_URL} Build number is ${env.BUILD_NUMBER}", 
                teamDomain: 'DevOps Engineer'
            )
            cleanWs()
        }
    }
}
