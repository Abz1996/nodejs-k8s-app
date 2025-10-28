#!/bin/bash

echo "=== Setting up Kubernetes Cluster (Minikube) ==="

# Install dependencies
sudo apt update
sudo apt install -y curl wget apt-transport-https

# Install Docker (if not already installed)
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker --cpus=2 --memory=4096

# Enable Ingress addon (optional)
minikube addons enable ingress

# Verify installation
kubectl cluster-info
kubectl get nodes

echo "=== Kubernetes Setup Complete ==="
echo "Get Minikube IP: minikube ip"