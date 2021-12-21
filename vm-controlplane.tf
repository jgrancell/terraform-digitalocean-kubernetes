resource "digitalocean_droplet" "controlplane" {
  count = var.controlplane.count
  image = coalesce(var.os.image, data.digitalocean_images.main.images.0.slug)

  name   = "ctrl-${count.index + 1}.${var.service_tier}.${var.customer_group}-k8s.com"
  region = element(var.regions, count.index)
  size   = coalesce(var.controlplane.plan, data.digitalocean_sizes.main["controlplane"].sizes.0.slug)

  backups     = local.provider_config.backups
  monitoring  = local.provider_config.monitoring
  ipv6        = local.provider_config.ipv6_networking
  resize_disk = local.provider_config.resize_disk

  ssh_keys = [
    data.digitalocean_ssh_key.main.fingerprint
  ]

  tags = [
    digitalocean_tag.controlplane.name
  ]
}