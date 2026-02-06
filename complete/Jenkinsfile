pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Compile') {
            steps {
                echo "Compiling project..."
                bat "mvn clean compile"
            }
        }
    }

    post {
        success {
            echo "Compilation Successful"
        }
        failure {
            echo "Compilation Failed"
        }
    }
}
