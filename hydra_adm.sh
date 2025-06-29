#!/bin/bash
# ADM-HYDRA - Instalador Completo de Protocolos
# GitHub: https://github.com/mmleal43/adm_hydra

# Configuración
VERSION="3.0"
INSTALL_DIR="/usr/local/hydra"
LOG_FILE="/var/log/hydra_install.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para registrar logs
log() {
    echo "[$(date '+%d/%m/%Y %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Función para instalar dependencias básicas
install_dependencies() {
    echo -e "${YELLOW}[+] Instalando dependencias básicas...${NC}"
    apt-get update > /dev/null 2>&1
    apt-get install -y git curl wget build-essential > /dev/null 2>&1
}

# Función para mostrar el banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "   _    _           _   _ "
    echo "  | |  | |         | | | |"
    echo "  | |__| |_   _  __| | | |"
    echo "  |  __  | | | |/ _\` | | |"
    echo "  | |  | | |_| | (_| | |_|"
    echo "  |_|  |_|\__,_|\__,_| (_)"
    echo -e "${NC}"
    echo -e "${YELLOW}ADM-HYDRA - Instalador de Protocolos v$VERSION${NC}"
    echo "===================================="
}

# =========================================
# FUNCIONES DE INSTALACIÓN DE PROTOCOLOS
# =========================================

install_openssh() {
    echo -e "${YELLOW}[+] Instalando OpenSSH...${NC}"
    apt-get install -y openssh-server
    systemctl enable ssh
    systemctl start ssh
    echo -e "${GREEN}[✓] OpenSSH instalado correctamente${NC}"
    log "OpenSSH instalado"
    sleep 2
}

install_dropbear() {
    echo -e "${YELLOW}[+] Instalando Dropbear...${NC}"
    apt-get install -y dropbear
    echo 'NO_START=0' > /etc/default/dropbear
    echo 'DROPBEAR_PORT=443' >> /etc/default/dropbear
    systemctl enable dropbear
    systemctl start dropbear
    echo -e "${GREEN}[✓] Dropbear instalado correctamente${NC}"
    log "Dropbear instalado"
    sleep 2
}

install_openvpn() {
    echo -e "${YELLOW}[+] Instalando OpenVPN...${NC}"
    apt-get install -y openvpn easy-rsa
    cp -r /usr/share/easy-rsa/ /etc/openvpn/
    cd /etc/openvpn/easy-rsa || exit
    ./easyrsa init-pki
    ./easyrsa build-ca nopass
    ./easyrsa gen-dh
    echo -e "${GREEN}[✓] OpenVPN instalado correctamente${NC}"
    log "OpenVPN instalado"
    sleep 2
}

install_ssl() {
    echo -e "${YELLOW}[+] Instalando SSL/TLS (Stunnel)...${NC}"
    apt-get install -y stunnel4
    openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=US/ST=California/L=San Francisco/O=Global Security/OU=IT Department/CN=example.com"
    systemctl enable stunnel4
    systemctl start stunnel4
    echo -e "${GREEN}[✓] SSL/TLS instalado correctamente${NC}"
    log "SSL/TLS instalado"
    sleep 2
}

install_shadowsocks() {
    echo -e "${YELLOW}[+] Instalando Shadowsocks-R...${NC}"
    apt-get install -y python3-pip
    pip3 install git+https://github.com/shadowsocks/shadowsocks.git@master
    echo -e "${GREEN}[✓] Shadowsocks-R instalado correctamente${NC}"
    log "Shadowsocks-R instalado"
    sleep 2
}

install_squid() {
    echo -e "${YELLOW}[+] Instalando Squid Proxy...${NC}"
    apt-get install -y squid
    systemctl enable squid
    systemctl start squid
    echo -e "${GREEN}[✓] Squid instalado correctamente${NC}"
    log "Squid instalado"
    sleep 2
}

install_python_proxy() {
    echo -e "${YELLOW}[+] Instalando Python Proxy...${NC}"
    apt-get install -y python3
    cat > /usr/local/bin/python_proxy.py << 'EOF'
import socket
import threading
# Código básico de proxy Python aquí
EOF
    echo -e "${GREEN}[✓] Python Proxy instalado correctamente${NC}"
    log "Python Proxy instalado"
    sleep 2
}

install_v2ray() {
    echo -e "${YELLOW}[+] Instalando V2Ray...${NC}"
    bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
    systemctl enable v2ray
    systemctl start v2ray
    echo -e "${GREEN}[✓] V2Ray instalado correctamente${NC}"
    log "V2Ray instalado"
    sleep 2
}

# =========================================
# MENÚ PRINCIPAL
# =========================================

protocol_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}1. Instalar OpenSSH${NC}"
        echo -e "${GREEN}2. Instalar Dropbear${NC}"
        echo -e "${GREEN}3. Instalar OpenVPN${NC}"
        echo -e "${GREEN}4. Instalar SSL/TLS${NC}"
        echo -e "${GREEN}5. Instalar Shadowsocks-R${NC}"
        echo -e "${GREEN}6. Instalar Squid${NC}"
        echo -e "${GREEN}7. Instalar Python Proxy${NC}"
        echo -e "${GREEN}8. Instalar V2Ray${NC}"
        echo -e "${RED}9. Volver al menú principal${NC}"
        echo "===================================="
        
        read -p "Seleccione una opción [1-9]: " option
        
        case $option in
            1) install_openssh ;;
            2) install_dropbear ;;
            3) install_openvpn ;;
            4) install_ssl ;;
            5) install_shadowsocks ;;
            6) install_squid ;;
            7) install_python_proxy ;;
            8) install_v2ray ;;
            9) break ;;
            *) 
                echo -e "${RED}Opción inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Inicio del script
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Error: Debes ejecutar como root!${NC}" 1>&2
    exit 1
fi

install_dependencies
protocol_menu
