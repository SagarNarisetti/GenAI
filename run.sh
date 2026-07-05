set -e

# --- CONFIGURATION VARIABLES ---
AWS_ACCOUNT_ID="185990503656"
AWS_REGION="eu-west-1"
CLUSTER_NAME="mleng-eks-cluster"
NAMESPACE="rag-app"
IMAGE_NAME="rag-app"
TAG="latest"

# Derived Variables
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_URL="${ECR_REGISTRY}/${IMAGE_NAME}:${TAG}"
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/mleng-bedrock-pod-role"
SERVICE_ACCOUNT="bedrock-sa"

echo "🏃Starting automated deployment for cluster: ${CLUSTER_NAME}..."

# 1. Update local Kubernetes context to point to AWS EKS
echo "🏃Updating kubeconfig context..."

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

# 2. Authenticate Docker with AWS ECR
echo "🏃Logging into Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_REGISTRY"

# 3. Build, Tag, and Push the Docker Container
echo "🏃Building the local Docker image..."
docker build --platform linux/amd64 -t "${IMAGE_NAME}:${TAG}" -f ./app/Dockerfile .

echo "🏃Tagging image for remote registry..."
docker tag "${IMAGE_NAME}:${TAG}" "$FULL_IMAGE_URL"

echo "🏃Pushing image to Amazon ECR..."
docker push "$FULL_IMAGE_URL"

# 4. Handle EKS Pod Identity Agent Addon
echo "🏃Check EKS Pod Identity Agent Addon."
if ! aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name eks-pod-identity-agent >/dev/null 2>&1; then
    echo "Creating Pod Identity Agent addon..."
    aws eks create-addon --cluster-name "$CLUSTER_NAME" --addon-name eks-pod-identity-agent
else
    echo "🏃Pod Identity Agent addon is already installed."
fi

# 5. Handle IAM Pod Identity Association
echo "🏃Checking IAM Pod Identity Association..."
if ! aws eks list-pod-identity-associations --cluster-name "$CLUSTER_NAME" | grep -q "$SERVICE_ACCOUNT"; then
    echo "Creating Pod Identity Association in namespace: ${NAMESPACE}..."
    aws eks create-pod-identity-association --cluster-name "$CLUSTER_NAME" --namespace "$NAMESPACE" --service-account "$SERVICE_ACCOUNT" --role-arn "$ROLE_ARN"
else
    echo "🏃Pod Identity Association already exists."
fi

# 6. Deploy Kubernetes Manifests
echo "⚙️ Applying Kubernetes Namespace..."
kubectl apply -f k8s/namespace.yaml

# PREREQUISITE CHECK: Fail fast if envsubst is missing from your machine
if ! command -v envsubst &> /dev/null; then
    echo "Error: 'envsubst' is required to inject your AWS Account ID, but it is not installed."
    echo "To fix this, run:"
    echo "MacOS: brew install gettext"
    echo "Linux: sudo apt-get install gettext-base"
    exit 1
fi

echo " 🏃Resolving dynamic variables in deployment manifest and pushing to EKS..."
# Export variables so envsubst can see them
export AWS_ACCOUNT_ID AWS_REGION

# This line reads your placeholder-filled file, injects the IDs, and streams it to EKS
envsubst < k8s/deployment.yaml | kubectl apply -n "$NAMESPACE" -f -

echo "Applying remaining application manifests..."
#files without placeholders
kubectl apply -f k8s/secret.yaml -n "$NAMESPACE"
kubectl apply -f k8s/service.yaml -n "$NAMESPACE"

echo "Cloud deployment sequence completed successfully!"

echo "⏳ Waiting for pods to become ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n rag-app --timeout=120s
kubectl wait --for=condition=ready pod -l app=rag-app -n rag-app --timeout=300s

echo "🌐 Setting up Port Forwarding for the frontend..."
echo "Access your app at: http://localhost:8501"
echo "Press Ctrl+C to stop port forwarding."

kubectl port-forward svc/rag-app-service -n rag-app 8501:8501