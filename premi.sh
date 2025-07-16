#!/bin/bash
set -e

# === DETEKSI OS ===
source /etc/os-release
if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
  echo "Script ini hanya untuk Ubuntu atau Debian."
  exit 1
fi

# === INSTALL DEPENDENSI ===
if command -v apt >/dev/null 2>&1; then
    apt update -y && apt upgrade -y
    apt install -y wget curl unzip socat net-tools cron iptables-persistent ruby lsof gnupg
else
    apt-get update -y && apt-get upgrade -y
    apt-get install -y wget curl unzip socat net-tools cron iptables-persistent ruby lsof gnupg
fi

# === INSTALL LOLCAT ===
gem install lolcat || echo "Gagal install lolcat"

# === SET SWAPFILE 1GB ===
if ! swapon --show | grep -q '/swapfile'; then
    fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

# === AKTIFKAN rc.local (UNTUK UBUNTU >= 18) ===
if [[ ! -f /etc/systemd/system/rc-local.service ]]; then
cat >/etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

echo -e "#!/bin/sh -e\nexit 0" > /etc/rc.local
chmod +x /etc/rc.local
systemctl daemon-reexec
systemctl enable rc-local
systemctl start rc-local
fi

# === PASANG MENU SISTEM ===
wget -q -O /root/menu.zip https://raw.githubusercontent.com/rizxddev/kont/main/limit/menu.zip
unzip -o /root/menu.zip -d /root/menu
chmod +x /root/menu/*
mv /root/menu/* /usr/local/sbin/
rm -rf /root/menu /root/menu.zip

# === ATUR PROFIL DAN CRON ===
cat >/root/.profile <<EOF
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
menu
EOF

cat >/etc/cron.d/xp_all <<EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/xp
EOF

cat >/etc/cron.d/logclean <<EOF
*/20 * * * * root /usr/local/sbin/clearlog
EOF

systemctl daemon-reload
systemctl enable --now cron rc-local netfilter-persistent

echo -e "\e[92m[+] premi.sh berhasil dijalankan dan dikonfigurasi untuk semua versi Ubuntu/Debian.\e[0m"