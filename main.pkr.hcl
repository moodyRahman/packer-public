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
variable "vm_id" {}


source "proxmox-clone" "debian" {
  proxmox_url              = var.api_url
  username             = var.token_id
  token             = var.token_secret

  node = "ermes"
  clone_vm_id = 104 # EXISTING TEMPLATE
  vm_id       = var.vm_id # NEW VM/TEMPLATE
  vm_name     = "packer-temp"

  cores  = 1
  memory = 1024

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ssh_username = "moody"
  ssh_timeout  = "10m"
}

build {
  sources = ["source.proxmox-clone.debian"]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install -y btop",
    ]
  }
}
