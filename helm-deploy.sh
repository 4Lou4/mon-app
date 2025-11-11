#!/bin/bash
# Helm deployment script - runs on host with access to Minikube

set -e

RELEASE_NAME="$1"
CHART_DIR="$2"
IMAGE="$3"
TAG="$4"
NAMESPACE="${5:-default}"

export KUBECONFIG=/home/louay/.kube/config

echo "Deploying with Helm..."
helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" \
  --set image.repository="$IMAGE" \
  --set image.tag="$TAG" \
  --namespace "$NAMESPACE" \
  --wait --timeout 120s

echo "Deployment complete!"
helm status "$RELEASE_NAME"
kubectl get pods -l app.kubernetes.io/instance="$RELEASE_NAME"
