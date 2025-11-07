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
                    // Use Jenkins build number for unique tagging
                    IMAGE_TAG = "${BUILD_NUMBER}"
                    sh """
                        echo "🔨 Building Docker image with tag: ${IMAGE_TAG}"
                        docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
                        docker tag ${DOCKER_IMAGE}:${IMAGE_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    // Use Docker Hub credentials securely
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "🔑 Logging in to Docker Hub as ${DOCKER_USER}"
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            echo "📦 Pushing image ${DOCKER_IMAGE}:${IMAGE_TAG} to Docker Hub"
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
                    // Deploy and force rollout using the new image
                    sh """
                        echo "🚀 Deploying ${DOCKER_IMAGE}:${IMAGE_TAG} to Kubernetes namespace: ${NAMESPACE}"
                        sudo k3s kubectl set image deployment/anon-web nginx=${DOCKER_IMAGE}:${IMAGE_TAG} -n ${NAMESPACE} || true
                        sudo k3s kubectl rollout restart deployment/anon-web -n ${NAMESPACE}
                        sudo k3s kubectl rollout status deployment/anon-web -n ${NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Version ${BUILD_NUMBER} is live and served from ${DOCKER_IMAGE}:${BUILD_NUMBER}."
        }
        failure {
            echo "❌ Build or deployment failed. Check Jenkins logs for details."
        }
    }
}
