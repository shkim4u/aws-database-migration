resource "helm_release" "istio_base" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "base"
  name  = "istio-base"
  namespace = "istio-system"
  create_namespace = true
  wait = true
  wait_for_jobs = true
  timeout = 3600
}

resource "helm_release" "istiod" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "istiod"
  name  = "istiod"
  namespace = "istio-system"
  create_namespace = false
  wait = true
  wait_for_jobs = true
  depends_on = [helm_release.istio_base]
  timeout = 3600
}

/*
 * Related issue
 * Internal error occurred: failed calling webhook "object.sidecar-injector.istio.io
status:                                                                                                                                                                                              │
│   conditions:                                                                                                                                                                                        │
│   - lastTransitionTime: "2023-08-07T14:07:02Z"                                                                                                                                                       │
│     message: 'Internal error occurred: failed calling webhook "object.sidecar-injector.istio.io":                                                                                                    │
│       failed to call webhook: Post "https://istiod.istio-system.svc:443/inject?timeout=10s":                                                                                                         │
│       context deadline exceeded'                                                                                                                                                                     │
│     reason: FailedCreate                                                                                                                                                                             │
│     status: "True"                                                                                                                                                                                   │
│     type: ReplicaFailure                                                                                                                                                                             │
│   observedGeneration: 1                                                                                                                                                                              │
│   replicas: 0
* Other references:
* - https://istio.io/latest/docs/setup/additional-setup/gateway/
* - https://discuss.istio.io/t/internal-error-occurred-failed-calling-webhook-namespace-sidecar-injector-istio-io-post-https-istiod-istio-system-svc-443-inject-timeout-10s-context-deadline-exceeded/13531/2
 */
resource "helm_release" "istio_gateway" {
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "gateway"
  name = "istio-ingressgateway"
  namespace = "istio-system"
  create_namespace = false

  set {
    name = "replicaCount"
    value = 1
  }

  set {
    name  = "autoscaling.minReplicas"
    value = 1
  }

  wait = true
  wait_for_jobs = true
#  timeout = 600
  depends_on = [helm_release.istiod]
  timeout = 3600
}
