#!/bin/bash
# Installer Oficial ADM-HYDRA (Corregido)
# GitHub: https://github.com/mmleal43/adm_hydra

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Verificar root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Error: Debes ejecutar como root!${NC}" 1>&2
    exit 1
fi

# Configuración
INSTALL_DIR="/usr/local/hydra"
BIN_PATH="/usr/local/bin/hydra"
REPO_URL="https://github.com/mmleal43/adm_hydra.git"

# Mostrar banner
clear
echo -e "${BLUE}"
echo "   _    _           _   _ "
echo "  | |  | |         | | | |"
echo "  | |__| |_   _  __| | | |"
echo "  |  __  | | | |/ _\` | | |"
echo "  | |  | | |_| | (_| | |_|"
echo "  |_|  |_|\__,_|\__,_| (_)"
echo -e "${NC}"
echo -e "${YELLOW}Instalador Oficial ADM-HYDRA${NC}"
echo "===================================="

# Instalar dependencias
echo -e "${YELLOW}[+] Instalando dependencias...${NC}"
apt-get update > /dev/null 2>&1
apt-get install -y git curl jq python3-pip openssh-server dropbear stunnel4 squid shadowsocks-libev > /dev/null 2>&1

# Clonar repositorio
echo -e "${YELLOW}[+] Clonando repositorio...${NC}"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}[!] Actualizando instalación existente...${NC}"
    cd "$INSTALL_DIR" || exit 1
    git pull > /dev/null 2>&1
else
    git clone "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Error al clonar el repositorio!${NC}"
        exit 1
    fi
fi

# Permisos de ejecución
chmod +x "$INSTALL_DIR/hydra_adm.sh"

# Crear enlace simbólico
ln -sf "$INSTALL_DIR/hydra_adm.sh" "$BIN_PATH"

# Configurar auto-actualización
(crontab -l 2>/dev/null; echo "0 3 * * * $BIN_PATH --update") | crontab -

echo -e "${GREEN}"
echo "  _   _                 _ "
echo " | | | |               | |"
echo " | |_| |_ _ __ __ _  __| |"
echo " |  _  | '__/ _\` |/ _\` |"
echo " | | | | | | (_| | (_| |"
echo " \_| |_/_|  \__,_|\__,_|"
echo -e "${NC}"
echo -e "${GREEN}[+] Instalación completada con éxito!${NC}"
echo "===================================="
echo -e "Usa el comando: ${YELLOW}hydra${NC} para iniciar la herramienta"
echo -e "Documentación: ${BLUE}https://github.com/mmleal43/adm_hydra${NC}"
