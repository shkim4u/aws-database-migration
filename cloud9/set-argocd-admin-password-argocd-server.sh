#!/bin/bash

# Check if argocd is installed.
if [ -z `which argocd` ]; then
  echo "argocd is not installed."
  ehho "Install argocd first by running install-argocd-cli.sh."
  exit 1
fi

# Check if the number of argument is 2.
if [ $# -ne 2 ]; then
  echo "Usage: $0 <argocd-admin-password-old> <argocd-admin-password-new>"
  exit 1
fi

# Set passwd as the first argument.
ARGOCD_ADMIN_PASSWD_OLD=$1
ARGOCD_ADMIN_PASSWD_NEW=$2

# Get ArgoCD Server URL.
ARGOCD_SERVER=`kubectl get ingress/argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo "ARGOCD_SERVER: ${ARGOCD_SERVER}"

# Login to ArgoCD server with old password.
argocd login ${ARGOCD_SERVER} --username admin --password ${ARGOCD_ADMIN_PASSWD_OLD} --insecure --grpc-web
if [ $? -ne 0 ]; then
  echo "Failed to login to ArgoCD server with old password."
  exit 1
fi

# Set ArgoCD admin password.
argocd account update-password --current-password ${ARGOCD_ADMIN_PASSWD_OLD} --new-password ${ARGOCD_ADMIN_PASSWD_NEW} --grpc-web
if [ $? -ne 0 ]; then
  echo "Failed to set new ArgoCD admin password."
  exit 1
fi
