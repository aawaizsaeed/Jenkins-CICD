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
        
        stage('Create CSV File') {
            steps {
                script {
                    def csvDir = "$var/jenkins_home/builds/csv"
                    def filePath = "${csvDir}/build_info.csv"

                    // Create directory if it doesn't exist
                    sh "mkdir -p ${csvDir}"

                    // Create or update the CSV file
                    sh """
                        if [ ! -f ${filePath} ]; then
                            echo "Pipeline Name,Time,Branch,Commit ID,Build Number" > ${filePath}
                        fi
                        CURRENT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
                        BRANCH=$(git rev-parse --abbrev-ref HEAD)
                        COMMIT_ID=$(git rev-parse HEAD)

                        # Append the build information to the CSV file
                        echo "${JOB_NAME},${CURRENT_TIME},${BRANCH},${COMMIT_ID},${BUILD_NUMBER}" >> ${filePath}
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
                        filePath: "${filepath}/csv/build_info.csv",
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
                message: "Build status for ${env.JOB_NAME} - ${currentBuild.currentResult}: Latest Pipe
