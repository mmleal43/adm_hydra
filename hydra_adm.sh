#!/bin/bash
# ADM-HYDRA - Script Principal (Corregido)
# GitHub: https://github.com/mmleal43/adm_hydra

# Configuración
VERSION="2.0"
INSTALL_DIR="/usr/local/hydra"
LOG_FILE="/var/log/hydra.log"
CONFIG_FILE="/etc/hydra.conf"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Función de logging
log() {
    echo "[$(date '+%d/%m/%Y %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Mostrar banner
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
    echo -e "${YELLOW}ADM-HYDRA - Panel de Control v$VERSION${NC}"
    echo "===================================="
}

# Menú de gestión SSH
manage_ssh() {
    while true; do
        show_banner
        echo -e "${GREEN}1. Agregar usuario SSH${NC}"
        echo -e "${GREEN}2. Eliminar usuario SSH${NC}"
        echo -e "${GREEN}3. Listar usuarios SSH${NC}"
        echo -e "${RED}4. Volver al menú principal${NC}"
        echo "===================================="
        
        read -r -p "Seleccione una opción [1-4]: " option
        
        case $option in
            1) add_ssh_user ;;
            2) del_ssh_user ;;
            3) list_ssh_users ;;
            4) break ;;
            *) 
                echo -e "${RED}Opción inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Función para agregar usuario SSH
add_ssh_user() {
    read -r -p "Nombre de usuario: " username
    read -r -p "Contraseña: " password
    read -r -p "Días de vigencia: " days
    
    expiry_date=$(date -d "$days days" +"%Y-%m-%d")
    useradd -m -s /bin/false "$username"
    echo "$username:$password" | chpasswd
    
    echo "$username:$expiry_date" >> "$CONFIG_FILE"
    log "Usuario SSH agregado: $username (Expira: $expiry_date)"
    echo -e "${GREEN}Usuario $username creado exitosamente!${NC}"
    sleep 2
}

# Menú principal
main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}1. Gestión de Usuarios SSH${NC}"
        echo -e "${GREEN}2. Instalar Protocolos${NC}"
        echo -e "${GREEN}3. Administrar Servicios${NC}"
        echo -e "${GREEN}4. Ver Registros${NC}"
        echo -e "${RED}0. Salir${NC}"
        echo "===================================="
        
        read -r -p "Seleccione una opción [0-4]: " option
        
        case $option in
            1) manage_ssh ;;
            2) install_protocols ;;
            3) manage_services ;;
            4) view_logs ;;
            0) 
                log "Sesión finalizada"
                echo -e "${GREEN}Hasta pronto!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Opción inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Inicialización
if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
    chmod 600 "$CONFIG_FILE"
fi

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"
fi

log "Inicio de sesión - Versión $VERSION"

# Manejo de parámetros
case $1 in
    "--update")
        log "Iniciando actualización automática"
        cd "$INSTALL_DIR" || exit 1
        git pull
        ;;
    "--install")
        log "Instalación adicional requerida"
        ;;
    *)
        main_menu
        ;;
esac
