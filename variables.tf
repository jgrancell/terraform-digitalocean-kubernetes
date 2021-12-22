variable "admin_ips" {
  description = "Comma-delineated list of IPs to allow admin access through the firewall"
  type        = string
}

variable "customer_group" {
  description = "The customer group we're assigning this cluster to."
  type        = string
}

variable "os" {
  description = "The operating system information that will be used to find an appropriate VM image."
  type        = object({
    distribution      = string
    image             = string
    long_term_support = bool
    major_version     = number
    minor_version     = number
    name              = string
  })
}

variable "regions" {
  description = "The Digitalocean Datacenters resources will be created in."
  type        = list(string)

  validation {
    condition = can(length(var.regions) >= 1)
    error_message = "You must provide either a var.region string or var.regions list to deploy cluster VMs to."
  }
}

variable "service_tier" {
  description = "The incidence tier we're assigning this cluster to."
  type        = string
}

## Controlplane/worker specific configurations
variable "controlplane" {
  description = "Configuration information for the Kubernetes controlplane nodes."
  type        = object({
    count         = number
    cpus          = number
    cpu_intensive = bool
    memory        = number
    plan          = string 
  })
}

variable "workers" {
  description = "Configuration information for the Kubernetes worker nodes."
  type        = object({
    count         = number
    cpus          = number
    cpu_intensive = bool
    memory        = number
    plan          = string
  })
}

variable "provider_config" {
  description = "The Digitalocean-specific configuration options available."
  type        = object({
    backups            = optional(bool)
    ipv6_networking    = optional(bool)
    monitoring         = optional(bool)
    resize_disk        = optional(bool)
    vault_firewall_tag = optional(string)
  })
  default = {}
}

