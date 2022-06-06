module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "17.24.0"
  kubeconfig_api_version = "client.authentication.k8s.io/v1beta1"

  cluster_name    = "${local.cluster_id}-eks"
  cluster_version = "1.22"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    application = {
      name_prefix      = "hashicorp"
      instance_types   = ["t3a.medium"]
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2
    }
  }
}

resource "helm_release" "vault-secret-injector" {
  chart            = "vault"
  name             = "vault-secret-injector"
  namespace        = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  cleanup_on_fail  = true
  force_update     = false
  create_namespace = true
  timeout          = 300
  set {
    name  = "injector.enabled"
    value = "true"
  }
  set {
    name = "injector.externalVaultAddr"
    value = "https://tapuhi-aidoc-vault-private-vault-34504ffe.f7ee9677.z1.hashicorp.cloud:8200"
  }
}

resource "helm_release" "cert-manager-helm-release" {
  chart            = "cert-manager"
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.8.0"
  cleanup_on_fail  = true
  force_update     = false
  create_namespace = true
  timeout          = 300
  set {
    name  = "installCRDs"
    value = "true"
  }
}

## ---------- Self-hosted runners installation ----------
resource "helm_release" "self-hosted-runners-controller" {
  chart            = "actions-runner-controller"
  name             = "actions-runner-controller"
  namespace        = "actions-runner-system"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  cleanup_on_fail  = true
  create_namespace = true
  force_update     = false
  wait             = false
  timeout          = 300
}


resource "kubernetes_manifest" "tapuhi-self-hosted-" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind"       = "RunnerDeployment"
    "metadata" = {
      "name"      = "tapuhi-self-hosted-deploy"
      "namespace" = "actions-runner-system"
    }
    "spec" = {
      "replicas" = 2
      "template" = {
        "spec" = {
          "repository" = "tapuhi-org/aidoc-devops-task"
          "serviceAccountName" : "actions-runner-controller"
        }
      }
    }
  }
}