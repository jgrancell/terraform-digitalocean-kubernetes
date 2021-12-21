resource "digitalocean_tag" "controlplane" {
  name = "k8s::${var.customer_group}::${var.service_tier}::controlplane"
}

resource "digitalocean_tag" "worker" {
  name = "k8s::${var.customer_group}::${var.service_tier}::worker"
}

resource "digitalocean_tag" "loadbalancer" {
  name = "k8s::${var.customer_group}::${var.service_tier}::loadbalancer"
}

resource "digitalocean_firewall" "controlplane" {
  count = var.controlplane.count == 0 ? 0 : 1
  name = replace(digitalocean_tag.controlplane.name, "::", "-")

  tags = [
    digitalocean_tag.controlplane.name
  ]

  ## Allowing all TCP+UDP from same group+tier controlplanes and workers
  dynamic "inbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol    = inbound_rule.value
      port_range  = "all"
      source_tags = [
        digitalocean_tag.controlplane.name,
        digitalocean_tag.worker.name
      ]
    }
  }

  ## Vault access to controlplane for reviewer
  inbound_rule {
    protocol    = "tcp"
    port_range  = 6443
    source_tags = [
      local.provider_config.vault_firewall_tag
    ]
  }

  ## Admin access
  dynamic "inbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol         = inbound_rule.value
      port_range       = "all"
      source_addresses = local.admin_ips
    }
  }

  dynamic "outbound_rule" {
    for_each = ["tcp", "udp", "icmp"]
    content {
      protocol              = outbound_rule.value
      port_range            = outbound_rule.value == "icmp" ? null : "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}

resource "digitalocean_firewall" "worker" {
  count = var.workers.count == 0 ? 0 : 1
  name = replace(digitalocean_tag.worker.name, "::", "-")

  tags = [
    digitalocean_tag.worker.name
  ]

  ## Allowing all TCP+UDP from same group+tier controlplanes and workers
  dynamic "inbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol    = inbound_rule.value
      port_range  = "all"
      source_tags = [
        digitalocean_tag.controlplane.name,
        digitalocean_tag.worker.name
      ]
    }
  }

  ## Loadbalancer 443+80 mappings
  inbound_rule {
    protocol    = "tcp"
    port_range  = 32443
    source_load_balancer_uids = digitalocean_loadbalancer.main[*].id
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = 32080
    source_load_balancer_uids = digitalocean_loadbalancer.main[*].id
   }

  ## Admin access
  dynamic "inbound_rule" {
    for_each = ["tcp", "udp"]
    content {
      protocol         = inbound_rule.value
      port_range       = "all"
      source_addresses = local.admin_ips
    }
  }

  dynamic "outbound_rule" {
    for_each = ["tcp", "udp", "icmp"]
    content {
      protocol              = outbound_rule.value
      port_range            = outbound_rule.value == "icmp" ? null : "all"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    }
  }
}