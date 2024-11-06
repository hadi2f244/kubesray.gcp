terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file(var.keyfile_location)
  region      = var.region
  project     = var.gcp_project_id
}

module "kubernetes" {
  source = "./modules/kubernetes-cluster"
  region = var.region
  prefix = var.prefix

  machines    = var.machines
  ssh_pub_key = var.ssh_pub_key

  master_sa_email    = var.master_sa_email
  master_sa_scopes   = var.master_sa_scopes
  master_preemptible = var.master_preemptible
  master_additional_disk_type = var.master_additional_disk_type
  worker_sa_email    = var.worker_sa_email
  worker_sa_scopes   = var.worker_sa_scopes
  worker_preemptible = var.worker_preemptible
  worker_additional_disk_type = var.worker_additional_disk_type

  ssh_whitelist        = var.ssh_whitelist
  api_server_whitelist = var.api_server_whitelist
  nodeport_whitelist   = var.nodeport_whitelist
  ingress_whitelist    = var.ingress_whitelist

  extra_ingress_firewalls = var.extra_ingress_firewalls
}

# Generate ansible inventory
#

locals {
  inventory = templatefile(
    "${path.module}/templates/inventory.tpl",
    {
      connection_strings_master = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s ip=%s etcd_member_name=etcd%d",
        keys(module.kubernetes.master_ip_addresses),
        values(module.kubernetes.master_ip_addresses).*.public_ip,
        values(module.kubernetes.master_ip_addresses).*.private_ip,
      range(1, length(module.kubernetes.master_ip_addresses) + 1)))
      connection_strings_worker = join("\n", formatlist("%s ansible_user=ubuntu ansible_host=%s ip=%s",
        keys(module.kubernetes.worker_ip_addresses),
        values(module.kubernetes.worker_ip_addresses).*.public_ip,
      values(module.kubernetes.worker_ip_addresses).*.private_ip))
      list_master = join("\n", keys(module.kubernetes.master_ip_addresses))
      list_worker = join("\n", keys(module.kubernetes.worker_ip_addresses))
      control_plane_lb_ip_address = module.kubernetes.control_plane_lb_ip_address
      ingress_controller_lb_ip_address = module.kubernetes.ingress_controller_lb_ip_address
    }
  )
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${local.inventory}' > ${var.inventory_file}"
  }

  triggers = {
    template = local.inventory
  }
}
