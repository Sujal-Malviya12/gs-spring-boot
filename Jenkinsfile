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
                dir('complete') {
                    sh 'mvn clean test'
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                dir('complete') {
                    withSonarQubeEnv('sonarqube') {
                        sh '''
                        mvn sonar:sonar \
                        -Dsonar.projectKey=gs-spring-boot-demo \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('JMeter') {
            steps {
                sh '''
                jmeter -n \
                -t jmeter/test-plan.jmx \
                -l jmeter/results.jtl
                '''
            }
        }
    }
}
