data "cloudflare_zone" "zone" {
  filter = {
    name = var.zone_name
  }
}

data "cloudflare_zero_trust_tunnel_cloudflareds" "tunnel" {
  account_id = var.account_id
  name       = var.tunnel_name
}
