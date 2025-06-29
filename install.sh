#!/bin/bash
echo -e "\e[31m🐉 Instalando HYDRA PANEL v3...\e[0m"
sleep 2

# Actualizar sistema
apt update -y && apt upgrade -y

# Instalar dependencias
apt install -y wget curl net-tools unzip jq screen nginx stunnel4 fail2ban openssl

# Configurar SSH + Stunnel
echo "Port 22" >> /etc/ssh/sshd_config
systemctl restart ssh

cat > /etc/stunnel/stunnel.conf <<EOF
client = no
[ssh]
accept = 443
connect = 22
EOF
echo "ENABLED=1" > /etc/default/stunnel4
systemctl restart stunnel4

# Configurar Fail2Ban
systemctl enable fail2ban
systemctl start fail2ban

# Nginx default
rm -f /etc/nginx/sites-enabled/default
cat > /etc/nginx/sites-available/hydra <<EOF
server {
    listen 80;
    server_name _;
    root /var/www/html;
    index index.html;
}
EOF
ln -s /etc/nginx/sites-available/hydra /etc/nginx/sites-enabled/
systemctl restart nginx

# TLS autofirmado
mkdir -p /etc/ssl
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/hydra-key.pem -out /etc/ssl/hydra-cert.pem -subj "/CN=HYDRA"

# HYDRA ADM script
mkdir -p /etc/hydra_adm
wget -O /etc/hydra_adm/hydra_adm.sh https://raw.githubusercontent.com/mmleal43/adm_hydra/main/hydra_adm.sh
chmod +x /etc/hydra_adm/hydra_adm.sh

# Alias global
echo -e "#!/bin/bash\nbash /etc/hydra_adm/hydra_adm.sh" > /usr/bin/menu
chmod +x /usr/bin/menu

echo -e "\e[32m✅ Instalación completa."
echo -e "\e[31m🐉 Escribe \e[33mmenu\e[0m \e[31mpara abrir tu HYDRA PANEL.\e[0m"
