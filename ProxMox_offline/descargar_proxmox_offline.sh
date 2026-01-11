#!/bin/bash
# Script para descargar todos los recursos de Proxmox necesarios para una instalación offline.
# Incluye ISOs principales, Plantilla LXC, Imágenes QEMU/KVM y Código Fuente CLAVE.
# Version PVE 8.4-1 (Basada en Debian 12 Bookworm)

# --- 1. CONFIGURACIÓN ---
# Directorio de destino
TARGET_DIR="$HOME/public_html/mirror/proxmox/ISO"

# URLs de Recursos Principales
ISO_PVE_URL="https://enterprise.proxmox.com/iso/proxmox-ve_8.4-1.iso"
ISO_PBS_URL="https://enterprise.proxmox.com/iso/proxmox-backup-server_3.2-1.iso" # PBS 3.2-1 (Basado en Debian 12)
TEMPLATE_URL="https://download.proxmox.com/images/system/debian-12-standard_12.2-1_amd64.tar.zst"

# URLs de Imágenes QEMU/KVM (qcow2) - para pruebas
declare -A QEMU_IMAGES=(
    ["debian-12-cloud"]="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
    ["debian-11-cloud"]="https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
    ["ubuntu-2204-cloud"]="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
)

# ESTO SE HA MOVIDO EN OTRO SCRIPT Repositorios de Código Fuente clave (URLs de CLONE de GitHub)
#declare -a GIT_REPOS=(
#    "https://github.com/proxmox/pve-kernel.git"
#    "https://github.com/proxmox/pve-manager.git"
#    "https://github.com/proxmox/pve-lxc.git"
#    "https://github.com/proxmox/pve-qemu-server.git"
#    "https://github.com/proxmox/pve-storage.git"
#)
#
#echo "--- 🚀 INICIANDO DESCARGA DE RECURSOS PROXMOX OFFLINE ---"
#echo "Directorio de destino: $TARGET_DIR"
#


# --- 2. PREPARACIÓN DEL DIRECTORIO ---
if [ ! -d "$TARGET_DIR" ]; then
    echo "Creando directorio: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

cd "$TARGET_DIR" || { echo "Error al cambiar al directorio $TARGET_DIR. Saliendo."; exit 1; }

# --- 3. FUNCIÓN DE DESCARGA WGET ---
download_file() {
    local url=$1
    local output_file=$2
    local description=$3

    if [ ! -f "$output_file" ]; then
        echo "⬇️ Descargando $description..."
        wget -c "$url" -O "$output_file"
        if [ $? -ne 0 ]; then
            echo "⚠️ ADVERTENCIA: La descarga de $description falló o se interrumpió."
        else
            echo "✅ Descarga de $description completada."
        fi
    else
        echo "✅ $description ya existe. Saltando descarga."
    fi
}

# --- 4. DESCARGA DE ISOs y LXC ---
echo ""
echo "--- 💿 DESCARGA DE ISOS Y PLANTILLAS ---"
download_file "$ISO_PVE_URL" "$(basename "$ISO_PVE_URL")" "ISO de Proxmox VE (PVE)"
download_file "$ISO_PBS_URL" "$(basename "$ISO_PBS_URL")" "ISO de Proxmox Backup Server (PBS)"
download_file "$TEMPLATE_URL" "$(basename "$TEMPLATE_URL")" "Plantilla LXC Debian 12"

# --- 5. DESCARGA DE IMAGENES QEMU/KVM (qcow2) ---
echo ""
echo "--- 🖼️ DESCARGANDO IMÁGENES QEMU/KVM (PRUEBAS) ---"
QEMU_DIR="qemu_images"
mkdir -p "$QEMU_DIR"

for name in "${!QEMU_IMAGES[@]}"; do
    url="${QEMU_IMAGES[$name]}"
    output_name=$(basename "$url")
    download_file "$url" "$QEMU_DIR/$output_name" "Imagen QEMU $name"
done

# --- 6. DESCARGA DE CÓDIGO FUENTE (GIT CLONE) ---
echo ""
echo "--- 💻 CLONANDO REPOSITORIOS DE CÓDIGO FUENTE ---"

GIT_DIR="source_code"
mkdir -p "$GIT_DIR"

for repo_url in "${GIT_REPOS[@]}"; do
    repo_name=$(basename "$repo_url" .git)
    repo_path="$GIT_DIR/$repo_name"
    
    if [ -d "$repo_path" ]; then
        echo "🔄 $repo_name ya existe. Intentando actualizar (pull)..."
        (
            cd "$repo_path" && git pull --rebase
        ) || echo "⚠️ ADVERTENCIA: No se pudo actualizar $repo_name."
    else
        echo "⬇️ Clonando $repo_name..."
        git clone "$repo_url" "$repo_path"
        [ $? -ne 0 ] && echo "⚠️ ADVERTENCIA: No se pudo clonar $repo_name." || echo "✅ Clonación de $repo_name completada."
    fi
done

echo ""
echo "--- 🎉 DESCARGA DE RECURSOS PROXMOX COMPLETADA ---"
echo "Todo el material se encuentra en $TARGET_DIR"

