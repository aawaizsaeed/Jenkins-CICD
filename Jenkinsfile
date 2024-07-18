pipeline {
    agent any

    stages {
        stage('Clone Code from GitHub') {
            steps {
                git url: 'https://github.com/aawaizsaeed/Jenkins-CICD.git', branch: 'main'
            }
        }
    }

    post {
        always {
            //Add channel name
            slackSend channel: 'channelName',
            message: "Find Status of Pipeline:- ${currentBuild.currentResult} ${env.JOB_NAME} ${env.BUILD_NUMBER} ${BUILD_URL}"
        }
    }
}
