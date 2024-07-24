pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                    sh "docker images"
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("http://${DOCKER_REGISTRY}") {
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Pull Docker Image') {
            steps {
                script {
                    sh "docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
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
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker image prune -f"
                    sh "docker images"
                }
            }
        }

        stage('Create CSV File') {
            steps {
                script {
                    echo "CSV File Path: ${FILE_PATH}"

                    // Create directory if it doesn't exist
                    sh """
                        mkdir -p ${env.CSV_DIR}
                        CURRENT_TIME=\$(date +'%Y-%m-%d %H:%M:%S')
                        BRANCH=\$(git rev-parse --abbrev-ref HEAD)
                        COMMIT_ID=\$(git rev-parse HEAD)

                        if [ ! -f ${FILE_PATH} ]; then
                            echo "Pipeline Name,Time,Branch,Commit ID,Build Number" > ${FILE_PATH}
                        fi

                        echo "${JOB_NAME},\${CURRENT_TIME},\${BRANCH},\${COMMIT_ID},${BUILD_NUMBER}" >> ${FILE_PATH}
                    """
                }
            }
        }

        stage('Upload CSV to Slack') {
            steps {
                script {
                    slackUploadFile(
                        channel: "${SLACK_CHANNEL}", 
                        credentialId: 'slack-bot-token', // Replace with your Slack bot token ID
                        filePath: "${FILE_PATH}",
                        initialComment: "Build information for job ${env.JOB_NAME} - build #${env.BUILD_NUMBER}"
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
                teamDomain: 'your-team-domain'  // Replace with your Slack team domain
            )
            cleanWs()
        }
    }
}
