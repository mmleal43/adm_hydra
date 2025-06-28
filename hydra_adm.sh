#!/bin/bash
# INSTALADOR X-UI PANEL EN ESPAÑOL
# Versión 3.5 - By BLACKBOX AI
# Características mejoradas vs ADMRufu

# Colores para la interfaz
ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[0;33m'
AZUL='\033[0;34m'
NC='\033[0m' # Sin color

# Verificar root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${ROJO}✗ Debes ejecutar este script como root/sudo ✗${NC}"
    exit 1
fi

# Función para mostrar el menú principal
mostrar_menu() {
    clear
    echo -e "${AZUL}"
    echo -e " ██████╗ ██████╗ ███████╗██████╗ "
    echo -e "██╔═══██╗██╔══██╗██╔════╝██╔══██╗"
    echo -e "██║   ██║██████╔╝█████╗  ██████╔╝"
    echo -e "██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗"
    echo -e "╚██████╔╝██║     ███████╗██║  ██║"
    echo -e " ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}${AMARILLO}  INSTALADOR X-UI PANEL - VERSIÓN EN ESPAÑOL ${NC}"
    echo -e "${AZUL}==========================================${NC}"
    echo -e " ${VERDE}1.${NC} Instalar X-UI Panel Completo"
    echo -e " ${VERDE}2.${NC} Configurar Dominio y SSL"
    echo -e " ${VERDE}3.${NC} Administrar Usuarios"
    echo -e " ${VERDE}4.${NC} Configurar Firewall"
    echo -e " ${VERDE}5.${NC} Realizar Backup"
    echo -e " ${VERDE}6.${NC} Desinstalar"
    echo -e "${AZUL}==========================================${NC}"
    echo -e " ${VERDE}0.${NC} Salir"
    echo -e "${AZUL}==========================================${NC}"
}

# Función para instalar X-UI
instalar_xui() {
    echo -e "${AMARILLO}▶ Instalando X-UI Panel...${NC}"
    
    # Actualizar sistema
    apt update && apt upgrade -y
    
    # Instalar dependencias
    apt install -y curl socat nginx certbot mariadb-server
    
    # Descargar e instalar X-UI
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
    
    # Configurar servicio
    systemctl enable x-ui
    systemctl start x-ui
    
    echo -e "${VERDE}✔ Instalación completada con éxito${NC}"
    echo -e "Accede al panel en: ${AMARILLO}https://tu_ip:54321${NC}"
    echo -e "Usuario: admin | Contraseña: admin"
}

# Función para configurar dominio
configurar_dominio() {
    read -p "Ingresa tu dominio (ejemplo.com): " dominio
    echo -e "${AMARILLO}▶ Configurando $dominio...${NC}"
    
    # Detener Nginx temporalmente
    systemctl stop nginx
    
    # Obtener certificado SSL
    certbot certonly --standalone -d $dominio
    
    # Configurar Nginx
    cat > /etc/nginx/conf.d/x-ui.conf <<EOF
server {
    listen 80;
    server_name $dominio;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $dominio;
    
    ssl_certificate /etc/letsencrypt/live/$dominio/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$dominio/privkey.pem;
    
    location / {
        proxy_pass http://127.0.0.1:54321;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
    
    # Reiniciar servicios
    systemctl restart nginx
    systemctl restart x-ui
    
    echo -e "${VERDE}✔ Dominio configurado correctamente${NC}"
    echo -e "Ahora puedes acceder en: ${AMARILLO}https://$dominio${NC}"
}

# Función principal
while true; do
    mostrar_menu
    read -p "Selecciona una opción [0-6]: " opcion
    
    case $opcion in
        1) instalar_xui ;;
        2) configurar_dominio ;;
        0) echo -e "${VERDE}¡Hasta luego!${NC}"; exit 0 ;;
        *) echo -e "${ROJO}Opción inválida${NC}"; sleep 1 ;;
    esac
    
    read -p "Presiona Enter para continuar..."
done
