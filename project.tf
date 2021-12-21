resource "digitalocean_project_resources" "main" {
  project = data.digitalocean_project.main.id

  resources = concat(
    digitalocean_droplet.controlplane[*].urn,
    digitalocean_droplet.worker[*].urn,
    digitalocean_loadbalancer.main[*].urn,
  )
}