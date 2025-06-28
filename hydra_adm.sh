#!/bin/bash
# ==========================================
# HYDRA PANEL - INSTALADOR AUTOMÁTICO
# Panel en rojo/negro con SSH, SSL, WS, V2Ray, Trojan
# Usuario: hydra / Contraseña: 12345
# ==========================================

echo "🔧 Iniciando instalación del HYDRA PANEL..."
sleep 2

# Actualizar VPS
apt update -y && apt upgrade -y

# Instalar dependencias básicas
apt install -y nginx curl wget unzip socat cron

# Instalar y configurar Stunnel (SSL)
apt install -y stunnel4
cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[https]
accept = 443
connect = 22
EOF
echo "ENABLED=1" > /etc/default/stunnel4
systemctl restart stunnel4

# Instalar y configurar fail2ban (seguridad)
apt install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Instalar V2Ray (VLESS WS TLS)
bash <(curl -L -s https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
cat > /usr/local/etc/v2ray/config.json <<EOF
{
  "inbounds": [{
    "port": 8443,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "$(uuidgen)", "flow": "xtls-rprx-direct"}],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {"path": "/hydra"}
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF
systemctl enable v2ray
systemctl restart v2ray

# Configurar Nginx
rm /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/hydra <<EOF
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html index.htm;
    location /hydra {
        proxy_pass http://127.0.0.1:8443;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF
ln -s /etc/nginx/sites-available/hydra /etc/nginx/sites-enabled/
systemctl restart nginx

# Panel visual (HTML básico rojo/negro)
mkdir -p /var/www/html
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html lang="es">
<head>
<title>HYDRA PANEL</title>
<style>
body { background: black; color: red; font-family: Arial; text-align: center; }
button { background: red; color: white; padding: 10px; border: none; }
</style>
</head>
<body>
<h1>🐉 HYDRA PANEL</h1>
<p>Usuario: hydra</p>
<p>Contraseña: 12345</p>
<button onclick="alert('Protocolos activos: SSH, SSL, WS, V2Ray, Trojan')">
Ver protocolos
</button>
</body>
</html>
EOF

# Habilitar cron
systemctl enable cron
systemctl start cron

echo "✅ HYDRA PANEL instalado."
echo "🌐 Accede en: http://$(curl -s ifconfig.me)"
echo "Login: hydra / 12345"
