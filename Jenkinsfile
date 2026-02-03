pipeline {
    agent any

    tools {
        jdk 'jdk-21'
        maven 'maven-3'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                dir('complete/complete') {
                    bat 'mvn clean test'
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                dir('complete/complete') {
                    withSonarQubeEnv('sonarqube') {
                        bat """
                        mvn sonar:sonar ^
                        -Dsonar.projectKey=gs-spring-boot-demo ^
                        -Dsonar.login=%SONAR_TOKEN%
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('JMeter') {
            steps {
                bat """
                "C:\\tools\\apache-jmeter-5.6.3\\bin\\jmeter.bat" -n ^
                 -t "%WORKSPACE%\\jmeter\\petclinic-smoke.jmx" ^
                 -l "%WORKSPACE%\\jmeter\\results.jtl"
                """
            }
        }
    }
}
