#!/bin/bash
set -e

NS=$(cat /etc/xray/dns 2>/dev/null || echo "NS_NOT_FOUND")
PUB=$(cat /etc/slowdns/server.pub 2>/dev/null || echo "PUB_NOT_FOUND")
domain=$(cat /etc/xray/domain 2>/dev/null || echo "domain.com")

# === Install dependensi Python dan alat pendukung ===
if command -v apt >/dev/null 2>&1; then
    apt update -y && apt upgrade -y
    apt install -y python3 python3-pip git unzip wget
else
    apt-get update -y && apt-get upgrade -y
    apt-get install -y python3 python3-pip git unzip wget
fi

# === Download dan pasang file bot ===
cd /usr/bin
wget -q https://raw.githubusercontent.com/rizxddev/kont/main/limit/bot.zip -O bot.zip
unzip -o bot.zip
mv bot/* /usr/bin || true
chmod +x /usr/bin/*
rm -rf bot.zip bot

cd /root
wget -q https://raw.githubusercontent.com/rizxddev/kont/main/limit/regis.zip -O regis.zip
unzip -o regis.zip -d regis
rm -rf regis.zip

# === Install dependensi bot Python ===
pip3 install -r regis/requirements.txt || true
pip3 install pillow || true

# === Input Token & ID ===
echo -e "\033[1;36mMasukkan Token Bot dan ID Telegram Admin\033[0m"
read -rp "[*] BOT TOKEN: " bottoken
read -rp "[*] ADMIN ID : " admin

cat <<EOF > /root/regis/var.txt
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
PUB="$PUB"
HOST="$NS"
EOF

# === Buat service bot ===
cat >/etc/systemd/system/regis.service <<END
[Unit]
Description=Telegram Bot Panel
After=network.target

[Service]
WorkingDirectory=/root
ExecStart=/usr/bin/python3 -m regis
Restart=always

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable --now regis

# === Info ===
echo -e "\n\033[92mBot telah diaktifkan dan berjalan.\033[0m"
echo "Token   : $bottoken"
echo "Admin   : $admin"
echo "Domain  : $domain"
echo "PubKey  : $PUB"
echo "NSHost  : $NS"
echo -e "\nSilakan ketik /menu pada bot Telegram Anda."