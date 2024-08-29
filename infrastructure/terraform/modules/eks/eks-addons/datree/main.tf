/**
 * References:
 * - [Read This]: https://aws.amazon.com/blogs/containers/preventing-kubernetes-misconfigurations-using-datree/
 * - https://hub.datree.io/dashboard/account-token
 * - https://app.datree.io/clusters
 *
 * Commands to install:
 * 1. helm repo add datree-webhook https://datreeio.github.io/admission-webhook-datree
 * 2. helm repo update
 * 3. helm install -n datree datree-webhook datree-webhook/datree-admission-webhook --debug \
--create-namespace \
--set datree.token=0a6ede1b-3687-463b-ad89-24575982ab79 \
--set datree.clusterName=$(kubectl config current-context
