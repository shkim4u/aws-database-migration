#!/bin/bash

# Check if argocd is installed.
if [ -z `which argocd` ]; then
  echo "argocd is not installed."
  ehho "Install argocd first by running install-argocd-cli.sh."
  exit 1
fi

# Check if the number of argument is 2.
if [ $# -ne 2 ]; then
  echo "Usage: $0 <argocd-admin-password> <AWS Secrets Manager SecretID>: (eg)hotelspecials-ci-argocd-admin-password>"
  exit 1
fi

# Set passwd as the first argument.
ARGOCD_ADMIN_PASSWD=$1
AWS_SECRETS_MANAGER_SECRET_ID=$2

# Test if AWS_SECRETS_MANAGER_SECRET_ID is set.
if [ -z "${AWS_SECRETS_MANAGER_SECRET_ID}" ]; then
  echo "AWS_SECRETS_MANAGER_SECRET_ID is not set."
  echo "Skip setting the AWS Secrets Manager SecretID."
else
  echo "Setting the AWS Secrets Manager SecretID: [${AWS_SECRETS_MANAGER_SECRET_ID}]..."
  # Set AWS Secrets Manager SecretID.
  aws secretsmanager put-secret-value --secret-id ${AWS_SECRETS_MANAGER_SECRET_ID} --secret-string "${ARGOCD_ADMIN_PASSWD}"
fi
