variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  default     = "2414808b70222ef715e330f232684a3e"
}

variable "zone_name" {
  description = "Cloudflare zone domain name"
  type        = string
  default     = "lucasrocha.dpdns.org"
}

variable "tunnel_name" {
  description = "Cloudflare Tunnel name"
  type        = string
  default     = "Homelab"
}

variable "origin_ip" {
  description = "Internal IP of the Traefik LoadBalancer"
  type        = string
  default     = "192.168.0.100"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token for Terraform provider"
  type        = string
  sensitive   = true
}

variable "origin_port" {
  description = "Traefik web entrypoint port"
  type        = number
  default     = 80
}
