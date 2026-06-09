output "zone_id" {
  value = data.cloudflare_zone.zone.id
}

output "tunnel_id" {
  value = data.cloudflare_zero_trust_tunnel_cloudflareds.tunnel.result[0].id
}

output "tunnel_status" {
  value = data.cloudflare_zero_trust_tunnel_cloudflareds.tunnel.result[0].status
}

output "dns_record_cname" {
  value = cloudflare_dns_record.apex.content
}
