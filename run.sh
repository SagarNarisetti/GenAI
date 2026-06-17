#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "🚀 Starting Localized RAG-Enabled Document Intelligence deployment..."

# NOTE: If you are using Minikube, uncomment the line below so Docker builds into the Minikube environment.
# eval $(minikube docker-env)

echo "📦 Building the local Docker image for the RAG app..."
docker build -t rag-app:latest -f ./app/Dockerfile .

echo "⚙️  Applying Kubernetes manifests..."

# Apply namespace first
kubectl apply -f k8s/namespace.yaml

# Apply the rest of the manifests
kubectl apply -f k8s/ -n rag-app

echo "⏳ Waiting for pods to become ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n rag-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=rag-app -n rag-app --timeout=300s

echo "🌐 Setting up Port Forwarding for the frontend..."
echo "Access your app at: http://localhost:8501"
echo "Press Ctrl+C to stop port forwarding."

# Forward the Streamlit port to localhost
kubectl port-forward svc/rag-app-service 8501:8501 -n rag-app