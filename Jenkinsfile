pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'  // or your private registry
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        DOCKER_IMAGE = 'your-dockerhub-username/nodejs-k8s-app'
        K8S_NAMESPACE = 'nodejs-app'
        K8S_CREDENTIALS_ID = 'kubeconfig-credentials'
        K8S_MASTER = '50.116.51.141'  // Your K8s Master PUBLIC IP
        K8S_API = "https://${K8S_MASTER}:6443"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from Git...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Installing dependencies...'
                sh 'cd app && npm install'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'cd app && npm test'
            }
        }
        
        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to registry...'
                script {
                    docker.withRegistry("https://${DOCKER_REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
                        dockerImage.push("${BUILD_NUMBER}")
                        dockerImage.push("latest")
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                script {
                    withKubeConfig([credentialsId: "${K8S_CREDENTIALS_ID}"]) {
                        sh """
                            # Apply namespace
                            kubectl apply -f k8s/namespace.yaml
                            
                            # Update image in deployment
                            sed -i 's|YOUR_DOCKER_REGISTRY/nodejs-k8s-app:latest|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' k8s/deployment.yaml
                            sed -i 's|BUILD_NUMBER|${BUILD_NUMBER}|g' k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            
                            # Wait for rollout
                            kubectl rollout status deployment/nodejs-app -n ${K8S_NAMESPACE} --timeout=5m
                            
                            # Get service details
                            kubectl get svc -n ${K8S_NAMESPACE}
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    withKubeConfig([credentialsId: "${K8S_CREDENTIALS_ID}"]) {
                        sh """
                            kubectl get pods -n ${K8S_NAMESPACE}
                            kubectl get svc -n ${K8S_NAMESPACE}
                        """
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
            slackSend(color: 'good', message: "Deployment succeeded: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(color: 'danger', message: "Deployment failed: ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}")
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}