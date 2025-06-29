#!/bin/bash
# ==========================================
# HYDRA PANEL v3
# ==========================================

# Auto-expirador SSH
for user in $(cut -d: -f1 /etc/passwd | grep -vE "root|nologin|sync|shutdown|halt|mail"); do
  exp=$(chage -l $user | grep "Account expires" | awk -F": " '{print $2}')
  if [[ $exp != "never" && $(date -d "$exp" +%s) -lt $(date +%s) ]]; then
    userdel -r $user &>/dev/null
    echo -e "\e[31m🗑 Usuario $user eliminado por expiración ($exp)\e[0m"
  fi
done

while true; do
  clear
  echo -e "\e[31m============================"
  echo -e "     🐉 HYDRA PANEL v3"
  echo -e "============================\e[0m"
  echo -e "\e[33m[1]\e[0m Crear usuario SSH"
  echo -e "\e[33m[2]\e[0m Listar usuarios SSH"
  echo -e "\e[33m[3]\e[0m Reiniciar servicios"
  echo -e "\e[33m[4]\e[0m Ver logs conexiones"
  echo -e "\e[33m[5]\e[0m Instalar V2Ray multi-path WS"
  echo -e "\e[33m[6]\e[0m Instalar Trojan-GO TLS"
  echo -e "\e[0m"
  echo -e "\e[33m[0]\e[0m Salir"
  echo -ne "\n\e[31mSelecciona una opción: \e[0m"
  read opt
  case $opt in
    1)
      echo -ne "\n\e[33mUsuario SSH: \e[0m"; read user
      echo -ne "\e[33mDías válido: \e[0m"; read days
      exp_date=$(date -d "$days days" +"%Y-%m-%d")
      pass=$(openssl rand -hex 4)
      useradd -e $exp_date -M -s /bin/false $user
      echo "$user:$pass" | chpasswd
      echo "$user maxlogins=1" >> /etc/security/limits.conf
      echo -e "\e[32m✅ $user creado, pass: $pass, expira: $exp_date\e[0m"
      read -p "Enter para continuar..."
      ;;
    2)
      echo -e "\n\e[33mUsuarios SSH activos:\e[0m"
      cut -d: -f1 /etc/passwd | grep -vE "root|nologin|sync|shutdown|halt|mail" | while read u; do
        chage -l $u | grep "Account expires" | awk '{print "\e[32m" u "\e[0m expira: "$4" "$5" "$6}' u=$u
      done
      read -p "Enter para continuar..."
      ;;
    3)
      echo -e "\n\e[33mReiniciando SSH, Stunnel, Nginx, V2Ray, Trojan-GO...\e[0m"
      systemctl restart ssh
      systemctl restart stunnel4
      systemctl restart nginx
      systemctl restart v2ray &>/dev/null
      systemctl restart trojan-go &>/dev/null
      echo -e "\e[32m✅ Servicios reiniciados.\e[0m"
      read -p "Enter para continuar..."
      ;;
    4)
      echo -e "\n\e[33mLogs de conexiones:\e[0m"
      last
      read -p "Enter para continuar..."
      ;;
    5)
      echo -e "\n\e[33mInstalando V2Ray multi-path...\e[0m"
      bash <(curl -L -s https://install.direct/go.sh)
      uuid=$(cat /proc/sys/kernel/random/uuid)
      mkdir -p /etc/v2ray
      cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": { "clients": [{ "id": "$uuid" }] },
    "streamSettings": {
      "network": "ws",
      "wsSettings": { "path": "/hydra" },
      "security": "tls",
      "tlsSettings": { "certificates": [{ "certificateFile": "/etc/ssl/hydra-cert.pem", "keyFile": "/etc/ssl/hydra-key.pem" }] }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF
      systemctl enable v2ray
      systemctl restart v2ray
      echo -e "\n\e[32m✅ V2Ray multi-path instalado."
      echo -e "\e[33mVLESS:\e[0m"
      echo -e "\e[32mvless://$uuid@$(curl -s ifconfig.me):443?type=ws&security=tls&path=/hydra#HYDRA\e[0m"
      read -p "Enter para continuar..."
      ;;
    6)
      echo -e "\n\e[33mInstalando Trojan-GO...\e[0m"
      mkdir -p /etc/trojan-go
      wget -O /etc/trojan-go/trojan-go https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64
      chmod +x /etc/trojan-go/trojan-go
      uuid=$(cat /proc/sys/kernel/random/uuid)
      cat > /etc/trojan-go/config.json <<EOF
{
  "run_type": "server",
  "local_addr": "0.0.0.0",
  "local_port": 443,
  "remote_addr": "127.0.0.1",
  "remote_port": 80,
  "password": ["$uuid"],
  "ssl": {
    "cert": "/etc/ssl/hydra-cert.pem",
    "key": "/etc/ssl/hydra-key.pem"
  }
}
EOF
      cat > /etc/systemd/system/trojan-go.service <<EOF
[Unit]
Description=Trojan-GO Server
After=network.target
[Service]
Type=simple
ExecStart=/etc/trojan-go/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
      systemctl daemon-reload
      systemctl enable trojan-go
      systemctl restart trojan-go
      echo -e "\n\e[32m✅ Trojan-GO instalado."
      echo -e "\e[33mTrojan link:\e[0m"
      echo -e "\e[32mtrojan://$uuid@$(curl -s ifconfig.me):443?security=tls&peer=example.com#HYDRA-TROJAN\e[0m"
      read -p "Enter para continuar..."
      ;;
    0)
      echo -e "\e[31mSaliendo del HYDRA PANEL 🐉\e[0m"
      exit 0
      ;;
    *)
      echo -e "\e[31mOpción inválida\e[0m"
      sleep 1
      ;;
  esac
done
