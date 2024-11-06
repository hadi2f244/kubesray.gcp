gcp_project_id     = "amazing-autumn-440715-d4"
region             = "us-central1"
ssh_pub_key        = "~/.ssh/id_ed25519.pub"
keyfile_location   = "/home/hadi/code/gcp/service-account.json"
prefix             = "development"
inventory_file = "inventory.ini"

ssh_whitelist      = ["0.0.0.0/0"]
api_server_whitelist = ["0.0.0.0/0"]
nodeport_whitelist = ["0.0.0.0/0"]
ingress_whitelist  = ["0.0.0.0/0"]

machines = {
  master-0 = {
    node_type = "master"
    size      = "e2-medium"
    zone      = "us-central1-a"
    additional_disks = {}
    boot_disk = {
      image_name = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240927"
      size       = 20
    }
  },
  worker-0 = {
    node_type = "worker"
    size      = "e2-medium"
    zone      = "us-central1-a"
    additional_disks = {
      extra-disk-1 = {
        size = 20
      }
    }
    boot_disk = {
      image_name = "ubuntu-os-cloud/ubuntu-2204-jammy-v20240927"
      size       = 20
    }
  },
}
