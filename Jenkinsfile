pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        DOCKER_IMAGE = "pn2849/anon-ecommerce"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/DespondentG/anon-ecommerce-website.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh """
                        echo ${DOCKERHUB_CREDENTIALS_PSW} | docker login -u ${DOCKERHUB_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                script {
                    sh """
                        sudo k3s kubectl set image deployment/anon-web nginx=${DOCKER_IMAGE}:latest -n anon
                        sudo k3s kubectl rollout restart deployment/anon-web -n anon
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Your site is updated and live."
        }
        failure {
            echo "❌ Build or deployment failed. Check logs."
        }
    }
}
