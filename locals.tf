locals {
  loadbalancer_price = "10"

  provider_config = defaults(var.provider_config, {
    backups            = false,
    ipv6_networking    = false,
    monitoring         = false, 
    resize_disk        = false,
    vault_firewall_tag = "core::vault",
  })

  common_filters = {
    available = ["true"]
    regions   = var.regions
  }

  size_filters = {
    controlplane = merge(local.common_filters, {
      slug      = var.controlplane.cpu_intensive ? ["^s-\\dvcpu-\\dgb-amd$"] : ["^s-\\dvcpu-\\d+gb$"]
      vcpus     = [var.controlplane.cpus]
      memory    = [var.controlplane.memory]
    })

    workers = merge(local.common_filters, {
      slug      = var.workers.cpu_intensive ? ["^s-\\dvcpu-\\dgb-amd$"] : ["^s-\\dvcpu-\\d+gb$"]
      vcpus     = [var.workers.cpus]
      memory    = [var.workers.memory]
    })
  }

  size_sorters = {
    price_monthly = "asc"
    disk          = "desc"
  }

  admin_ips_string = var.admin_ips
  admin_ips        = split(",", local.admin_ips_string)
}