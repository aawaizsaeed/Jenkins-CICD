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
                    def csvDir = "${env.CSV_DIR}"
                    def filePath = "${csvDir}/build_info.csv"

                    echo "CSV Directory: ${csvDir}"
                    echo "File Path: ${filePath}"

                    // Create directory if it doesn't exist
                    sh """ 
                    mkdir -p ${csvDir}
                    ls -l ${csvDir} 
                    """

                    // Create or update the CSV file
                    sh '''
                        CURRENT_TIME=$(date +'%Y-%m-%d %H:%M:%S')
                        BRANCH=$(git rev-parse --abbrev-ref HEAD)
                        COMMIT_ID=$(git rev-parse HEAD)
                        FILE_PATH="pipeline_details.csv"
                                        # Check if the CSV file already exists
                        if [ ! -f ${FILE_PATH} ]; then
                          If it doesn't exist, create the header
                        echo "Pipeline Name,Time,Branch,Commit ID,Build Number" > ${FILE_PATH}
                        fi

                            # Append the details to the CSV file
                        echo "${JOB_NAME},${CURRENT_TIME},${BRANCH},${COMMIT_ID},${BUILD_NUMBER}" >> ${FILE_PATH}  
                       '''
                }
            }
        }

        stage('Upload CSV to Slack') {
            steps {
                script {
                    slackUploadFile(
                        channel: "${SLACK_CHANNEL}", 
                        credentialId: 'slack-bot-token', // Replace with your Slack bot token ID
                        filePath: "${filePath}",
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
