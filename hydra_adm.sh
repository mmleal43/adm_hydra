#!/bin/bash
# HYDRA ADM - PANEL AVANZADO DE ADMINISTRACIÓN
# Versión 5.0 - Soporte Multi-Protocolo
# Incluye: X-UI modificado + Herramientas ADM

# Configuración
HYDRA_PORT="5400"
HYDRA_USER="admin"
HYDRA_PASS=$(openssl rand -base64 12)
INSTALL_DIR="/usr/local/hydra"
LOG_FILE="/var/log/hydra_install.log"

# Colores para la interfaz
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Verificación de root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}ERROR: Debes ejecutar este script como root${NC}"
    exit 1
fi

# Logo de HYDRA ADM
show_logo() {
    clear
    echo -e "${CYAN}"
    echo -e " ██╗  ██╗██╗   ████████╗ ██████╗  █████╗ "
    echo -e " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
    echo -e " ███████║ ╚████╔╝ ██████╔╝██████╔╝███████║"
    echo -e " ██╔══██║  ╚██╔╝  ██╔══██╗██╔══██╗██╔══██║" 
    echo -e " ██║  ██║   ██║   ██║  ██║██║  ██║██║  ██║"
    echo -e " ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}${MAGENTA}       PANEL DE ADMINISTRACIÓN AVANZADA${NC}"
    echo -e "${BLUE}==============================================${NC}"
}

# Función para instalar dependencias
install_dependencies() {
    echo -e "${YELLOW}[+] Instalando dependencias del sistema...${NC}"
    apt update && apt upgrade -y
    apt install -y curl wget git nginx certbot openvpn ufw socat mysql-server python3-pip
    pip3 install flask python-dotenv
}

# Instalación personalizada de HYDRA ADM
install_hydra() {
    echo -e "${YELLOW}[+] Descargando HYDRA ADM...${NC}"
    git clone https://github.com/hydra-adm/panel.git $INSTALL_DIR
    
    echo -e "${YELLOW}[+] Configurando entorno...${NC}"
    cp $INSTALL_DIR/config.example.py $INSTALL_DIR/config.py
    sed -i "s/^ADMIN_PASSWORD =.*/ADMIN_PASSWORD = '$HYDRA_PASS'/" $INSTALL_DIR/config.py
    sed -i "s/^PANEL_PORT =.*/PANEL_PORT = $HYDRA_PORT/" $INSTALL_DIR/config.py
    
    echo -e "${YELLOW}[+] Configurando servicios...${NC}"
    cat > /etc/systemd/system/hydra.service <<EOF
[Unit]
Description=HYDRA ADM Panel
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/main.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable hydra
    systemctl start hydra
}

# Configurar firewall y optimización
configure_firewall() {
    echo -e "${YELLOW}[+] Configurando firewall...${NC}"
    ufw allow $HYDRA_PORT/tcp
    ufw allow OpenSSH
    ufw --force enable
}

# Menú principal
show_menu() {
    show_logo
    echo -e " ${GREEN}1.${NC} Instalar HYDRA ADM Completo"
    echo -e " ${GREEN}2.${NC} Configurar Dominio SSL"
    echo -e " ${GREEN}3.${NC} Administrar Usuarios"
    echo -e " ${GREEN}4.${NC} Gestión de Protocolos"
    echo -e " ${GREEN}5.${NC} Monitor de Rendimiento"
    echo -e " ${GREEN}6.${NC} Herramientas ADM"
    echo -e " ${GREEN}7.${NC} Desinstalar"
    echo -e "${BLUE}==============================================${NC}"
    echo -e " ${GREEN}0.${NC} Salir"
    echo -e "${BLUE}==============================================${NC}"
}

# Función de desinstalación mejorada
uninstall_hydra() {
    echo -e "\n${RED}[!] ADVERTENCIA: Esto eliminará completamente HYDRA ADM${NC}"
    read -p "¿Estás seguro? (s/n): " confirm
    
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo -e "${GREEN}Cancelado.${NC}"
        return
    fi
    
    echo -e "${YELLOW}[+] Desinstalando HYDRA ADM...${NC}"
    
    # Detener y eliminar servicio
    systemctl stop hydra
    systemctl disable hydra
    rm -f /etc/systemd/system/hydra.service
    
    # Eliminar archivos
    rm -rf $INSTALL_DIR
    rm -f /usr/local/bin/hydra-cli
    
    # Limpiar dependencias
    apt remove -y --purge git python3-pip
    apt autoremove -y
    
    echo -e "${GREEN}[✔] HYDRA ADM ha sido desinstalado completamente${NC}"
}

# Bucle principal
while true; do
    show_menu
    read -p "Seleccione una opción [0-7]: " option
    
    case $option in
        1) 
            install_dependencies
            install_hydra
            configure_firewall
            echo -e "\n${GREEN}[✔] Instalación completada!${NC}"
            echo -e " Panel: ${CYAN}http://$(curl -4s icanhazip.com):$HYDRA_PORT${NC}"
            echo -e " Usuario: ${YELLOW}$HYDRA_USER${NC}"
            echo -e " Clave: ${YELLOW}$HYDRA_PASS${NC}"
            ;;
        2)
            echo -e "\n${YELLOW}Configuración de dominio...${NC}"
            read -p "Ingrese su dominio completo: " domain
            # Configuración de Nginx y Certbot aquí
            ;;
        7) 
            uninstall_hydra
            ;;
        0)
            echo -e "${GREEN}Saliendo...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida${NC}"
            ;;
    esac
    
    read -n 1 -s -r -p "Presione cualquier tecla para continuar..."
done
