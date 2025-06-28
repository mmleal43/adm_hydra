#!/bin/bash
# HYDRA ADM PANEL - VERSIÓN CORREGIDA
# Soluciona el problema "opción no válida"

# ... (mantén aquí tu configuración inicial de colores y variables)

mostrar_menu() {
    clear
    echo -e "${AZUL}"
    echo -e " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
    echo -e " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
    echo -e " ███████║ ╚████╔╝ ██████╔╝██████╔╝███████║"
    echo -e " ██╔══██║  ╚██╔╝  ██╔══██╗██╔══██╗██╔══██║"
    echo -e " ██║  ██║   ██║   ██║  ██║██║  ██║██║  ██║"
    echo -e " ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}${AMARILLO}         PANEL DE ADMINISTRACIÓN HYDRA ADM${NC}"
    echo -e "${AZUL}============================================${NC}"
    echo -e " ${VERDE}1.${NC} Instalar componentes principales"
    echo -e " ${VERDE}2.${NC} Configurar dominio"
    echo -e " ${VERDE}3.${NC} Administrar usuarios"
    echo -e " ${VERDE}4.${NC} Monitor de tráfico"
    echo -e " ${VERDE}5.${NC} Herramientas de red"
    echo -e " ${VERDE}6.${NC} Ver registros del sistema"
    echo -e " ${VERDE}0.${NC} Salir"
    echo -e "${AZUL}============================================${NC}"
}

# Bucle del menú CORREGIDO
while true; do
    mostrar_menu
    read -p "Seleccione una opción [0-6]: " opcion
    
    case "$opcion" in
        1) 
            echo -e "\n${VERDE}Instalando componentes principales...${NC}"
            # Tu lógica de instalación aquí
            sleep 2
            ;;
        2) 
            echo -e "\n${VERDE}Configurando dominio...${NC}"
            # Tu lógica de dominio aquí
            sleep 2
            ;;
        3) 
            echo -e "\n${VERDE}Accediendo a gestión de usuarios...${NC}"
            # Tu lógica de usuarios aquí
            sleep 2
            ;;
        4) 
            echo -e "\n${VERDE}Mostrando monitor de tráfico...${NC}"
            # Mostrar logs aquí
            if [ -f "/var/log/hydra.log" ]; then
                echo -e "${AZUL}=== ÚLTIMAS 10 LÍNEAS DEL LOG ===${NC}"
                tail -10 /var/log/hydra.log
            else
                echo -e "${ROJO}No se encontró el archivo de logs${NC}"
            fi
            read -p "Presione Enter para continuar..."
            ;;
        5) 
            echo -e "\n${VERDE}Mostrando herramientas de red...${NC}"
            # Tu lógica de red aquí
            sleep 2
            ;;
        6)
            echo -e "\n${AZUL}=== REGISTROS COMPLETOS ===${NC}"
            cat /var/log/hydra.log || echo -e "${ROJO}Error al leer los logs${NC}"
            read -p "Presione Enter para continuar..."
            ;;
        0)
            echo -e "\n${VERDE}Saliendo del panel...${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROJO}\n¡Opción inválida!${NC}" 
            echo -e "Por favor ingrese un número del ${AMARILLO}0 al 6${NC}"
            sleep 2
            ;;
    esac
done
