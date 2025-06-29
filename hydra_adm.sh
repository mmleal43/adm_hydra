#!/bin/bash
# HYDRA VPS Installer & User Control Script - v1.0
# Compatible con Ubuntu 18.04/20.04/22.04+

# =========== VARIABLES GLOBALES ============
USERS_DB="/etc/hydra-users.db"
V2RAY_USERS_DB="/etc/hydra-v2ray.db"

# =========== FUNCIONES DE USUARIO SSH/DROPBEAR ============

crear_usuario_demo() {
    echo "=== Crear Usuario SSH/Dropbear DEMO (por minutos/horas) ==="
    read -p "Nombre de usuario: " user
    read -p "Contraseña: " pass
    read -p "Horas de duración: " horas
    read -p "Minutos de duración: " mins
    read -p "Conexiones máximas: " max
    useradd -M -s /bin/false $user
    echo "$user:$pass" | chpasswd
    expire_time=$(( ($(date +%s) + horas*3600 + mins*60) ))
    echo "$user|$(date +%s)|$expire_time|$max" >> "$USERS_DB"
    echo "Usuario demo creado hasta $(date -d @$expire_time)"
}

crear_usuario_normal() {
    echo "=== Crear Usuario SSH/Dropbear (por días/meses) ==="
    read -p "Nombre de usuario: " user
    read -p "Contraseña: " pass
    read -p "Días de duración: " dias
    read -p "Conexiones máximas: " max
    useradd -M -s /bin/false $user
    echo "$user:$pass" | chpasswd
    expire_time=$(( ($(date +%s) + dias*86400) ))
    echo "$user|$(date +%s)|$expire_time|$max" >> "$USERS_DB"
    echo "Usuario creado hasta $(date -d @$expire_time)"
}

borrar_usuario() {
    echo "=== Borrar Usuario ==="
    cut -d '|' -f1 "$USERS_DB"
    read -p "Usuario a borrar: " user
    userdel -f "$user"
    sed -i "/^$user|/d" "$USERS_DB"
    echo "Usuario $user eliminado."
}

borrar_caducos() {
    echo "=== Borrar Usuarios Caducos ==="
    now=$(date +%s)
    while IFS='|' read -r u created expires max; do
        if [[ $expires -lt $now ]]; then
            userdel -f "$u"
            sed -i "/^$u|/d" "$USERS_DB"
            echo "Eliminado $u (caducado)"
        fi
    done < "$USERS_DB"
}

mostrar_usuarios() {
    echo "=== Usuarios Registrados ==="
    while IFS='|' read -r u created expires max; do
        echo "$u - Vence: $(date -d @$expires) - Conexiones: $max"
    done < "$USERS_DB"
    read -p "Presione ENTER para continuar..."
}

# =========== INSTALADOR DE PROTOCOLOS ============

instalar_protocolos() {
    echo "=== Instalador de Protocolos ==="
    echo "1) OpenSSH"
    echo "2) Dropbear"
    echo "3) OpenVPN"
    echo "4) SSL/TLS (stunnel)"
    echo "5) Shadowsocks-r"
    echo "6) Squid"
    echo "7) Proxy Python"
    echo "8) V2Ray"
    echo "0) Volver"
    read -p "Seleccione una opción: " p
    case $p in
        1) apt install -y openssh-server ;;
        2) apt install -y dropbear ;;
        3) apt install -y openvpn ;;
        4) apt install -y stunnel4 ;;
        5) echo "Shadowsocks-r requiere instalación manual." ;;
        6) apt install -y squid ;;
        7) pip install --upgrade pip && pip install http.server ;;
        8) bash <(curl -Ls https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) ;;
        0) return ;;
        *) echo "Opción inválida." ;;
    esac
    read -p "Presione ENTER para continuar..."
}

# =========== MENÚ PRINCIPAL ============

menu_usuario() {
    while true; do
        clear
        echo "==== CONTROL DE USUARIO ===="
        echo "1.1) Crear usuario demo (SSH/Dropbear)"
        echo "1.2) Crear usuario normal (SSH/Dropbear)"
        echo "2.1) Borrar usuario manual"
        echo "2.2) Borrar usuarios caducos"
        echo "4) Mostrar usuarios"
        echo "0) Volver al menú principal"
        read -p "Seleccione una opción: " op
        case $op in
            1.1) crear_usuario_demo ;;
            1.2) crear_usuario_normal ;;
            2.1) borrar_usuario ;;
            2.2) borrar_caducos ;;
            4) mostrar_usuarios ;;
            0) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

main_menu() {
    mkdir -p /etc/hydra
    touch "$USERS_DB"

    while true; do
        clear
        echo "=============================="
        echo "     HYDRA VPS MANAGER"
        echo "=============================="
        echo "1) Control de Usuario SSH/Dropbear"
        echo "2) Instalador de Protocolos"
        echo "3) Salir"
        echo "=============================="
        read -p "Seleccione una opción: " opt
        case $opt in
            1) menu_usuario ;;
            2) instalar_protocolos ;;
            3) exit 0 ;;
            *) echo "Opción inválida"; read ;;
        esac
    done
}

main_menu
