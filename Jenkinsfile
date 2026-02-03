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
                dir('complete') {
                    bat 'mvn -U -B clean verify'
                }
            }
        }

        stage('SonarQube Scan') {
            steps {
                dir('complete') {
                    withSonarQubeEnv('sonarqube') {
                        bat """
                        mvn sonar:sonar ^
                        -Dsonar.projectKey=%SONAR_PROJECT_KEY%
                        """
                    }
                }
            }
        }

        stage('SonarQube Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Start App (for JMeter)') {
            steps {
                dir('complete') {
                    bat """
                    start "spring-boot-app" /B mvn spring-boot:run ^
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
         -l "%WORKSPACE%\\complete\\target\\jmeter-results.jtl" ^
         -e -o "%WORKSPACE%\\complete\\target\\jmeter-report"
        """
    }
}

        stage('Extract Performance Metrics') {
    steps {
        bat '"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" -ExecutionPolicy Bypass -File scripts\\parse-jmeter.ps1 complete\\target\\jmeter-results.jtl perf-current.json'
    }
}

stage('Performance Gate (PR)') {
    when {
        changeRequest()
    }
    steps {
        script {
            def exceptionAllowed = bat(
                script: 'git log -1 --pretty=%B | findstr PERF-EXCEPTION',
                returnStatus: true
            ) == 0

            if (exceptionAllowed) {
                echo "⚠ Performance exception allowed for this PR"
            } else {
                bat '"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" -ExecutionPolicy Bypass -File scripts\\parse-jmeter.ps1 complete\\target\\jmeter-results.jtl perf-current.json'
            }
        }
    }
}

        stage('Update Performance Baseline') {
    when {
        branch 'main'
    }
    steps {
        bat 'copy perf-current.json baseline\\perf-baseline.json'
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
        junit allowEmptyResults: true,
              testResults: 'complete/target/surefire-reports/*.xml'

        archiveArtifacts artifacts: 'complete/target/jmeter-results.jtl, complete/target/jmeter-report/**',
                         fingerprint: true
    }
    cleanup {
        cleanWs()
    }
}

}
