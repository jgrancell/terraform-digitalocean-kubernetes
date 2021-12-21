data "digitalocean_ssh_key" "main" {
    name = "Mainkey"
}

data "digitalocean_project" "main" {
    name = "K8S ${upper(var.customer_group)}"
}

data "digitalocean_sizes" "main" {
  for_each = toset(["controlplane", "workers"])

  dynamic "filter" {
    for_each = local.size_filters[each.value]
    content {
      key    = filter.key
      values = filter.value
      all    = true

      match_by = filter.key == "slug" ? "re" : "exact"
    }
  }

  dynamic "sort" {
    for_each = local.size_sorters
    content {
      key       = sort.key
      direction = sort.value
    }
  }
}

data "digitalocean_images" "main" {
  filter {
    key      = "slug"
    values   = [var.os.name, var.os.major_version, "x64"]
    all      = true
    match_by = "substring"
  }

  filter {
    key = "private"
    values = ["false"]
  }

  sort {
    key = "created"
    direction = "desc"
  }
}