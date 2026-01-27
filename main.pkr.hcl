packer {
  required_plugins {
    name = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "api_url" {}
variable "token_id" {}
variable "token_secret" {}

source "proxmox-clone" "debian" {
  proxmox_url              = var.api_url
  username             = var.token_id
  token             = var.token_secret

  node = "ermes"
  clone_vm_id = 104 # EXISTING TEMPLATE
  vm_id       = 140 # NEW VM/TEMPLATE
  vm_name     = "packer-temp"

  cores  = 2
  memory = 2048

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ssh_username = "moody"
  ssh_timeout  = "10m"
}

build {
  sources = ["source.proxmox-clone.debian"]


  provisioner "shell-local" {
    inline = [
      "curl -k -X DELETE -H 'Authorization: PVEAPIToken=root@pam!packer=295testextestetestd' \"https://ermes:8006/api2/json/nodes/ermes/qemu/140\""
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y btop",
    ]
  }
}
