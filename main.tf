##########
# Locals #
##########
locals {
  tags = join(", ", [for key, value in var.default_tags : "${key}=${value}"])
}

########
# Helm #
########

resource "helm_release" "nginx_ingress_validator" {
  name       = "nginx-ingress-${var.controller_name}-validator"
  chart      = "ingress-nginx"
  namespace  = "ingress-controllers"
  repository = "https://kubernetes.github.io/ingress-nginx"
  timeout    = 600
  version    = "4.14.3"

  values = [templatefile("${path.module}/templates/values.yaml.tpl", {
    metrics_namespace    = "ingress-controllers"
    replica_count        = var.replica_count
    controller_name      = var.controller_name
    controller_value     = "k8s.io/ingress-${var.controller_name}"
    enable_modsec        = var.enable_modsec
    enable_latest_tls    = var.enable_latest_tls
    enable_owasp         = var.enable_owasp
    enable_anti_affinity = var.enable_anti_affinity
    keepalive            = var.keepalive
    # https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#upstream-keepalive-time
    upstream_keepalive_time = var.upstream_keepalive_time
    # https://docs.aws.amazon.com/elasticloadbalancing/latest/network/network-load-balancers.html#cross-zone-load-balancing
    default                     = var.controller_name == "default" ? true : false
    name_override               = "ingress-${var.controller_name}-validator"
    memory_requests             = var.memory_requests
    memory_limits               = var.memory_limits
    fluent_bit_version          = var.fluent_bit_version
    modsec_nginx_cm_config_name = var.is_non_prod_modsec ? "modsecurity-nginx-config-${var.controller_name}" : "modsecurity-nginx-config"
    fluent_bit_config_name      = var.is_non_prod_modsec ? "fluent-bit-config-modsec-non-prod" : "fluent-bit-config"
    default_tags                = local.tags
    internal_load_balancer      = var.internal_load_balancer
  })]

  depends_on = [
    kubernetes_config_map.modsecurity_nginx_config,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}
