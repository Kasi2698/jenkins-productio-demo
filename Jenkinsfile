pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('SonarQube Analysis') {
    steps {
        script {
            def scannerHome = tool 'SonarQube Scanner'

            withSonarQubeEnv('SonarQube') {
                sh """
                    ${scannerHome}/bin/sonar-scanner \
                      -Dsonar.organization=kasi2698 \
                      -Dsonar.projectKey=Kasi2698_sonarqube-github-actions-demo \
                      -Dsonar.projectName=jenkins-production-demo \
                      -Dsonar.sources=. \
                      -Dsonar.tests=tests \
                      -Dsonar.test.inclusions=tests/**/*.js \
                      -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                      -Dsonar.qualitygate.wait=true \
                      -Dsonar.qualitygate.timeout=300
                """
            }
        }
    }
}

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t jenkins-production-demo:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Security Scan') {
            steps {
                sh '''
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --exit-code 1 \
                      jenkins-production-demo:${BUILD_NUMBER}
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                          -u "$DOCKER_USER" \
                          --password-stdin

                        docker tag \
                          jenkins-production-demo:${BUILD_NUMBER} \
                          "$DOCKER_USER/jenkins-production-demo:${BUILD_NUMBER}"

                        docker push \
                          "$DOCKER_USER/jenkins-production-demo:${BUILD_NUMBER}"
                    '''
                }
            }
        }

        stage('Production Approval') {
            steps {
                input message: 'Deploy to production?',
                      ok: 'Deploy'
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(['ec2-ssh']) {

                    sh '''
                        ssh -o StrictHostKeyChecking=no \
                            ubuntu@15.206.163.153 \
                            "
                            sudo docker pull kasi26/jenkins-production-demo:${BUILD_NUMBER} &&
                            sudo docker stop jenkins-demo || true &&
                            sudo docker rm jenkins-demo || true &&
                            sudo docker run -d \
                              --name jenkins-demo \
                              -p 3000:3000 \
                              kasi26/jenkins-production-demo:${BUILD_NUMBER}
                            "
                    '''
                }
            }
        }
    }
}
