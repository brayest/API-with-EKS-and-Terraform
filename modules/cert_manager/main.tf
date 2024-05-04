
resource "helm_release" "cert_manager" {
  name  = "${var.cluster_name}-cert-manager"
  chart = "${path.module}/cert-manager"

  namespace = "cert-manager"
  create_namespace = true

  set {
    name = "installCRDs"
    value = true
  }

  # depends_on = [ null_resource.helm_uninstall ]
}

resource "helm_release" "cluster_issuer" {
  name  = "${var.cluster_name}-cluster-issuer"
  chart = "${path.module}/cluster_issuer"

  namespace = "cert-manager"
  create_namespace = true

  set {
    name = "ClusterName"
    value = var.cluster_name
  }

  set {
    name = "NotificationsEmail"
    value = var.notifications_email
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

### Private
# Generate a new private key
resource "tls_private_key" "private" {
  count = var.create_private_issuer ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a new self-signed certificate
resource "tls_self_signed_cert" "ca" {
  count = var.create_private_issuer ? 1 : 0

  private_key_pem = tls_private_key.private[0].private_key_pem

  subject {
    common_name  = "*.${var.private_domain}"
    organization = "Platform"
  }

  validity_period_hours = 87600  # 10 years
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]
}

# Create a Kubernetes secret
resource "kubernetes_secret" "ca_key_pair" {
  count = var.create_private_issuer ? 1 : 0

  metadata {
    name      = "ca-key-pair"
    namespace = "cert-manager" # update if your namespace is different
  }

  data = {
    "tls.crt" = trimspace(tls_self_signed_cert.ca[0].cert_pem)
    "tls.key" = trimspace(tls_private_key.private[0].private_key_pem)
  }

  type = "Opaque"

  depends_on = [ helm_release.cert_manager ]
}

resource "helm_release" "private_cluster_issuer" {
  count = var.create_private_issuer ? 1 : 0

  name  = "${var.cluster_name}-private-cluster-issuer"
  chart = "${path.module}/private_cluster_issuer"

  namespace = "cert-manager"

  set {
    name = "ClusterName"
    value = var.cluster_name
  }

  set {
    name = "NotificationsEmail"
    value = var.notifications_email
  }

  set {
    name = "internal_domain"
    value = var.private_domain
  }

  depends_on = [
    helm_release.cert_manager
  ]
}

