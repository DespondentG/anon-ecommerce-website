pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "pn2849/anon-ecommerce"
        NAMESPACE = "anon"
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
                    // Use Jenkins build number to create unique image tags
                    IMAGE_TAG = "${BUILD_NUMBER}"
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                        docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                script {
                    // Automatically tell Kubernetes to use the new versioned image and restart deployment
                    sh """
                        sudo k3s kubectl set image deployment/anon-web nginx=${DOCKER_IMAGE}:${IMAGE_TAG} -n ${NAMESPACE}
                        sudo k3s kubectl rollout restart deployment/anon-web -n ${NAMESPACE}
                        sudo k3s kubectl rollout status deployment/anon-web -n ${NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Version ${BUILD_NUMBER} is live."
        }
        failure {
            echo "❌ Build or deployment failed. Check Jenkins logs for details."
        }
    }
}
