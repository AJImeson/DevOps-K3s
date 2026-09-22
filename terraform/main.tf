resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "hcloud_network" "grupp4-k3s" {
  name     = "${var.prefix}-net"
  ip_range = var.vnet_cidr
}

resource "hcloud_network_subnet" "grupp4-k3s" {
  network_id   = hcloud_network.grupp4-k3s.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = var.subnet_cidr
}

resource "hcloud_firewall" "grupp4-k3s" {
  name = "${var.prefix}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "2522"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = var.user_ip
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "grupp4-k3s" {
  count        = var.node_count
  name         = "${var.prefix}-nod${count.index}"
  server_type  = var.server_type
  image        = var.image
  location     = var.location
  firewall_ids = [hcloud_firewall.grupp4-k3s.id]

  network {
    network_id = hcloud_network_subnet.grupp4-k3s.network_id
    ip         = "10.20.1.${count.index + 1}"
  }

  user_data = <<-EOT
    #cloud-config
    users:
      - name: ${var.admin_user}
        groups: sudo
        shell: /bin/bash
        sudo: 'ALL=(ALL) NOPASSWD:ALL'
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    disable_root: true
    ssh_pwauth: false
    write_files:
      - path: /etc/ssh/sshd_config.d/99-grupp4.conf
        content: |
          Port 2522
      - path: /etc/netplan/99-private.yaml
        permissions: '0600'
        content: |
          network:
            version: 2
            ethernets:
              enp7s0:
                dhcp4: true
    runcmd:
      - systemctl disable --now ssh.socket
      - systemctl enable --now ssh.service
      - netplan apply
  EOT

  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_server_network" "grupp4-k3s" {
  count     = var.node_count
  server_id = hcloud_server.grupp4-k3s[count.index].id
  subnet_id = hcloud_network_subnet.grupp4-k3s.id
}

resource "local_file" "inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0600"
  content = templatefile("${path.module}/inventory.tmpl", {
    server_ip         = hcloud_server.grupp4-k3s[0].ipv4_address
    server_private_ip = hcloud_server_network.grupp4-k3s[0].ip
    agent_ips         = slice(hcloud_server.grupp4-k3s[*].ipv4_address, 1, var.node_count)
    agent_private_ips = slice(hcloud_server_network.grupp4-k3s[*].ip, 1, var.node_count)
    admin_user        = var.admin_user
    k3s_token         = random_password.k3s_token.result
  })
}
