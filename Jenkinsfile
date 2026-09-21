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
