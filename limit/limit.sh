#!/bin/bash
set -e

REPO="https://raw.githubusercontent.com/rizxddev/kont/main/"

# === Unduh file systemd service
wget -q -O /etc/systemd/system/limitvmess.service "${REPO}limit/limitvmess.service"
wget -q -O /etc/systemd/system/limitvless.service "${REPO}limit/limitvless.service"
wget -q -O /etc/systemd/system/limittrojan.service "${REPO}limit/limittrojan.service"
wget -q -O /etc/systemd/system/limitshadowsocks.service "${REPO}limit/limitshadowsocks.service"

# === Unduh script limit untuk masing-masing protocol
wget -q -O /etc/xray/limit.vmess "${REPO}limit/vmess"
wget -q -O /etc/xray/limit.vless "${REPO}limit/vless"
wget -q -O /etc/xray/limit.trojan "${REPO}limit/trojan"
wget -q -O /etc/xray/limit.shadowsocks "${REPO}limit/shadowsocks"

# === Set permission
chmod +x /etc/xray/limit.*

# === Reload & aktifkan service
systemctl daemon-reexec
systemctl daemon-reload

systemctl enable --now limitvmess limitvless limittrojan limitshadowsocks

echo -e "\e[92m[+] Semua limit service berhasil diaktifkan dan berjalan.\e[0m"