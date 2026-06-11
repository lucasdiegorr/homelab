# Usage
ansible-playbook -i inventory.yml playbook.yml

# With secrets
ansible-playbook -i inventory.yml playbook.yml \
  -e duckdns_token=your_token \
  -e tailscale_auth_key=your_key \
  -e cloudflare_account_id=your_id \
  -e cloudflare_api_token=your_token \
  -e wifi_password=your_password \
  -e ssh_authorized_keys='["ssh-ed25519 AAA..."]'
