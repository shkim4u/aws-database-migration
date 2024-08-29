/**
 * References
 * - https://github.com/hjacobs/kube-ops-view/blob/master/docs/user-guide.rst
 * - https://archive.eksworkshop.com/beginner/080_scaling/install_kube_ops_view/
 * - https://codeberg.org/hjacobs/kube-ops-view
 * - DO NOT USE THIS, EXCEPT FOR REFERENCE:
 *    ~ https://catalog.us-east-1.prod.workshops.aws/workshops/9c0aa9ab-90a9-44a6-abe1-8dff360ae428/ko-KR/100-scaling/300-kube-ops-view
 * - USE THIS TO INSTALL WITH HELM
 *    ~ https://artifacthub.io/packages/helm/christianknell/kube-ops-view
 *
 * (Use This) Commands to install:
helm repo add christianknell https://christianknell.github.io/helm-charts
helm repo update
helm install kube-ops-view christianknell/kube-ops-view
 *
 * View Kube Ops View
 * - http://localhost:8080/#scale=3
 */
