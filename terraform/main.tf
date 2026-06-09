resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_config" {
  account_id = var.account_id
  tunnel_id  = data.cloudflare_zero_trust_tunnel_cloudflareds.tunnel.result[0].id
  source     = "cloudflare"

  config = {
    ingress = [
      {
        hostname = var.zone_name
        service  = "https://${var.origin_ip}:443"
        originRequest = {
          originServerName = var.zone_name
        }
      },
      {
        service = "http_status:404"
      }
    ]

    origin_request = {
      connect_timeout = 30
    }
  }
}

resource "cloudflare_dns_record" "apex" {
  zone_id = data.cloudflare_zone.zone.id
  name    = "@"
  type    = "CNAME"
  content = "${data.cloudflare_zero_trust_tunnel_cloudflareds.tunnel.result[0].id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}
