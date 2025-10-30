#!/bin/bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD pods..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=180s

echo "Expose ArgoCD Dashboard on port 8082..."
kubectl port-forward svc/argocd-server -n argocd 8082:443 &
echo "ArgoCD running at: https://localhost:8082"