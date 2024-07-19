pipeline {
    agent any

    

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
        
        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    def versionTag = "${env.BUILD_NUMBER}" // Or use any versioning scheme you prefer

            // Tag the image with both `latest` and version-specific tags
                    sh """
                        docker tag ${IMAGE_NAME}:${imageTag} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}
                        docker tag ${IMAGE_NAME}:${imageTag} ${DOCKER_REGISTRY}/${IMAGE_NAME}:${versionTag}
                    """

            // Push both tags to the registry
                    docker.withRegistry("http://${DOCKER_REGISTRY}") {
                         docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}").push()
                        docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${versionTag}").push()
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
                        channel: "${SLACK_CHANNEL}", 
                        credentialId: 'slack-bot-token', // Replace with your Slack bot token ID
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
