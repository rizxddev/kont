#!/bin/bash
set -euo pipefail

# === Konfigurasi Domain dan Cloudflare ===
DOMAIN="klmpk-tunneling.my.id"
CF_ID="andyyuda41@gmail.com"
CF_KEY="0d626234700bad388d6d07b49c42901445d1c"

# === Pastikan dependensi universal ===
if ! command -v jq >/dev/null || ! command -v curl >/dev/null; then
  if command -v apt >/dev/null; then
    apt update -y && apt install -y jq curl
  else
    apt-get update -y && apt-get install -y jq curl
  fi
fi

# === Ambil IP dan buat subdomain random ===
IP=$(wget -qO- icanhazip.com)
SUB=$(</dev/urandom tr -dc a-z0-9 | head -c5)
DNS="${SUB}.${DOMAIN}"

# === Update DNS via Cloudflare API ===
echo "Mengupdate DNS untuk $DNS..."

ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" | jq -r .result[0].id)

RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${DNS}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" | jq -r .result[0].id)

if [[ "${#RECORD}" -le 10 ]]; then
  RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
    -H "X-Auth-Email: ${CF_ID}" \
    -H "X-Auth-Key: ${CF_KEY}" \
    -H "Content-Type: application/json" \
    --data '{"type":"A","name":"'"${DNS}"'","content":"'"${IP}"'","ttl":120,"proxied":false}' | jq -r .result.id)
fi

curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
  -H "X-Auth-Email: ${CF_ID}" \
  -H "X-Auth-Key: ${CF_KEY}" \
  -H "Content-Type: application/json" \
  --data '{"type":"A","name":"'"${DNS}"'","content":"'"${IP}"'","ttl":120,"proxied":false}' >/dev/null

# === Simpan domain ke file ===
echo "$DNS" | tee /root/domain /root/scdomain /etc/xray/domain /etc/v2ray/domain /etc/xray/scdomain >/dev/null
echo "IP=$DNS" > /var/lib/kyt/ipvps.conf

echo -e "\e[92m[✓] DNS berhasil diupdate: $DNS\e[0m"