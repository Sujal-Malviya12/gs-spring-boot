pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        APP_PORT = "9966"
        JMETER_HOME = "C:\\tools\\apache-jmeter-5.6.3"
        SONAR_PROJECT_KEY = "petclinic-rest-testing-demo"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build + Unit Tests') {
            steps {
                dir('complete/complete') {
                    bat 'mvn -U -B clean verify'
                }
            }
        }

        stage('SonarQube Scan') {
            options {
                timeout(time: 45, unit: 'MINUTES')
            }
            steps {
                dir('complete/complete') {
                    withSonarQubeEnv('sonarqube') {
                        bat """
                        mvn sonar:sonar ^
                        -Dsonar.projectKey=%SONAR_PROJECT_KEY%
                        """
                    }
                }
            }
        }

        stage('Start App (for JMeter)') {
            steps {
                dir('complete/complete') {
                    bat """
                    echo Starting app on port %APP_PORT%
                    start "petclinic" /B mvn spring-boot:run ^
                    -Dspring-boot.run.arguments=--server.port=%APP_PORT%
                    ping 127.0.0.1 -n 20 > nul
                    """
                }
            }
        }

        stage('JMeter Performance Test') {
            steps {
                bat """
                "%JMETER_HOME%\\bin\\jmeter.bat" -n ^
                 -t "%WORKSPACE%\\jmeter\\petclinic-smoke.jmx" ^
                 -l "%WORKSPACE%\\target\\jmeter-results.jtl" ^
                 -e -o "%WORKSPACE%\\target\\jmeter-report"
                """
            }
        }

        stage('Stop App') {
            steps {
                bat """
                for /f "tokens=5" %%a in ('netstat -ano ^| findstr :%APP_PORT%') do (
                    taskkill /PID %%a /F
                )
                exit /b 0
                """
            }
        }
    }

    post {
        always {
            junit allowEmptyResults: true, testResults: 'complete/complete/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: 'target/jmeter-results.jtl, target/jmeter-report/**', fingerprint: true
        }
        cleanup {
            cleanWs()
        }
    }
}
