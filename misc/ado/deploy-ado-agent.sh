#!/bin/bash
#
# Azure DevOps Self-Hosted Agent Deployment Script
#
# This script deploys an Azure DevOps self-hosted agent in your Kubernetes namespace
# and connects it to your sandbox's Docker-in-Docker service.
#
# Usage:
#   ./deploy-ado-agent.sh <ORG> <PAT_TOKEN> <POOL_NAME>
#
# Example:
#   ./deploy-ado-agent.sh brainupgrade-in YOUR_PAT_TOKEN K8s-Pool
#
# The script will:
# 1. Auto-detect your username from the current namespace
# 2. Generate the deployment manifest with your settings
# 3. Deploy it to your current namespace
# 4. Show the agent status and logs

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo "========================================"
    echo "$1"
    echo "========================================"
    echo ""
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we have arguments
if [ $# -lt 3 ]; then
    print_error "Missing required arguments!"
    echo ""
    echo "Usage: $0 <ORG> <PAT_TOKEN> <POOL_NAME>"
    echo ""
    echo "Arguments:"
    echo "  ORG         - Azure DevOps organization name (e.g., brainupgrade-in)"
    echo "  PAT_TOKEN   - Personal Access Token with Agent Pools (read, manage) scope"
    echo "  POOL_NAME   - Agent pool name (e.g., K8s-Pool)"
    echo ""
    echo "Example:"
    echo "  $0 brainupgrade-in abcd1234...xyz K8s-Pool"
    echo ""
    exit 1
fi

# Parse arguments
ORG="$1"
PAT_TOKEN="$2"
POOL_NAME="$3"

print_header "Azure DevOps Agent Deployment"

# Get current namespace
NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}')
if [ -z "$NAMESPACE" ]; then
    print_error "Could not detect current namespace. Set your namespace first:"
    echo "  kubectl config set-context --current --namespace=YOUR_NAMESPACE"
    exit 1
fi

print_info "Current namespace: $NAMESPACE"

# Use namespace as username (assuming namespace = username)
USERNAME="$NAMESPACE"
AGENT_NAME="k8s-agent-${USERNAME}-01"
AZP_URL="https://dev.azure.com/${ORG}"
DOCKER_HOST="tcp://${USERNAME}:2375"

print_info "Configuration:"
echo "  Organization: $ORG"
echo "  Agent Pool:   $POOL_NAME"
echo "  Agent Name:   $AGENT_NAME"
echo "  Docker Host:  $DOCKER_HOST"
echo ""

# Confirm deployment
read -p "Deploy agent with these settings? (y/n) " -n 1 -r </dev/tty
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Deployment cancelled by user"
    exit 0
fi

print_info "Generating deployment manifest..."

# Create the deployment manifest
MANIFEST=$(cat <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azdo-agent
  namespace: ${NAMESPACE}
  labels:
    app: azdo-agent
    user: ${USERNAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azdo-agent
  template:
    metadata:
      labels:
        app: azdo-agent
        user: ${USERNAME}
    spec:
      containers:
      - name: azdo-agent
        image: mcr.microsoft.com/devcontainers/universal:linux
        command: ["/bin/bash", "-c"]
        args:
          - |
            set -e
            if [ -z "\$AZP_URL" ]; then
              echo "error: missing AZP_URL environment variable"
              exit 1
            fi

            if [ -z "\$AZP_TOKEN" ]; then
              echo "error: missing AZP_TOKEN environment variable"
              exit 1
            fi

            if [ -z "\$AZP_POOL" ]; then
              echo "Using default pool"
              AZP_POOL=Default
            fi

            if [ -n "\$AZP_WORK" ]; then
              mkdir -p "\$AZP_WORK"
            fi

            export AGENT_ALLOW_RUNASROOT="1"

            cleanup() {
              if [ -e config.sh ]; then
                print_header "Cleanup. Removing Azure Pipelines agent..."
                ./config.sh remove --unattended --auth PAT --token "\$AZP_TOKEN"
              fi
            }

            print_header() {
              lightcyan='\033[1;36m'
              nocolor='\033[0m'
              echo "\${lightcyan}\$1\${nocolor}"
            }

            trap 'cleanup; exit 0' EXIT
            trap 'cleanup; exit 130' INT
            trap 'cleanup; exit 143' TERM

            print_header "1. Determining matching Azure Pipelines agent..."

            AZP_AGENT_PACKAGES=\$(curl -LsS \
                -u user:\$AZP_TOKEN \
                -H 'Accept:application/json;' \
                "\$AZP_URL/_apis/distributedtask/packages/agent?platform=linux-x64&top=1")

            AZP_AGENT_PACKAGE_LATEST_URL=\$(echo "\$AZP_AGENT_PACKAGES" | jq -r '.value[0].downloadUrl')

            if [ -z "\$AZP_AGENT_PACKAGE_LATEST_URL" ] || [ "\$AZP_AGENT_PACKAGE_LATEST_URL" == "null" ]; then
              echo "error: could not determine a matching Azure Pipelines agent"
              echo "check that account '\$AZP_URL' is correct and the token is valid for that account"
              exit 1
            fi

            print_header "2. Downloading and extracting Azure Pipelines agent..."
            cd /azp/_work

            if [ ! -f config.sh ]; then
              curl -LsS \$AZP_AGENT_PACKAGE_LATEST_URL | tar -xz
            else
              print_header "Agent already downloaded, skipping download..."
            fi

            print_header "3. Configuring Azure Pipelines agent..."
            ./config.sh --unattended \
              --agent "\${AZP_AGENT_NAME:-\$(hostname)}" \
              --url "\$AZP_URL" \
              --auth PAT \
              --token "\$AZP_TOKEN" \
              --pool "\${AZP_POOL:-Default}" \
              --work "\${AZP_WORK:-_work}" \
              --replace \
              --acceptTeeEula

            print_header "4. Running Azure Pipelines agent..."
            trap 'cleanup; exit 0' EXIT
            trap 'cleanup; exit 130' INT
            trap 'cleanup; exit 143' TERM

            chmod +x ./run.sh
            ./run.sh & wait \$!
        env:
        - name: AZP_URL
          value: "${AZP_URL}"
        - name: AZP_TOKEN
          value: "${PAT_TOKEN}"
        - name: AZP_AGENT_NAME
          value: "${AGENT_NAME}"
        - name: AZP_POOL
          value: "${POOL_NAME}"
        - name: DOCKER_HOST
          value: "${DOCKER_HOST}"
        - name: AZP_WORK
          value: "/azp/_work"
        - name: TZ
          value: "Asia/Kolkata"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: agent-work
          mountPath: /azp/_work
      volumes:
      - name: agent-work
        emptyDir: {}
      restartPolicy: Always
EOF
)

print_info "Deploying agent to namespace: $NAMESPACE"

# Apply the manifest
echo "$MANIFEST" | kubectl apply -f -

if [ $? -eq 0 ]; then
    print_success "Deployment created successfully!"
else
    print_error "Failed to create deployment"
    exit 1
fi

echo ""
print_info "Waiting for pod to start..."
sleep 3

# Check pod status
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app=azdo-agent -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ]; then
    print_success "Pod created: $POD_NAME"
    echo ""

    # Show pod status
    print_info "Pod status:"
    kubectl get pods -n "$NAMESPACE" -l app=azdo-agent

    echo ""
    print_info "Waiting for agent to initialize (this may take 30-60 seconds)..."
    echo ""

    # Follow logs for a few seconds
    timeout 10 kubectl logs -n "$NAMESPACE" -f "$POD_NAME" 2>/dev/null || true

    echo ""
    print_success "Agent deployment completed!"
    echo ""
    print_info "Next steps:"
    echo "  1. Verify agent is online in Azure DevOps:"
    echo "     Organization Settings → Agent pools → ${POOL_NAME} → Agents"
    echo ""
    echo "  2. View logs:"
    echo "     kubectl logs -f deployment/azdo-agent"
    echo ""
    echo "  3. Check status:"
    echo "     kubectl get pods -l app=azdo-agent"
    echo ""
    echo "  4. To delete the agent:"
    echo "     kubectl delete deployment/azdo-agent"
    echo ""
else
    print_warning "Pod not found yet. Check status with:"
    echo "  kubectl get pods -l app=azdo-agent"
    echo ""
    echo "View deployment status:"
    echo "  kubectl describe deployment azdo-agent"
fi

print_success "Deployment script completed!"
