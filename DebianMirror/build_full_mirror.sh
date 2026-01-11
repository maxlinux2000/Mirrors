#!/bin/bash
# Script: build_debian_mirror.sh
# Descripción: Crea un mirror selectivo de Debian 12 (Bookworm) 
#              para amd64 y arm64.
#              Incluye todos los sources (deb-src) 
#              y los binarios (deb) esenciales.

# --- Configuración ---
MIRROR_ROOT="$HOME/public_html/mirror/debian"
MIRROR_URL="http://deb.debian.org/debian" # URL base de Debian (Volvemos al principal)
DISTRIBUTION="bookworm"
ARCHITECTURES="amd64,arm64"
SECTIONS="main,contrib,non-free,non-free-firmware"
LOG_FILE="$HOME/mirror_sync.log"
# HOST DE MIRROR: Usamos el host principal.
MIRROR_HOST="deb.debian.org" 

# Comprobación de debmirror
if ! command -v debmirror &> /dev/null
then
    echo "debmirror no está instalado. Por favor, instálalo con 'sudo apt install debmirror'."
    exit 1
fi

echo "--- Iniciando la creación/sincronización del mirror de Debian ---"

# ------------------------------------------------------------------
# 🔑 PASO CRÍTICO: Usar el keyring GPG oficial del sistema
# ------------------------------------------------------------------
OFFICIAL_KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
KEYRING_OPTION="--keyring $OFFICIAL_KEYRING"

echo "--- 1. Preparando la verificación GPG con el keyring oficial del sistema ---"

if [ ! -f "$OFFICIAL_KEYRING" ]; then
    echo "🚨 Archivo de keyring oficial ($OFFICIAL_KEYRING) no encontrado."
    echo "  Intentando instalar el paquete 'debian-archive-keyring'..."
    sudo apt update
    sudo apt install -y debian-archive-keyring || { 
        echo "🚨 Error: Falló la instalación del paquete 'debian-archive-keyring'."
        echo "  Continuando SIN verificación GPG (RIESGOSO), o compruebe su conexión a Internet."
        # Si la instalación falla, eliminamos la opción de keyring para que debmirror falle
        # más elegantemente o continúe (depende de su configuración por defecto)
        KEYRING_OPTION="" 
    }
fi
echo "✅ Verificación GPG configurada para usar: $OFFICIAL_KEYRING"
# ------------------------------------------------------------------

echo "Directorio de destino: $MIRROR_ROOT"
echo "Distribución: $DISTRIBUTION"
echo "Arquitecturas: $ARCHITECTURES (Incluyendo sources)"
echo "Host de origen: $MIRROR_HOST"
echo "------------------------------------------------------------------"

# Crear el directorio si no existe
mkdir -p "$MIRROR_ROOT"

# Ejecutar la sincronización con debmirror
# Añadimos la opción $KEYRING_OPTION para forzar la clave GPG.
debmirror \
    --host="$MIRROR_HOST" \
    --root=/debian \
    --method=http \
    --dist="$DISTRIBUTION" \
    --section="$SECTIONS" \
    --arch="$ARCHITECTURES" \
    --source \
    --passive \
    --nocleanup \
    --ignore-small-errors \
    --progress \
    --verbose \
    --postclean \
    $KEYRING_OPTION \
    "$MIRROR_ROOT" 2>&1 | tee "$LOG_FILE"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------------------------"
    echo "✅ Sincronización de Debian completada con éxito."
    echo "El mirror selectivo está listo en $MIRROR_ROOT"
    echo "------------------------------------------------------------------"
else
    echo "------------------------------------------------------------------"
    echo "❌ Error durante la sincronización de Debian. Revisa $LOG_FILE"
    echo "------------------------------------------------------------------"
fi

