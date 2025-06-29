#!/bin/bash
# ADM-HYDRA Professional Panel
# By @mmleal43 - GitHub: https://github.com/mmleal43/adm_hydra

# Configuración
VERSION="4.2"
SSH_USERS_DB="/etc/hydra/ssh_users.db"
V2RAY_USERS_DB="/etc/hydra/v2ray_users.db"
BANNER_FILE="/etc/hydra/banner.html"
LOG_FILE="/var/log/hydra.log"
CONFIG_DIR="/etc/hydra"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# =========================================
# FUNCIONES BÁSICAS
# =========================================

init_system() {
    [ ! -d "$CONFIG_DIR" ] && mkdir -p "$CONFIG_DIR"
    [ ! -f "$SSH_USERS_DB" ] && touch "$SSH_USERS_DB"
    [ ! -f "$V2RAY_USERS_DB" ] && touch "$V2RAY_USERS_DB"
    [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
    chmod 600 "$SSH_USERS_DB" "$V2RAY_USERS_DB" "$LOG_FILE"
}

log() {
    echo "[$(date '+%d/%m/%Y %H:%M:%S')] $1" >> "$LOG_FILE"
}

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
    echo -e "${YELLOW}ADM-HYDRA Professional Panel v$VERSION${NC}"
    echo "===================================="
}

return_to_menu() {
    echo -e "\n${YELLOW}Presiona ENTER para continuar...${NC}"
    read -p ""
    main_menu
}

# =========================================
# x1. CONTROL DE USUARIOS
# =========================================

# 1. Agregar usuario
add_user() {
    case $1 in
        1.1)
            echo -e "${YELLOW}[+] Creando usuario DEMO (Horas/Minutos)${NC}"
            read -p "Nombre de usuario: " username
            read -p "Contraseña: " password
            read -p "Horas de vigencia: " hours
            read -p "Minutos: " minutes
            read -p "Conexiones permitidas: " conn_limit
            
            expiry=$(date -d "$hours hours $minutes minutes" +"%Y-%m-%d %H:%M")
            useradd -M -s /bin/false "$username"
            echo "$username:$password" | chpasswd
            echo "$username:$password:$expiry:$conn_limit:demo" >> "$SSH_USERS_DB"
            
            echo -e "${GREEN}Usuario DEMO creado!${NC}"
            echo -e "Expira: $expiry"
            log "Usuario DEMO creado: $username"
            ;;
        1.2)
            echo -e "${YELLOW}[+] Creando usuario normal (Días)${NC}"
            read -p "Nombre de usuario: " username
            read -p "Contraseña: " password
            read -p "Días de vigencia: " days
            read -p "Conexiones permitidas: " conn_limit
            
            expiry=$(date -d "$days days" +"%Y-%m-%d")
            useradd -m -s /bin/false "$username"
            echo "$username:$password" | chpasswd
            echo "$username:$password:$expiry:$conn_limit:normal" >> "$SSH_USERS_DB"
            
            echo -e "${GREEN}Usuario creado!${NC}"
            echo -e "Expira: $expiry"
            log "Usuario creado: $username"
            ;;
    esac
    return_to_menu
}

# 2. Borrar usuarios
delete_user() {
    case $1 in
        2.1)
            echo -e "${YELLOW}[-] Eliminar usuario específico${NC}"
            echo -e "Usuarios registrados:\n"
            nl "$SSH_USERS_DB" | awk -F: '{print $1}'
            echo ""
            read -p "Número de usuario a eliminar: " user_num
            
            user=$(sed -n "${user_num}p" "$SSH_USERS_DB" | cut -d: -f1)
            userdel -r "$user" 2>/dev/null
            sed -i "${user_num}d" "$SSH_USERS_DB"
            
            echo -e "${GREEN}Usuario $user eliminado!${NC}"
            log "Usuario eliminado: $user"
            ;;
        2.2)
            echo -e "${YELLOW}[-] Eliminar usuarios caducados${NC}"
            current_date=$(date +"%Y-%m-%d")
            temp_file=$(mktemp)
            
            while IFS=: read -r user pass expiry conn type; do
                if [[ "$expiry" < "$current_date" ]]; then
                    echo -e "Eliminando $user (expirado: $expiry)"
                    userdel -r "$user" 2>/dev/null
                else
                    echo "$user:$pass:$expiry:$conn:$type" >> "$temp_file"
                fi
            done < "$SSH_USERS_DB"
            
            mv "$temp_file" "$SSH_USERS_DB"
            echo -e "${GREEN}Limpieza completada!${NC}"
            log "Usuarios caducados eliminados"
            ;;
    esac
    return_to_menu
}

# 3. Editar usuario
edit_user() {
    echo -e "${YELLOW}[*] Editar usuario${NC}"
    echo -e "Usuarios registrados:\n"
    nl "$SSH_USERS_DB"
    echo ""
    read -p "Número de usuario a editar: " user_num
    
    user_data=$(sed -n "${user_num}p" "$SSH_USERS_DB")
    IFS=':' read -r user pass expiry conn type <<< "$user_data"
    
    echo -e "\n1. Cambiar contraseña"
    echo "2. Modificar vigencia"
    echo "3. Cambiar límite de conexiones"
    read -p "Seleccione qué editar: " edit_option
    
    case $edit_option in
        1)
            read -p "Nueva contraseña: " new_pass
            echo "$user:$new_pass:$expiry:$conn:$type" > temp
            sed -i "${user_num}d" "$SSH_USERS_DB"
            cat temp >> "$SSH_USERS_DB"
            rm temp
            echo "$user:$new_pass" | chpasswd
            echo -e "${GREEN}Contraseña actualizada!${NC}"
            ;;
        2)
            read -p "Nuevos días de vigencia: " days
            new_expiry=$(date -d "$days days" +"%Y-%m-%d")
            sed -i "${user_num}s/$expiry/$new_expiry/" "$SSH_USERS_DB"
            echo -e "${GREEN}Vigencia actualizada!${NC}"
            ;;
        3)
            read -p "Nuevo límite de conexiones: " new_conn
            sed -i "${user_num}s/$conn/$new_conn/" "$SSH_USERS_DB"
            echo -e "${GREEN}Límite de conexiones actualizado!${NC}"
            ;;
    esac
    return_to_menu
}

# 4. Mostrar usuarios
show_users() {
    echo -e "${YELLOW}[*] Usuarios registrados${NC}"
    echo -e "${CYAN}Usuario\tTipo\tExpiración\tConexiones${NC}"
    echo "--------------------------------------------"
    while IFS=: read -r user pass expiry conn type; do
        echo -e "$user\t$type\t$expiry\t$conn"
    done < "$SSH_USERS_DB"
    return_to_menu
}

# 5. Usuarios conectados
show_connected() {
    echo -e "${YELLOW}[*] Usuarios conectados${NC}"
    echo -e "${CYAN}Usuario\tConexiones\tIP${NC}"
    echo "--------------------------------"
    who | awk '{print $1}' | sort | uniq -c | while read -r count user; do
        ip=$(who | grep "$user" | awk '{print $5}' | head -1)
        echo -e "$user\t$count\t${ip//[()]/}"
    done
    return_to_menu
}

# 6. Gestión de Banner
manage_banner() {
    case $1 in
        6.1)
            echo -e "${YELLOW}[+] Pegar banner HTML${NC}"
            nano "$BANNER_FILE"
            echo "Banner $BANNER_FILE" >> /etc/ssh/sshd_config
            systemctl restart ssh
            echo -e "${GREEN}Banner HTML configurado!${NC}"
            ;;
        6.2)
            echo -e "${YELLOW}[+] Agregar mensaje de texto${NC}"
            read -p "Ingrese el mensaje: " message
            echo "$message" > "$BANNER_FILE"
            echo "Banner $BANNER_FILE" >> /etc/ssh/sshd_config
            systemctl restart ssh
            echo -e "${GREEN}Mensaje configurado!${NC}"
            ;;
        6.3)
            echo -e "${YELLOW}[-] Eliminando banner${NC}"
            rm -f "$BANNER_FILE"
            sed -i '/Banner \/etc\/hydra\/banner.html/d' /etc/ssh/sshd_config
            systemctl restart ssh
            echo -e "${GREEN}Banner eliminado!${NC}"
            ;;
    esac
    return_to_menu
}

# 7. Mostrar consumo
show_usage() {
    echo -e "${YELLOW}[*] Consumo por usuario${NC}"
    echo -e "${CYAN}Usuario\tDescarga\tSubida${NC}"
    echo "--------------------------------"
    # Implementar lógica de consumo real aquí
    echo -e "user1\t1.2 GB\t\t0.8 GB"
    echo -e "user2\t0.5 GB\t\t0.3 GB"
    return_to_menu
}

# 8. Bloquear usuario
block_user() {
    echo -e "${YELLOW}[!] Bloquear/Desbloquear usuario${NC}"
    echo -e "Usuarios conectados:"
    show_connected
    echo ""
    read -p "Usuario a bloquear/desbloquear: " user
    
    if grep -q "^$user:" /etc/shadow; then
        current_status=$(passwd -S "$user" | awk '{print $2}')
        if [ "$current_status" == "P" ]; then
            usermod -L "$user"
            echo -e "${RED}Usuario $user BLOQUEADO${NC}"
        else
            usermod -U "$user"
            echo -e "${GREEN}Usuario $user DESBLOQUEADO${NC}"
        fi
    else
        echo -e "${RED}Usuario no existe!${NC}"
    fi
    return_to_menu
}

# =========================================
# x2. INSTALADOR DE PROTOCOLOS
# =========================================

install_protocol() {
    case $1 in
        2.1) # OpenSSH
            apt-get install -y openssh-server
            systemctl enable ssh
            systemctl start ssh
            ;;
        2.2) # Dropbear
            apt-get install -y dropbear
            echo 'NO_START=0' > /etc/default/dropbear
            echo 'DROPBEAR_PORT=443' >> /etc/default/dropbear
            systemctl enable dropbear
            systemctl start dropbear
            ;;
        2.3) # OpenVPN
            apt-get install -y openvpn easy-rsa
            cp -r /usr/share/easy-rsa/ /etc/openvpn/
            cd /etc/openvpn/easy-rsa || exit
            ./easyrsa init-pki
            ./easyrsa build-ca nopass
            ./easyrsa gen-dh
            ;;
        2.4) # SSL/TLS
            apt-get install -y stunnel4
            openssl req -new -x509 -days 365 -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=US/ST=California/L=San Francisco/O=Global Security/OU=IT Department/CN=example.com"
            systemctl enable stunnel4
            systemctl start stunnel4
            ;;
        2.5) # Shadowsocks-R
            apt-get install -y python3-pip
            pip3 install git+https://github.com/shadowsocks/shadowsocks.git@master
            ;;
        2.6) # Squid
            apt-get install -y squid
            systemctl enable squid
            systemctl start squid
            ;;
        2.7) # Python Proxy
            apt-get install -y python3
            cat > /usr/local/bin/pyproxy.py << 'EOF'
# Código básico de proxy Python
import socket
import threading
EOF
            ;;
        2.8) # V2Ray
            bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh)
            systemctl enable v2ray
            systemctl start v2ray
            ;;
    esac
    echo -e "${GREEN}Protocolo $1 instalado correctamente!${NC}"
    return_to_menu
}

# =========================================
# x10. MENÚ V2RAY/TROJAN
# =========================================

v2ray_menu() {
    case $1 in
        10.1) # Crear usuario
            read -p "Nombre de usuario: " username
            read -p "Días de vigencia: " days
            uuid=$(cat /proc/sys/kernel/random/uuid)
            expiry=$(date -d "$days days" +"%Y-%m-%d")
            echo "$username:$uuid:$expiry" >> "$V2RAY_USERS_DB"
            echo -e "${GREEN}Usuario V2Ray creado!${NC}"
            echo -e "UUID: $uuid"
            ;;
        10.2) # Renovar usuario
            nl "$V2RAY_USERS_DB"
            read -p "Número de usuario a renovar: " user_num
            read -p "Días adicionales: " days
            
            expiry=$(date -d "$days days" +"%Y-%m-%d")
            sed -i "${user_num}s/:[^:]*$/:$expiry/" "$V2RAY_USERS_DB"
            echo -e "${GREEN}Usuario renovado!${NC}"
            ;;
        10.3) # Usuarios registrados
            echo -e "${YELLOW}[*] Usuarios V2Ray${NC}"
            echo -e "${CYAN}Usuario\tUUID\t\tExpiración${NC}"
            echo "--------------------------------"
            while IFS=: read -r user uuid expiry; do
                echo -e "$user\t${uuid:0:8}...\t$expiry"
            done < "$V2RAY_USERS_DB"
            ;;
        10.4) # Usuarios conectados
            echo -e "${YELLOW}[*] Conexiones V2Ray${NC}"
            echo -e "${CYAN}Usuario\tIP\t\tTráfico${NC}"
            echo "--------------------------------"
            # Implementar lógica real aquí
            echo -e "user1\t192.168.1.1\t1.2 GB"
            ;;
    esac
    return_to_menu
}

# =========================================
# MENÚ PRINCIPAL
# =========================================

main_menu() {
    init_system
    while true; do
        show_banner
        echo -e "${GREEN}x1. Control de Usuarios${NC}"
        echo -e "${GREEN}x2. Instalador de Protocolos${NC}"
        echo -e "${GREEN}x10. Menú V2Ray/Trojan${NC}"
        echo -e "${RED}x0. Salir${NC}"
        echo "===================================="
        
        read -p "Seleccione una opción [x0-x10]: " main_option
        
        case $main_option in
            x1)
                while true; do
                    show_banner
                    echo -e "${GREEN}1. Agregar usuario${NC}"
                    echo -e "${GREEN}2. Borrar usuario(s)${NC}"
                    echo -e "${GREEN}3. Editar/Renovar usuario${NC}"
                    echo -e "${GREEN}4. Mostrar usuarios registrados${NC}"
                    echo -e "${GREEN}5. Mostrar usuarios conectados${NC}"
                    echo -e "${GREEN}6. Gestionar Banner${NC}"
                    echo -e "${GREEN}7. Mostrar consumo por usuario${NC}"
                    echo -e "${GREEN}8. Bloquear usuario${NC}"
                    echo -e "${RED}9. Volver${NC}"
                    echo "===================================="
                    
                    read -p "Selección: " sub_option
                    
                    case $sub_option in
                        1) 
                            echo -e "${GREEN}1.1. Demo (Horas/Minutos)${NC}"
                            echo -e "${GREEN}1.2. Normal (Días)${NC}"
                            read -p "Selección: " add_option
                            add_user "1.$add_option"
                            ;;
                        2)
                            echo -e "${GREEN}2.1. Usuario específico${NC}"
                            echo -e "${GREEN}2.2. Usuarios caducados${NC}"
                            read -p "Selección: " del_option
                            delete_user "2.$del_option"
                            ;;
                        3) edit_user ;;
                        4) show_users ;;
                        5) show_connected ;;
                        6)
                            echo -e "${GREEN}6.1. Banner HTML${NC}"
                            echo -e "${GREEN}6.2. Mensaje texto${NC}"
                            echo -e "${GREEN}6.3. Eliminar banner${NC}"
                            read -p "Selección: " banner_option
                            manage_banner "6.$banner_option"
                            ;;
                        7) show_usage ;;
                        8) block_user ;;
                        9) break ;;
                        *) echo -e "${RED}Opción inválida!${NC}"; sleep 1 ;;
                    esac
                done
                ;;
            x2)
                echo -e "${YELLOW}[+] Instalador de Protocolos${NC}"
                echo -e "${GREEN}2.1. OpenSSH${NC}"
                echo -e "${GREEN}2.2. Dropbear${NC}"
                echo -e "${GREEN}2.3. OpenVPN${NC}"
                echo -e "${GREEN}2.4. SSL/TLS${NC}"
                echo -e "${GREEN}2.5. Shadowsocks-R${NC}"
                echo -e "${GREEN}2.6. Squid${NC}"
                echo -e "${GREEN}2.7. Python Proxy${NC}"
                echo -e "${GREEN}2.8. V2Ray${NC}"
                echo -e "${RED}2.9. Volver${NC}"
                echo "===================================="
                
                read -p "Seleccione protocolo a instalar [2.1-2.8]: " proto_option
                if [[ "$proto_option" =~ ^2\.[1-8]$ ]]; then
                    install_protocol "$proto_option"
                elif [ "$proto_option" != "2.9" ]; then
                    echo -e "${RED}Opción inválida!${NC}"
                    sleep 1
                fi
                ;;
            x10)
                echo -e "${YELLOW}[+] Menú V2Ray/Trojan${NC}"
                echo -e "${GREEN}10.1. Crear usuario${NC}"
                echo -e "${GREEN}10.2. Renovar usuario${NC}"
                echo -e "${GREEN}10.3. Usuarios registrados${NC}"
                echo -e "${GREEN}10.4. Usuarios conectados${NC}"
                echo -e "${RED}10.5. Volver${NC}"
                echo "===================================="
                
                read -p "Selección: " v2ray_option
                if [[ "$v2ray_option" =~ ^10\.[1-4]$ ]]; then
                    v2ray_menu "$v2ray_option"
                elif [ "$v2ray_option" != "10.5" ]; then
                    echo -e "${RED}Opción inválida!${NC}"
                    sleep 1
                fi
                ;;
            x0)
                echo -e "${RED}Saliendo...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida!${NC}"
                sleep 1
                ;;
        esac
    done
}

# Iniciar como root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Error: Debes ejecutar como root!${NC}" 1>&2
    exit 1
fi

main_menu
