#!/bin/bash
# Auto Installer untuk Shadow Tunneling All-in-One

apt update -y && apt upgrade -y
apt install -y wget curl ruby unzip socat net-tools cron iptables-persistent lsof gnupg jq
gem install lolcat

# Ambil dan jalankan premi.sh
wget -q https://raw.githubusercontent.com/rizxddev/kont/main/premi.sh -O premi.sh
chmod +x premi.sh
./premi.sh

# Langsung install menu utama
wget -q https://raw.githubusercontent.com/rizxddev/kont/main/menu/menu.sh -O /usr/bin/menu
chmod +x /usr/bin/menu

# Jalankan menu (atau panel/setup kalau mau)
menu
