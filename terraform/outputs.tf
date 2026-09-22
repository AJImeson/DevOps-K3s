output "public_ips" {
  value = hcloud_server.grupp4-k3s[*].ipv4_address
}

output "private_ips" {
  value = hcloud_server_network.grupp4-k3s[*].ip
}

output "ssh" {
  value = [
    for ip in hcloud_server.grupp4-k3s[*].ipv4_address :
    "ssh -p 2522 ${var.admin_user}@${ip}"
  ]
}

output "server_ip" {
  value = hcloud_server.grupp4-k3s[0].ipv4_address
}

output "server_private_ip" {
  value = hcloud_server_network.grupp4-k3s[0].ip
}

output "k3s_token" {
  value     = random_password.k3s_token.result
  sensitive = true
}
