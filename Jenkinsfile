pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = "localhost:5001"
        IMAGE_NAME = "python-app"
        SLACK_CHANNEL = '#random'
        FILE_PATH = 'build_info.csv'
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
        stage('Create and Verify CSV File') {
            steps {
                script {
                    def filePath = 'build_info.csv'
            // Create and write to the file
                    sh """
                    echo 'Time,Branch,Commit ID,Build Number' > ${filePath}
                    echo '$(date +%Y-%m-%d\ %H:%M:%S),$(git rev-parse --abbrev-ref HEAD),$(git rev-parse HEAD),${env.BUILD_NUMBER}' >> ${filePath}
                    ls -l ${filePath}
                    cat ${filePath}
                    """
                }
            }
        }
       
        stage('Verify File Creation') {
            steps {
                script {
                    sh 'ls -l /var/jenkins_home/workspace/DevOps-Jenkins-CiCd_develop@tmp'
                    sh 'ls -l /var/jenkins_home/workspace/DevOps-Jenkins-CiCd_develop@tmp/build_info.csv'
                    sh 'cat /var/jenkins_home/workspace/DevOps-Jenkins-CiCd_develop@tmp/build_info.csv'
                }
            }
        }
        stage('Upload CSV to Slack') {
            steps {
                script {
                    slackUploadFile(
                        channel: '${env.SLACK_CHANNEL}', 
                        credentialId: 'slack-bot-token', 
                        filePath: '/var/jenkins_home/workspace/DevOps-Jenkins-CiCd_develop@tmp/build_info.csv', 
                        initialComment: 'Build information for job ${env.JOB_NAME} - build #${env.BUILD_NUMBER}'
                    )
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
