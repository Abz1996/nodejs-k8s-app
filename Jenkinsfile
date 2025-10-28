pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'abz1996/nodejs-k8s-app'
        K8S_NAMESPACE = 'nodejs-app'
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
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    docker.withRegistry('https://docker.io', 'docker-hub-credentials') {
                        sh """
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying to Kubernetes...'
                sh """
                    # Test connection
                    kubectl cluster-info
                    kubectl get nodes
                    
                    # Create namespace if not exists
                    kubectl get namespace ${K8S_NAMESPACE} || kubectl create namespace ${K8S_NAMESPACE}
                    
                    # Update deployment file with new image
                    sed -i 's|YOUR_DOCKER_REGISTRY/nodejs-k8s-app:latest|${DOCKER_IMAGE}:${BUILD_NUMBER}|g' k8s/deployment.yaml
                    sed -i 's|BUILD_NUMBER|${BUILD_NUMBER}|g' k8s/deployment.yaml
                    
                    # Apply manifests
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    
                    # Wait for rollout to complete
                    kubectl rollout status deployment/nodejs-app -n ${K8S_NAMESPACE} --timeout=5m
                    
                    # Show deployment status
                    kubectl get pods -n ${K8S_NAMESPACE}
                    kubectl get svc -n ${K8S_NAMESPACE}
                    
                    echo "✅ Deployment completed!"
                """
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                sh """
                    echo "=== Pods ==="
                    kubectl get pods -n ${K8S_NAMESPACE} -o wide
                    
                    echo ""
                    echo "=== Services ==="
                    kubectl get svc -n ${K8S_NAMESPACE}
                    
                    echo ""
                    echo "=== Deployment Status ==="
                    kubectl get deployment -n ${K8S_NAMESPACE}
                    
                    echo ""
                    echo "=== Application Info ==="
                    echo "Service Type: LoadBalancer"
                    echo "NodePort: \$(kubectl get svc nodejs-app-service -n ${K8S_NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')"
                """
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo '🚀 Your application is now running on Kubernetes!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
        
    
    