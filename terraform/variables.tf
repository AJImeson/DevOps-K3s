variable "prefix" {
  description = "Prefix"
  type        = string
  default     = "grupp4-k3s-axel"
}

variable "location" {
  description = "Location"
  type        = string
  default     = "hel1"
}

variable "server_type" {
  description = "Server type, K3s Node"
  type        = string
  default     = "cx23"
}

variable "image" {
  description = "Server image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "admin_user" {
  description = "SSH Username"
  type        = string
  default     = "grupp4"
}

variable "vnet_cidr" {
  description = "Private network address space"
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_cidr" {
  description = "Node Subnet prefix"
  type        = string
  default     = "10.20.1.0/24"
}

variable "user_ip" {
  description = "Permission for SSH to K3s"
  type        = list(string)
  validation {
    condition     = alltrue([for ip in var.user_ip : can(cidrhost(ip, 0))])
    error_message = "Each entry must be a valid CIDR"
  }
}

variable "node_count" {
  type    = number
  default = 3
}

variable "ssh_public_key" {
  type        = string
  description = "Pub.key injection"
  default     = "grupp4"
}
