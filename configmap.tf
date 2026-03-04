resource "kubernetes_config_map" "modsecurity_nginx_config_validator" {
  count = var.enable_modsec ? 1 : 0

  metadata {

    name      = "modsecurity-nginx-config-validator"
    namespace = "ingress-controllers"
    labels = {
      "k8s-app" = var.controller_name
    }
  }
  data = {
    "modsecurity.conf" = file("${path.module}/templates/modsecurity.conf"),
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}