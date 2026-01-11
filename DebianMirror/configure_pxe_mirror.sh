#!/bin/bash
# Script: configure_pxe_mirror.sh
# Descripción: Configura Apache, TFTP y DHCP para arrancar Debian 12 (amd64/arm64) via PXE.
#              Servidor en red aislada: 192.168.10.x.

# --- 1. CONFIGURACIÓN DEL ENTORNO DE RED AISLADA ---
SERVER_IP="192.168.10.1"
NETWORK_SUBNET="192.168.10.0"
NETMASK="255.255.255.0"
IP_RANGE_START="192.168.10.20"
IP_RANGE_END="192.168.10.50"
GATEWAY="192.168.10.1" # El propio servidor actúa como Gateway si es una red aislada

HTTP_ROOT="$HOME/public_html"
PXE_ROOT="/srv/tftp"

# Interfaz de red a usar para el servicio (Debe ser eth0)
NET_INTERFACE="eth0" 

# URLs para descargar los archivos de netboot (usando deb.debian.org)
DEBIAN_NETBOOT_URL="http://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/"
DEBIAN_ARM64_NETBOOT_URL="http://deb.debian.org/debian/dists/bookworm/main/installer-arm64/current/images/netboot/"

# --- 2. INSTALACIÓN DE SERVICIOS ---
echo "--- Instalando servicios necesarios (Apache, DHCP, TFTP) ---"
# Es fundamental que el servidor tenga acceso temporal a internet para la instalación
sudo apt update
sudo apt install -y apache2 tftpd-hpa isc-dhcp-server syslinux-common wget

# --- 3. CONFIGURACIÓN DE LA IP ESTÁTICA (eth0) ---
echo "--- Configuracion de la IP estatica en $NET_INTERFACE ---"
# Este script asume que la configuración de red se hace con netplan o /etc/network/interfaces.
# Si estás en un sistema moderno (Netplan), la configuración es manual y este script no la toca.
# Si estás en un sistema antiguo (/etc/network/interfaces):
# sudo tee /etc/network/interfaces.d/eth0.conf > /dev/null <<EOF
# auto $NET_INTERFACE
# iface $NET_INTERFACE inet static
# address $SERVER_IP
# netmask $NETMASK
# EOF
# NOTA: La configuración de red es crítica y varía mucho. Se asume que $SERVER_IP ya está configurada.

# --- 4. CONFIGURACIÓN DE APACHE (HTTP) ---
echo "--- Configurando Apache para servir los mirrors ---"
mkdir -p "$HTTP_ROOT"

# Configuración de Virtual Host simple para Apache
APACHE_CONF="
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot $HTTP_ROOT

    <Directory $HTTP_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>"

echo "$APACHE_CONF" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
sudo a2enmod headers
sudo systemctl restart apache2
echo "Apache configurado. Mirror accesible via http://$SERVER_IP/"

# --- 5. GENERACIÓN DE ARCHIVOS PRESEED.CFG ---
echo "--- Generando preseed.cfg para la instalación desatendida ---"

PRESEED_CONTENT=$(cat <<EOF
# Archivo: preseed.cfg (Generado automáticamente para 192.168.10.x)
d-i debian-installer/locale string es_ES.UTF-8
d-i keyboard-configuration/xkb-keymap select es
d-i netcfg/get_hostname string ch9-radio
d-i netcfg/get_domain string local

# --- Configuracion del Mirror ---
d-i mirror/protocol string http
d-i mirror/country string enter manually
d-i mirror/http/hostname string $SERVER_IP
d-i mirror/http/directory string /mirror/debian/
d-i mirror/suite string bookworm
d-i debian-installer/add-source boolean true

# --- Cuentas y Contraseñas ---
d-i passwd/root-password password tu_password_root
d-i passwd/root-password-again password tu_password_root
d-i passwd/user-fullname string Operador CH9
d-i passwd/username string sysop
d-i passwd/user-password password tu_password_sysop
d-i passwd/user-password-again password tu_password_sysop

# --- Particionamiento Simple (SIN LVM) ---
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select standard
d-i partman-auto/confirm_nochanges boolean true
d-i partman-commit/confirm_title string Finalizar particionamiento
d-i partman-commit/confirm boolean true

# --- Repositorio Channel-9 Local ---
d-i apt-setup/local0/repository string http://$SERVER_IP/ch9/debian bookworm main
d-i apt-setup/local0/comment string Channel-9 Repository
d-i apt-setup/local0/source boolean true

# --- Seleccion de Software ---
d-i tasksel/first multiselect standard

# --- Finalizacion ---
d-i clock-setup/ntp boolean false 
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_boot_drive boolean true
d-i finish-install/reboot boolean true
EOF
)

echo "$PRESEED_CONTENT" > "$HTTP_ROOT/preseed.cfg"
echo "Archivo preseed.cfg generado en $HTTP_ROOT/preseed.cfg"

# --- 6. CONFIGURACIÓN DE TFTP (PXE Boot) ---
echo "--- Configurando Servidor TFTP y descargando archivos de arranque ---"
sudo mkdir -p "$PXE_ROOT/debian-amd64/pxelinux.cfg"
sudo mkdir -p "$PXE_ROOT/debian-arm64" 

# Descargar archivos de netboot AMD64
echo "Descargando netboot AMD64..."
sudo wget -O "$PXE_ROOT/debian-amd64/vmlinuz" "$DEBIAN_NETBOOT_URL/vmlinuz"
sudo wget -O "$PXE_ROOT/debian-amd64/initrd.gz" "$DEBIAN_NETBOOT_URL/initrd.gz"
sudo cp /usr/lib/syslinux/modules/bios/pxelinux.0 "$PXE_ROOT/"
sudo cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$PXE_ROOT/"

# Descargar archivos de netboot ARM64
echo "Descargando netboot ARM64..."
sudo wget -O "$PXE_ROOT/debian-arm64/vmlinuz" "$DEBIAN_ARM64_NETBOOT_URL/vmlinuz"
sudo wget -O "$PXE_ROOT/debian-arm64/initrd.gz" "$DEBIAN_ARM64_NETBOOT_URL/initrd.gz"

# Configuración PXE: /srv/tftp/pxelinux.cfg/default
PXE_DEFAULT_CONF="
DEFAULT menu
PROMPT 0
TIMEOUT 300

MENU TITLE Channel-9 PXE Boot Menu

LABEL debian-amd64
    MENU LABEL Debian 12 AMD64 (Netinstall Local - Preseed)
    KERNEL debian-amd64/vmlinuz
    APPEND initrd=debian-amd64/initrd.gz auto=true url=http://$SERVER_IP/preseed.cfg debian-installer/language=es locale=es_ES.UTF-8 keyboard-configuration/xkb-keymap=es

LABEL debian-arm64
    MENU LABEL Debian 12 ARM64 (Netinstall Local - Preseed)
    KERNEL debian-arm64/vmlinuz
    APPEND initrd=debian-arm64/initrd.gz auto=true url=http://$SERVER_IP/preseed.cfg debian-installer/language=es locale=es_ES.UTF-8 keyboard-configuration/xkb-keymap=es

LABEL local
    MENU LABEL Boot local hard drive
    LOCALBOOT 0
"

echo "$PXE_DEFAULT_CONF" | sudo tee "$PXE_ROOT/pxelinux.cfg/default" > /dev/null
sudo chmod -R 755 "$PXE_ROOT"
sudo systemctl restart tftpd-hpa
echo "TFTP configurado. El archivo de arranque es $PXE_ROOT/pxelinux.0"

# --- 7. CONFIGURACIÓN DE DHCP ---
echo "--- Configurando DHCP Server para 192.168.10.x ---"
# Establecer la interfaz de red para DHCP
echo "INTERFACESv4=\"$NET_INTERFACE\"" | sudo tee /etc/default/isc-dhcp-server > /dev/null

DHCP_CONF="
# Configuración DHCP para PXE en la subred aislada 192.168.10.x
default-lease-time 600;
max-lease-time 7200;
ddns-update-style none;

subnet $NETWORK_SUBNET netmask $NETMASK {
    range $IP_RANGE_START $IP_RANGE_END;
    option broadcast-address $NETWORK_SUBNET;
    option routers $GATEWAY;
    
    # DNS puede ser la propia IP del servidor (si corre DNS) o no se usa si esta aislado
    option domain-name-servers $SERVER_IP; 

    # Opciones clave para PXE
    filename \"pxelinux.0\";
    next-server $SERVER_IP; 
}
"
echo "$DHCP_CONF" | sudo tee /etc/dhcp/dhcpd.conf > /dev/null

# Reiniciar DHCP
echo "Reiniciando DHCP Server..."
sudo systemctl restart isc-dhcp-server

echo "------------------------------------------------------------------"
echo "✅ INFRAESTRUCTURA PXE/MIRROR CONFIGURADA EN RED AISLADA (192.168.10.x)."
echo "El servidor ahora está listo para la instalación de red en $NET_INTERFACE."
echo ""
echo "!!! VERIFICA QUE LA IP ESTATICA DEL SERVIDOR ES $SERVER_IP Y LA INTERFAZ ES $NET_INTERFACE !!!"
echo "!!! ASEGURATE DE CAMBIAR LAS CONTRASEÑAS POR SEGURIDAD !!!"
echo "------------------------------------------------------------------"

