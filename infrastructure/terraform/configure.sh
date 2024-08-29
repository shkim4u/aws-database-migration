#!/bin/bash

if [  $# -le 1 ]
then
    echo "Usage: $0 <Terraform Workspace> <AWS_REGION>"
    return 1
fi

# Caution!: Clean up the previous terraform state.
#terraform state rm $(terraform state list)
#rm -rf .terraform.lock.hcl
#rm -rf terraform.tfstate*
#rm -rf tfplan
#rm -rf .terraform

# First try to select terraform workspace.
terraform workspace select $1
if [ $? -eq 0 ]
then
    echo "Workspace <$1> exists, which to be deleted for freshness."
    terraform workspace delete $1
fi

#echo "Seems to be a fresh terraform workspace: <$1>. Creating a new one..."
echo "Creating a new fresh workspace <$1>..."
terraform workspace new $1
terraform workspace select $1

echo "Terraform workspace <$1> selected"

AWS_REGION=$2
echo "AWS_REGION selected: ${AWS_REGION}"

###
### Some other things to initialize from here.
###
process_certificate() {
  local CA_ARN=$1

  # 2. Generate a certificate signing request (CSR).
  aws acm-pca get-certificate-authority-csr --region ${AWS_REGION} \
       --certificate-authority-arn ${CA_ARN} \
       --output text > ca.csr

  # 3. View and verify the contents of the CSR.
  openssl req -text -noout -verify -in ca.csr

  # 4. Issue a Root CA certificate.
  export CERTIFICATE_ARN=`aws acm-pca issue-certificate --region ${AWS_REGION} --certificate-authority-arn ${CA_ARN} --csr fileb://ca.csr --signing-algorithm SHA256WITHRSA --template-arn arn:aws:acm-pca:::template/RootCACertificate/V1 --validity Value=3650,Type=DAYS | jq --raw-output .CertificateArn`
  echo $CERTIFICATE_ARN

  # 5. Get the Root CA certificate.
  aws acm-pca get-certificate --region ${AWS_REGION} \
    --certificate-authority-arn ${CA_ARN} \
    --certificate-arn ${CERTIFICATE_ARN} \
    --output text > cert.pem

  # 6. View the certificate information with OpenSSL.
  openssl x509 -in cert.pem -text -noout

  # 7. Import the Root CA certificate into the CA.
  aws acm-pca import-certificate-authority-certificate --region ${AWS_REGION} \
       --certificate-authority-arn ${CA_ARN} \
       --certificate fileb://cert.pem

  # 8. Check the status of the private CA. Confirm it's ACTIVE.
  aws acm-pca describe-certificate-authority --region ${AWS_REGION} \
    --certificate-authority-arn ${CA_ARN} \
    --output json --no-cli-pager
}


# 0. [2024-02-26] KSH: Check if the PCA is already there. If so, skip the PCA creation.
# List all certificate authorities
authorities=$(aws acm-pca list-certificate-authorities --region ${AWS_REGION} --output json)
# Loop through each certificate authority
for row in $(echo "${authorities}" | jq -r '.CertificateAuthorities[] | @base64'); do
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
    }

    arn=$(_jq '.Arn')

    # Get the tags for the current certificate authority
    tags=$(aws acm-pca list-tags --certificate-authority-arn ${arn} --region ${AWS_REGION} --output json)

    # Check if the "Name" tag is "AwsProservePCA"
    if echo "${tags}" | jq -e ' .Tags[] | select(.Key=="Name" and .Value=="AwsProservePCA")' > /dev/null; then
        # If the tag matches, print the certificate authority
        echo ${row} | base64 --decode

        # Set the found CA_ARN.
        export CA_ARN=$arn
    fi
done

# If CA_ARN is not set, then the PCA was not found and we should create it
if [ -z "$CA_ARN" ]; then
    echo "Private CA is not found. Creating a new one..."

    # 1. Create Private Certificate Authority.
    export CA_ARN=`aws acm-pca create-certificate-authority --region ${AWS_REGION} --certificate-authority-configuration file://ca-config.txt --revocation-configuration file://ocsp-config.txt --certificate-authority-type "ROOT" --idempotency-token 01234567 --tags Key=Name,Value=AwsProservePCA | jq --raw-output .CertificateAuthorityArn`
    echo $CA_ARN

    # (Optional) For Terraform
    export TF_VAR_ca_arn=${CA_ARN}
    echo $TF_VAR_ca_arn

    # Wait for a while so that the private CA is completed to be created.
    # TODO: Do more elegantly by probing with AWS API.
    #echo "Wait for 10 secs for the private CA is ready to go."
    #sleep 10
    STATUS=""
    while [ "$STATUS" != "PENDING_CERTIFICATE" ]; do
      # Ge the current status of the PCA.
      STATUS=$(aws acm-pca describe-certificate-authority --region ${AWS_REGION} --certificate-authority-arn ${CA_ARN} --query "CertificateAuthority.Status" --output text)

      if [ "$STATUS" != "PENDING_CERTIFICATE" ]; then
        echo "Private CA is not yet ready to install its root CA certificate. Waiting for 5 seconds..."
        sleep 5
      fi
    done
    echo "Private CA is ready to go to install root CA certificate."

    process_certificate "${CA_ARN}"
else
    echo ""
    echo "Private CA is already there. Skipping the PCA creation."
    echo "$CA_ARN"
    export TF_VAR_ca_arn=${CA_ARN}
    echo $TF_VAR_ca_arn

    # Ge the current status of the PCA.
    STATUS=$(aws acm-pca describe-certificate-authority --region ${AWS_REGION} --certificate-authority-arn ${CA_ARN} --query "CertificateAuthority.Status" --output text)
    # Check if STATUS is PENDING_CERTIFICATE.
    if [ "$STATUS" = "PENDING_CERTIFICATE" ]; then
        echo "Private CA is waiting to be installed with a CA certificate. Generating one and installing it..."
        process_certificate "${CA_ARN}"
        echo "CA certificate is installed into private CA=[${CA_ARN}]."
    fi
fi

# 9. Randomize EKS KMS Key Alias.
export TF_VAR_eks_cluster_production_name=M2M-EksCluster-Production-$(date +'%Y%m%d') && echo $TF_VAR_eks_cluster_production_name
export TF_VAR_eks_cluster_staging_name=M2M-EksCluster-Staging-$(date +'%Y%m%d') && echo $TF_VAR_eks_cluster_staging_name

env | grep TF_VAR

# 10. Helm repository 추가
# - Bitname: Django-DefectDojo dependencies.
helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update
