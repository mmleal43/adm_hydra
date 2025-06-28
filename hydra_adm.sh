#!/bin/bash
# ==========================================
# HYDRA INSTALLER
# Instalador automático del HYDRA ADM
# Igual que ADMRufu pero con branding HYDRA
# ==========================================

echo -e "\e[31m🐉 Iniciando instalación del HYDRA ADM...\e[0m"
sleep 2

# Actualizar el sistema
apt update -y && apt upgrade -y

# Instalar dependencias necesarias
apt install -y wget curl net-tools unzip jq screen

# Crear carpeta HYDRA ADM
mkdir -p /etc/hydra_adm

# Descargar el script principal desde tu GitHub
wget -O /etc/hydra_adm/hydra_adm.sh https://raw.githubusercontent.com/mmleal43/adm_hydra/main/hydra_adm.sh

# Dar permisos de ejecución
chmod +x /etc/hydra_adm/hydra_adm.sh

# Crear alias en /usr/bin/menu para ejecutar tu script desde cualquier lugar
echo -e "#!/bin/bash\nbash /etc/hydra_adm/hydra_adm.sh" > /usr/bin/menu
chmod +x /usr/bin/menu

# Crear logs y config básicos
touch /etc/hydra_adm/usuarios.db
touch /etc/hydra_adm/log-hydra.log

echo -e "\e[32m✅ Instalación completada.\e[0m"
echo -e "\e[31m🐉 Para acceder a tu HYDRA ADM escribe: \e[33mmenu\e[0m"
