#!/bin/bash
set -e

echo -e "\e[94m[*] Memulai instalasi TCP BBR dan optimasi jaringan...\e[0m"

# === Aktifkan modul BBR jika ada
modprobe tcp_bbr || echo "tcp_bbr tidak tersedia, lanjutkan dengan sysctl saja."
echo "tcp_bbr" | tee /etc/modules-load.d/bbr.conf >/dev/null

# === Konfigurasi sysctl untuk BBR & performa jaringan
sysctl_config="/etc/sysctl.conf"

add_sysctl() {
    grep -qxF "$1" $sysctl_config || echo "$1" >> $sysctl_config
}

add_sysctl "net.core.default_qdisc = fq"
add_sysctl "net.ipv4.tcp_congestion_control = bbr"
add_sysctl "net.ipv4.ip_forward = 1"
add_sysctl "fs.file-max = 65535"
add_sysctl "net.core.rmem_max = 67108864"
add_sysctl "net.core.wmem_max = 67108864"
add_sysctl "net.ipv4.tcp_rmem = 4096 87380 67108864"
add_sysctl "net.ipv4.tcp_wmem = 4096 65536 67108864"
add_sysctl "net.core.somaxconn = 1024"
add_sysctl "net.ipv4.tcp_syncookies = 1"

# === Terapkan konfigurasi
sysctl -p

# === Cek apakah BBR aktif
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr && lsmod | grep -q bbr; then
    echo -e "\e[92m[+] TCP BBR berhasil diaktifkan!\e[0m"
else
    echo -e "\e[93m[!] BBR belum aktif atau kernel tidak mendukung. Cek kernel VPS.\e[0m"
fi