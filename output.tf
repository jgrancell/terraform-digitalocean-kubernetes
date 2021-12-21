output "ips" {
  value = {
    "controlplane" = digitalocean_droplet.controlplane[*].ipv4_address
    "workers"      = digitalocean_droplet.worker[*].ipv4_address
    "loadbalancers" = digitalocean_loadbalancer.main[*].ip
  }
}

output "cost" {
  value = {
    "controlplane"  = data.digitalocean_sizes.main["controlplane"].sizes.0.price_monthly * var.controlplane.count
    "workers"       = data.digitalocean_sizes.main["workers"].sizes.0.price_monthly * var.workers.count
    "loadbalancers" = local.loadbalancer_price * length(digitalocean_loadbalancer.main)
    "total"         = (data.digitalocean_sizes.main["controlplane"].sizes.0.price_monthly * var.controlplane.count) + (data.digitalocean_sizes.main["workers"].sizes.0.price_monthly * var.workers.count) + (local.loadbalancer_price * length(digitalocean_loadbalancer.main))
  }
}