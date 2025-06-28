#!/bin/bash
# INSTALADOR AUTOMÁTICO HYDRA ADM
# Basado en tu repositorio: github.com/mmleal43/adm_hydra
# Versión 2.0 - Todos los menús funcionales

# Configuración
HYDRA_REPO="https://github.com/mmleal43/adm_hydra/raw/main/hydra_adm.sh"
INSTALL_DIR="/usr/local/hydra"
LOG_FILE="/var/log/hydra_install.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Verificar root
[ "$(id -u)" != "0" ] && {
    echo -e "${RED}¡Ejecuta como root!${NC}";
    exit 1
}

# Función para instalar
install_hydra() {
    echo -e "${YELLOW}[+] Descargando HYDRA ADM...${NC}"
    mkdir -p $INSTALL_DIR
    curl -sL $HYDRA_REPO -o $INSTALL_DIR/hydra_adm.sh || {
        echo -e "${RED}Error al descargar${NC}";
        exit 1
    }

    chmod +x $INSTALL_DIR/hydra_adm.sh
    ln -s $INSTALL_DIR/hydra_adm.sh /usr/local/bin/hydra-adm

    # Crear servicio systemd (opcional)
    cat > /etc/systemd/system/hydra.service <<EOF
[Unit]
Description=HYDRA ADM Panel
After=network.target

[Service]
ExecStart=$INSTALL_DIR/hydra_adm.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    echo -e "${GREEN}[✔] Instalación completada${NC}"
    echo -e "Ejecuta: ${YELLOW}hydra-adm${NC} para iniciar el panel"
}

# Menú principal del instalador
echo -e "${GREEN}"
echo " ██╗  ██╗██╗   ██╗██████╗ ██████╗  █████╗ "
echo " ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██╔══██╗"
echo " ███████║ ╚████╔╝ ██████╔╝██████╔╝███████║"
echo -e "${NC}${YELLOW}   INSTALADOR AUTOMÁTICO - HYDRA ADM${NC}"
echo -e "${GREEN}============================================${NC}"

PS3="Seleccione una opción: "
options=("Instalar HYDRA ADM" "Desinstalar" "Salir")
select opt in "${options[@]}"
do
    case $opt in
        "Instalar HYDRA ADM")
            install_hydra
            break
            ;;
        "Desinstalar")
            echo -e "${YELLOW}[+] Desinstalando...${NC}"
            rm -rf $INSTALL_DIR /usr/local/bin/hydra-adm
            systemctl disable --now hydra.service 2>/dev/null
            rm -f /etc/systemd/system/hydra.service
            echo -e "${GREEN}[✔] Desinstalación completada${NC}"
            break
            ;;
        "Salir")
            exit 0
            ;;
        *) 
            echo -e "${RED}Opción no válida${NC}"
            ;;
    esac
done
