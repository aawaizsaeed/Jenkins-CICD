pipeline {
    agent any

    environment {
        // Placeholder environment variables
        DOCKER_REGISTRY = ''
        IMAGE_NAME = ''
    }

    stages {
        stage('Load Environment Variables') {
            steps {
                script {
                    // Load properties from the file
                    def props = readProperties file: 'env.properties'
                    env.DOCKER_REGISTRY = props.DOCKER_REGISTRY
                    env.IMAGE_NAME = props.IMAGE_NAME
                }
            }
        }
    }
}
