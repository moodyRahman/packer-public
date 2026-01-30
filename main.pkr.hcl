packer {
  required_plugins {
    name = {
      version = ">= 1.2.2"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "api_url" {}
variable "token_id" {}
variable "token_secret" {}
variable "vm_id" {}
variable "base_passwd" {}
variable "vm_name" {}



source "proxmox-clone" "debian" {
  proxmox_url              = var.api_url
  username             = var.token_id
  token             = var.token_secret

  node = "ermes"
  clone_vm_id = 104 # EXISTING TEMPLATE
  vm_id       = var.vm_id # NEW VM/TEMPLATE
  vm_name     = var.vm_name
  ssh_username = "moody"
  ssh_password = var.base_passwd

  cores  = 1
  memory = 1024

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ssh_timeout  = "10m"
}

build {
  sources = ["source.proxmox-clone.debian"]

  # provisioner "shell-local" {
  #   inline = [
  #     "curl -k -X PUT -H 'Authorization: PVEAPIToken=${var.token_id}=${var.token_secret}' -d \"protection=0\"   \"${var.api_url}/nodes/ermes/qemu/${var.vm_id}/config\" "
  #   ]
  # }

  provisioner "shell" {
    inline = [
      "sudo usermod -aG sudo moody",
      "echo 'moody ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers >/dev/null && sudo visudo -cf /etc/sudoers"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo apt install pipx",
      "pipx install --include-deps ansible",
      "pipx ensurepath"
    ]
  }
  

  provisioner "ansible" {
    playbook_file = "./base_image/apt-dependencies.yml"
  }

  # provisioner "shell" {
  #   inline = [
  #     "sudo apt-get update",
  #     "sudo apt-get install -y dnsutils nmap iperf3 traceroute lsof tcpdump socat",
  #     "sudo apt-get install -y curl wget git unzip gnupg lsb-release ca-certificates jq net-tools iproute2",
  #     "sudo apt-get install -y htop btop sysstat iotop iftop nload duf",
  #     "sudo apt-get install -y cloud-init",
  #     "sudo usermod -aG sudo moody",
  #     "echo 'moody ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers >/dev/null && sudo visudo -cf /etc/sudoers"
  #   ]
  # }

}

