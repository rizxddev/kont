#!/bin/bash
set -e

# === Deteksi OS ===
source /etc/os-release
if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
  echo "Script ini hanya untuk Ubuntu atau Debian."
  exit 1
fi

# === Update script menu (universal) ===
echo -e "\e[96m[+] Memperbarui script menu...\e[0m"

# Pastikan unzip terpasang
if ! command -v unzip >/dev/null 2>&1; then
  if command -v apt >/dev/null 2>&1; then
    apt update -y && apt install -y unzip
  else
    apt-get update -y && apt-get install -y unzip
  fi
fi

# Unduh dan pasang ulang menu
cd /root
wget -q https://raw.githubusercontent.com/rizxddev/kont/main/limit/menu.zip -O menu.zip
unzip -o menu.zip -d menu
chmod +x menu/*
mv -f menu/* /usr/local/sbin/
rm -rf menu menu.zip update.sh

echo -e "\e[92m[✓] Menu berhasil diperbarui.\e[0m"
echo -e "\e[90mTekan ENTER untuk kembali ke menu utama...\e[0m"
read
