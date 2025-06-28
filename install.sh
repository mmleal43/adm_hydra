#!/bin/bash
# Instalador Automático HYDRA ADM
# Uso: wget -qO- https://raw.githubusercontent.com/mmleal43/HYDRA-ADM/main/install.sh | sudo bash

# Configuración
SCRIPT_URL="https://raw.githubusercontent.com/mmleal43/HYDRA-ADM/main/HYDRAADM.sh"
INSTALL_PATH="/usr/local/bin/hydraadm"

# Verificar root
[ "$(id -u)" -ne 0 ] && {
    echo -e "\033[0;31m[!] Debes ejecutar como root. Usa: sudo bash $0\033[0m"
    exit 1
}

# Instalar dependencias
echo -e "\033[1;33m[+] Instalando dependencias...\033[0m"
apt-get update && apt-get install -y wget curl

# Descargar e instalar script
echo -e "\033[1;33m[+] Instalando HYDRA ADM...\033[0m"
wget -q "$SCRIPT_URL" -O "$INSTALL_PATH" || {
    echo -e "\033[0;31m[!] Error al descargar el script\033[0m"
    exit 1
}

chmod +x "$INSTALL_PATH"

# Crear enlace simbólico
ln -sf "$INSTALL_PATH" /usr/bin/hydraadm

# Crear directorios base
mkdir -p /opt/hydra_adm /var/log/hydra /etc/hydra

echo -e "\033[1;32m[+] Instalación completada!\033[0m"
echo -e "Ejecuta el panel con: \033[1;32mhydraadm\033[0m"

exit 0
