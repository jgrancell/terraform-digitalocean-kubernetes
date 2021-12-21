data "digitalocean_domain" "group-k8s" {
  name = "${var.customer_group}-k8s.com"
}

resource "digitalocean_record" "controlplane" {
  count  = var.controlplane.count
  domain = data.digitalocean_domain.group-k8s.name

  type  = "A"
  name  = "ctrl-${count.index +1}.${var.service_tier}"
  value = digitalocean_droplet.controlplane[count.index].ipv4_address
  ttl   = 600
}

resource "digitalocean_record" "worker" {
  count  = var.workers.count
  domain = data.digitalocean_domain.group-k8s.name

  type  = "A"
  name  = "wrkr-${count.index +1}.${var.service_tier}"
  value = digitalocean_droplet.worker[count.index].ipv4_address
  ttl   = 600
}

resource "digitalocean_record" "lb" {
  count  = var.controlplane.count == 0 ? 0 : length(var.regions)
  domain = data.digitalocean_domain.group-k8s.name

  type   = "A"
  name   = "lb.${var.service_tier}"
  value  = digitalocean_loadbalancer.main[count.index].ip
  ttl    = 600
}