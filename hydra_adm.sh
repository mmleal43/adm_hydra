#!/bin/bash
# HYDRA VPS Installer & User Control Script - v1.1
# Compatible con Ubuntu 18.04/20.04/22.04+

# =========== VARIABLES GLOBALES ============
USERS_DB="/etc/hydra-users.db"
V2RAY_USERS_DB="/etc/hydra-v2ray-users.db"

# =========== FUNCIONES DE USUARIO SSH/DROPBEAR ============

crear_usuario_demo() {
    echo "=== Crear Usuario SSH/Dropbear DEMO (por minutos/horas) ==="
    read -p "Nombre de usuario: " user
    read -p "Contraseña: " pass
    read -p "Horas de duración: " horas
    read -p "Minutos de duración: " mins
    read -p "Conexiones máximas: " max
    useradd -M -s /bin/false "$user"
    echo "$user:$pass" | chpasswd
    expire_time=$(( $(date +%s) + horas*3600 + mins*60 ))
    echo "$user|$(date +%s)|$expire_time|$max" >> "$USERS_DB"
    echo "Usuario demo creado hasta $(date -d @$expire_time)"
    sleep 2
}

crear_usuario_normal() {
    echo "=== Crear Usuario SSH/Dropbear (por días) ==="
    read -p "Nombre de usuario: " user
    read -p "Contraseña: " pass
    read -p "Días de duración: " dias
    read -p "Conexiones máximas: " max
    useradd -M -s /bin/false "$user"
    echo "$user:$pass" | chpasswd
    expire_time=$(( $(date +%s) + dias*86400 ))
    echo "$user|$(date +%s)|$expire_time|$max" >> "$USERS_DB"
    echo "Usuario creado hasta $(date -d @$expire_time)"
    sleep 2
}

borrar_usuario() {
    echo "=== Borrar Usuario Manual ==="
    cut -d '|' -f1 "$USERS_DB"
    read -p "Usuario a borrar: " user
    userdel -f "$user" 2>/dev/null
    sed -i "/^$user|/d" "$USERS_DB"
    echo "Usuario $user eliminado."
    sleep 2
}

borrar_caducos() {
    echo "=== Borrar Usuarios Caducos ==="
    now=$(date +%s)
    cp "$USERS_DB" "${USERS_DB}.bak"
    > "$USERS_DB"
    while IFS='|' read -r u created expires max; do
        if [[ $expires -gt $now ]]; then
            echo "$u|$created|$expires|$max" >> "$USERS_DB"
        else
            userdel -f "$u" 2>/dev/null
            echo "Eliminado $u (caducado)"
        fi
    done < "${USERS_DB}.bak"
    sleep 2
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
    while true; do
        clear
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
            5) echo "Instalación de Shadowsocks-r aún no implementada." ;;
            6) apt install -y squid ;;
            7) apt install -y python3 ;;
            8) bash <(curl -Ls https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh) ;;
            0) break ;;
            *) echo "Opción inválida." ;;
        esac
        sleep 2
    done
}

# =========== MENÚ PRINCIPAL ============

menu_usuario() {
    while true; do
        clear
        echo "==== CONTROL DE USUARIO ===="
        echo "1) Crear usuario demo (minutos/horas)"
        echo "2) Crear usuario normal (días)"
        echo "3) Borrar usuario manual"
        echo "4) Borrar usuarios caducos"
        echo "5) Mostrar usuarios registrados"
        echo "0) Volver al menú principal"
        read -p "Seleccione una opción: " op
        case $op in
            1) crear_usuario_demo ;;
            2) crear_usuario_normal ;;
            3) borrar_usuario ;;
            4) borrar_caducos ;;
            5) mostrar_usuarios ;;
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


# =========== FUNCIONES V2RAY/TROJAN ============

crear_usuario_v2ray() {
    echo "=== Crear Usuario V2Ray ==="
    read -p "Nombre de usuario: " user
    read -p "ID único (UUID, enter para generar): " uuid
    uuid=${uuid:-$(cat /proc/sys/kernel/random/uuid)}
    read -p "Path personalizado (ej: /$user): " path
    read -p "Duración en días: " dias
    expires=$(( $(date +%s) + dias*86400 ))
    echo "$user|$uuid|$path|$expires" >> "$V2RAY_USERS_DB"
    echo "Usuario V2Ray $user creado con ID $uuid y path $path válido hasta $(date -d @$expires)"
    sleep 2
}

renovar_usuario_v2ray() {
    echo "=== Renovar Usuario V2Ray ==="
    cut -d'|' -f1 "$V2RAY_USERS_DB"
    read -p "Usuario a renovar: " user
    read -p "Días adicionales: " dias
    tmpfile=$(mktemp)
    while IFS='|' read -r u uuid path exp; do
        if [[ "$u" == "$user" ]]; then
            new_exp=$(( exp + dias*86400 ))
            echo "$u|$uuid|$path|$new_exp" >> "$tmpfile"
        else
            echo "$u|$uuid|$path|$exp" >> "$tmpfile"
        fi
    done < "$V2RAY_USERS_DB"
    mv "$tmpfile" "$V2RAY_USERS_DB"
    echo "Usuario $user renovado hasta $(date -d @$new_exp)"
    sleep 2
}

listar_usuarios_v2ray() {
    echo "=== Usuarios V2Ray Registrados ==="
    while IFS='|' read -r u uuid path exp; do
        echo "$u - ID: $uuid - Path: $path - Expira: $(date -d @$exp)"
    done < "$V2RAY_USERS_DB"
    read -p "Presione ENTER para continuar..."
}

menu_v2ray_trojan() {
    touch "$V2RAY_USERS_DB"
    while true; do
        clear
        echo "==== GESTIÓN DE CUENTAS V2RAY/TROJAN ===="
        echo "1) Crear usuario V2Ray"
        echo "2) Renovar usuario"
        echo "3) Listar usuarios"
        echo "0) Volver"
        read -p "Seleccione una opción: " op
        case $op in
            1) crear_usuario_v2ray ;;
            2) renovar_usuario_v2ray ;;
            3) listar_usuarios_v2ray ;;
            0) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

# =========== BANNERS ============

pegar_banner_personalizado() {
    echo "=== Agregar banner personalizado ==="
    read -p "Pegue su banner en HTML/TXT (CTRL+D para finalizar): " banner
    cat > /etc/issue.net
    echo "$banner" >> /etc/issue.net
    echo "Banner agregado en /etc/issue.net"
    echo 'Banner /etc/issue.net' >> /etc/ssh/sshd_config
    systemctl restart ssh
    sleep 2
}

agregar_mensaje_banner() {
    echo "=== Escriba el mensaje para el banner (texto plano): ==="
    read mensaje
    echo "$mensaje" > /etc/issue.net
    echo 'Banner /etc/issue.net' >> /etc/ssh/sshd_config
    systemctl restart ssh
    echo "Mensaje agregado."
    sleep 2
}

eliminar_banner() {
    rm -f /etc/issue.net
    sed -i '/Banner \/etc\/issue.net/d' /etc/ssh/sshd_config
    systemctl restart ssh
    echo "Banner eliminado."
    sleep 2
}

menu_banner() {
    while true; do
        clear
        echo "==== GESTIÓN DE BANNERS ===="
        echo "1) Pegar banner personalizado"
        echo "2) Agregar mensaje de texto"
        echo "3) Eliminar banner"
        echo "0) Volver"
        read -p "Seleccione una opción: " op
        case $op in
            1) pegar_banner_personalizado ;;
            2) agregar_mensaje_banner ;;
            3) eliminar_banner ;;
            0) break ;;
            *) echo "Opción inválida" ;;
        esac
    done
}

# =========== ACTUALIZAR MENÚ PRINCIPAL ============

main_menu() {
    mkdir -p /etc/hydra
    touch "$USERS_DB"
    touch "$V2RAY_USERS_DB"

    while true; do
        clear
        echo "=============================="
        echo "     HYDRA VPS MANAGER"
        echo "=============================="
        echo "1) Control de Usuario SSH/Dropbear"
        echo "2) Instalador de Protocolos"
        echo "3) Gestión V2Ray/Trojan"
        echo "4) Gestión de Banner"
        echo "5) Salir"
        echo "=============================="
        read -p "Seleccione una opción: " opt
        case $opt in
            1) menu_usuario ;;
            2) instalar_protocolos ;;
            3) menu_v2ray_trojan ;;
            4) menu_banner ;;
            5) exit 0 ;;
            *) echo "Opción inválida"; read ;;
        esac
    done
}

main_menu
