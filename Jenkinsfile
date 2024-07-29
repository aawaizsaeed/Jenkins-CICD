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

        stage('Deploy Docker Container') {
            steps {
                script {

                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    def remoteServer = '${UBUNTU_IP}' // Replace with your remote server IP
                    def sshCredentialsId = '${ubuntu-ssh}' // Replace with your SSH credentials ID

                    // Ensure SSH plugin is available and use it to run commands on the remote server
                    sshagent([sshCredentialsId]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${remoteServer} '
                                docker pull ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag} &&
                                docker stop ${CONTAINER_NAME} || true &&
                                docker rm ${CONTAINER_NAME} || true &&
                                docker run -d --name ${CONTAINER_NAME} -p 80:80 ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag} &&
                                echo "Deployment successful"
                            '
                     """
                    }
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
                    def filePath = "${env.CSV_DIR}/build_info.csv"

                    echo "CSV File Path: ${filePath}"

                    // Create directory if it doesn't exist
                    sh """
                        mkdir -p ${env.CSV_DIR}
                    """

                    // Create or update the CSV file
                    sh """
                        CURRENT_TIME=\$(date +'%Y-%m-%d %H:%M:%S') 
                        BRANCH=\$(git rev-parse --abbrev-ref HEAD)
                        COMMIT_ID=\$(git rev-parse HEAD)

                        # Check if the CSV file already exists
                        if [ ! -f ${filePath} ]; then
                            # If it doesn't exist, create the header
                            echo "Pipeline Name,Time,Branch,Commit ID,Build Number" > ${filePath}
                        fi

                        # Append the details to the CSV file
                        echo "${JOB_NAME},\${CURRENT_TIME},\${BRANCH},\${COMMIT_ID},${BUILD_NUMBER}" >> ${filePath}
                    """
                }
            }
        }
        stage('Scan Docker Image with Trivy') {
            steps {
                script {

                    def imageTag = "latest-${env.BUILD_NUMBER}"
                    // Scan the Docker image
                    sh """
                       export PATH=\$PATH:/var/jenkins_home/workspace/DevOps-Jenkins-CiCd_develop@tmp/trivy/bin
                       trivy image --severity HIGH,CRITICAL,MEDIUM ${DOCKER_REGISTRY}/${IMAGE_NAME}:${imageTag}
                       """
                //  sh "trivy --no-progress --exit-code 1 --severity HIGH,CRITICAL,MEDIUM ${DOCKER_REGISTRY}/${IMAGE_NAME}:latest-${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Upload CSV to Slack') {
            steps {
                script {
                    slackUploadFile(
                        channel: "${SLACK_CHANNEL}", 
                        credentialId: 'slack-bot-token', // Replace with your Slack bot token ID
                        filePath: "${env.FILE_PATH}",
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
