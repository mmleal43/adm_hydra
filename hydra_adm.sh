#!/bin/bash
# HYDRA ADM PANEL - VERSIÓN 100% FUNCIONAL
# Solución definitiva al problema de opciones inválidas

# Configuración
HYDRA_USER="admin"
HYDRA_PASS=$(openssl rand -hex 8)
INSTALL_DIR="/usr/local/hydra"
LOG_FILE="/var/log/hydra.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Crear archivo de log si no existe
touch $LOG_FILE

# Función para el menú principal
show_menu() {
    clear
    echo -e "${BLUE}"
    echo -e " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
    echo -e " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
    echo -e " ███████║ ╚████╔╝ ██████╔╝██████╔╝███████║"
    echo -e " ██╔══██║  ╚██╔╝  ██╔══██╗██╔══██╗██╔══██║"
    echo -e " ██║  ██║   ██║   ██║  ██║██║  ██║██║  ██║"
    echo -e " ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}${YELLOW}        PANEL DE ADMINISTRACIÓN HYDRA ADM${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e " ${GREEN}1.${NC} Instalar componentes principales"
    echo -e " ${GREEN}2.${NC} Gestión de usuarios"
    echo -e " ${GREEN}3.${NC} Configurar protocolos"
    echo -e " ${GREEN}4.${NC} Monitor de red"
    echo -e " ${GREEN}5.${NC} Ver logs del sistema"
    echo -e " ${GREEN}6.${NC} Configuración avanzada"
    echo -e " ${GREEN}0.${NC} Salir"
    echo -e "${BLUE}============================================${NC}"
}

# Función para validar entrada numérica
validate_input() {
    local input=$1
    if ! [[ "$input" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: Debes ingresar un número${NC}" | tee -a $LOG_FILE
        return 1
    fi
    return 0
}

# Bucle principal del menú CORREGIDO
while true; do
    show_menu
    echo -ne "\n${YELLOW}Seleccione una opción: ${NC}"
    read -r choice
    
    # Validar entrada
    if ! validate_input "$choice"; then
        sleep 1
        continue
    fi

    # Procesar opción (usando comparación numérica)
    case $choice in
        1)
            echo -e "\n${GREEN}[+] Instalando componentes...${NC}" | tee -a $LOG_FILE
            # Tu lógica de instalación aquí
            sleep 2
            ;;
        2)
            echo -e "\n${GREEN}[+] Gestión de usuarios seleccionada${NC}" | tee -a $LOG_FILE
            # Tu lógica de usuarios aquí
            sleep 2
            ;;
        3)
            echo -e "\n${GREEN}[+] Configuración de protocolos${NC}" | tee -a $LOG_FILE
            # Tu lógica de protocolos
            sleep 2
            ;;
        4)
            echo -e "\n${GREEN}[+] Monitor de red activado${NC}" | tee -a $LOG_FILE
            # Mostrar información de red
            ifconfig | head -10
            read -p "Presione Enter para continuar..."
            ;;
        5)
            echo -e "\n${BLUE}=== ÚLTIMOS EVENTOS (logs) ===${NC}" | tee -a $LOG_FILE
            tail -20 $LOG_FILE || echo -e "${RED}No se pudo leer el archivo de logs${NC}" | tee -a $LOG_FILE
            read -p "Presione Enter para continuar..."
            ;;
        6)
            echo -e "\n${GREEN}[+] Configuración avanzada${NC}" | tee -a $LOG_FILE
            # Opciones avanzadas
            sleep 2
            ;;
        0)
            echo -e "\n${GREEN}[+] Saliendo del panel HYDRA ADM${NC}" | tee -a $LOG_FILE
            exit 0
            ;;
        *)
            echo -e "\n${RED}[!] Opción $choice no válida!${NC}" | tee -a $LOG_FILE
            echo -e "Por favor ingrese un número entre ${YELLOW}0 y 6${NC}" | tee -a $LOG_FILE
            sleep 2
            ;;
    esac
done
