pipeline {
    agent any

    stages {
        stage('Checkout GitHub Repo') {
            steps {
                script {
                    //Add github repo url
                    git branch: 'node-test', url: 'https://username:accesstoken@github.com/Devops-App.git'
                }
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
