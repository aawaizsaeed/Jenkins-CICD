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
    }
}
