#!/bin/bash
# Script para crear un mirror APT local que contiene ÚNICAMENTE los paquetes de Proxmox VE 8.x.
# Asume que el mirror de Debian 12 (bookworm) ya existe en otra ubicación.
# Requiere que el paquete 'debmirror' esté instalado.

# --- 1. CONFIGURACIÓN DEL MIRROR ---
TARGET_BASE="$HOME/public_html"
TARGET_PROXMOX="$TARGET_BASE/mirror/proxmox"
ARCHITECTURES="amd64"
KEYRING_PROXMOX="/usr/share/keyrings/proxmox-archive-keyring.gpg" # Ubicación común

echo "--- 🚀 INICIANDO CREACIÓN DE MIRROR APT SOLO PROXMOX VE OFFLINE ---"
echo "Directorio de destino: $TARGET_PROXMOX"

# --- 2. VERIFICACIÓN DE HERRAMIENTAS ---
if ! command -v debmirror &> /dev/null; then
    echo "❌ Error: La herramienta 'debmirror' no está instalada."
    echo "   Por favor, instálela con: sudo apt install debmirror"
    exit 1
fi

mkdir -p "$TARGET_PROXMOX" || { echo "Error al crear el directorio de Proxmox. Saliendo."; exit 1; }

# --- 3. MIRROR PROXMOX VE 8.x (No-Subscription) ---
echo ""
echo "--- ⬇️ Descargando repositorios de PROXMOX VE (pve-no-subscription) ---"

# Nota: Se utiliza el componente 'pve-no-subscription' y se apunta al directorio de Proxmox.
debmirror \
    --host=download.proxmox.com \
    --root=debian \
    --method=http \
    --dist=bookworm \
    --component=pve-no-subscription \
    --arch="$ARCHITECTURES" \
    --progress \
    --no-source \
    --nosource \
    --cleanup \
    --keyring="$KEYRING_PROXMOX" \
    "$TARGET_PROXMOX"

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló el mirror de Proxmox VE. Revisar la conexión o la clave."
    echo "   (La clave de Proxmox puede necesitar ser importada manualmente si no está en el sistema)"
    exit 1
fi
echo "✅ Mirror de Proxmox VE completado en: $TARGET_PROXMOX"


# --- 4. INSTRUCCIONES POST-DESCARGA ---
echo ""
echo "--- 🎉 CREACIÓN DE MIRROR COMPLETADA ---"
echo "Para usar este mirror OFFLINE en tu servidor Proxmox, debes editar los archivos sources.list:"
echo "1. Configurar un servidor web local (ej. Nginx o Apache) para servir el contenido de $TARGET_BASE."
echo "   La estructura será: http://[IP_Local_del_Mirror]/apt/proxmox/"
echo "2. En la máquina Proxmox instalada, edita los archivos /etc/apt/sources.list.d/* para que queden así:"
echo ""
echo "   # 1. Repositorios Base Debian 12 (¡Ya existentes en tu otro mirror!)"
echo "   deb http://[IP_Local_del_Mirror]/[ruta_a_debian]/ bookworm main"
echo ""
echo "   # 2. Repositorio Proxmox VE No-Subscription (usando este nuevo mirror)"
echo "   deb http://[IP_Local_del_Mirror]/apt/proxmox bookworm pve-no-subscription"
echo ""
echo "   # 3. Elimina o comenta (con #) la línea del repositorio enterprise por defecto de Proxmox."
