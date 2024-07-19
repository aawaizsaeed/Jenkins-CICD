pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "localhost:5001"
        IMAGE_NAME = "python-app"
        SLACK_CHANNEL = '#random'
        FILE_PATH = 'hello.txt'
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
        
        stage('Create Text File') {
            steps {
                script {
                    sh '''
                        CURRENT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
                        BRANCH=$(git rev-parse --abbrev-ref HEAD)
                        COMMIT_ID=$(git rev-parse HEAD)
                        echo "Pipeline Name: ${JOB_NAME}" > ${FILE_PATH}
                        echo "Time: ${CURRENT_TIME}" >> ${FILE_PATH}
                        echo "Branch: ${BRANCH}" >> ${FILE_PATH}
                        echo "Commit ID: ${COMMIT_ID}" >> ${FILE_PATH}
                        echo "Build Number: ${BUILD_NUMBER}" >> ${FILE_PATH}
                    '''
                }
            }
        }

        stage('Upload txt to Slack') {
            steps {
                script {
                    slackUploadFile(
                        channel: "${env.SLACK_CHANNEL}", 
                        credentialId: 'slack-webhook', // Replace with your Slack bot token ID
                        filePath: "${FILE_PATH}",
                        initialComment: 'Build information for job ${env.JOB_NAME} - build #${env.BUILD_NUMBER}'
                    )
                }
            }
        }
    }

    post {
        always {
            slackSend(
                channel: "${env.SLACK_CHANNEL}", 
                color: '#439FE0', 
                message: "Build status for ${env.JOB_NAME} - ${currentBuild.currentResult}: Latest Pipeline status ${env.BUILD_URL} Build number is ${env.BUILD_NUMBER}", 
                teamDomain: 'DevOps Engineer'
            )
            cleanWs()
        }
    }
}
