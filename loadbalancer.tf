
resource "digitalocean_loadbalancer" "main" {
  count  = var.controlplane.count >= 1 ? length(var.regions) : 0
  name   = "lb-${count.index + 1}.${var.service_tier}.${var.customer_group}-k8s.io"
  region = var.regions[count.index]

  enable_proxy_protocol = true

  forwarding_rule {
    entry_port = 80
    entry_protocol = "tcp"

    target_port = 32080
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port = 443
    entry_protocol = "tcp"

    target_port = 32443
    target_protocol = "tcp"
  }

  healthcheck {
    protocol               = "http"
    port                   = 32080
    path                   = "/healthz"
    check_interval_seconds = 3

  }

  droplet_tag = "k8s::${var.customer_group}::${var.service_tier}::worker"
}