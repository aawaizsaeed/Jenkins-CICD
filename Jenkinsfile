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
    stage('Check Branch Name') {
            steps {
                script {
                    if (env.BRANCH_NAME) {
                        echo "Current branch is: ${env.BRANCH_NAME}"
                    } else {
                        echo "BRANCH_NAME is not set."
                    }
                }
            }
        }
    }
}
