pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_CREDENTIALS_ID = 'docker-hub-credentials'
        DOCKER_IMAGE = 'abz1996/nodejs-k8s-app'  // ✅ Your username
        K8S_NAMESPACE = 'nodejs-app'
        K8S_CREDENTIALS_ID = 'kubeconfig-credentials'
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
        
       
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        dockerImage.push()
                        dockerImage.push("latest")
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
        
    
    