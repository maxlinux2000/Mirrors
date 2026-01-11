#!/bin/bash
# Script: build_rpi_mirror.sh
# Descripción: Crea un mirror selectivo del repositorio Raspberry Pi OS (archive.raspberrypi.org)
#              Utiliza la clave GPG específica de RPi para la verificación.

# --- Configuración ---
MIRROR_ROOT="$HOME/public_html/mirror/rpi"
RPI_HOST="archive.raspberrypi.org"
RPI_KEY_URL="http://archive.raspberrypi.org/debian/raspberrypi.gpg.key"
RPI_TEMP_KEYRING="$HOME/.gnupg/rpi-temp-keyring.gpg" # Keyring temporal solo para RPi
DISTRIBUTION="bookworm"
ARCHITECTURES="arm64"
SECTIONS="main"
LOG_FILE="$HOME/mirror_sync_rpi.log" # Log file específico para este mirror

# Comprobación de debmirror
if ! command -v debmirror &> /dev/null
then
    echo "debmirror no está instalado. Por favor, instálalo con 'sudo apt install debmirror'."
    exit 1
fi

echo "--- Iniciando la creación/sincronización del mirror de Raspberry Pi OS ---"

# ------------------------------------------------------------------
# 🔑 PASO CRÍTICO: Descargar y configurar la clave GPG de RPi
# ------------------------------------------------------------------
echo "--- 1. Preparando la verificación GPG con la clave de Raspberry Pi ---"

# 1.1 Asegurar directorio de claves
mkdir -p "$HOME/.gnupg"
sudo chmod 700 "$HOME/.gnupg"

# 1.2 Descargar la clave (requiere wget)
if ! command -v wget &> /dev/null; then sudo apt install -y wget; fi

echo "Descargando clave GPG de RPi desde $RPI_KEY_URL..."
wget -O "$HOME/.gnupg/raspberrypi.key" "$RPI_KEY_URL"

if [ $? -ne 0 ]; then
    echo "🚨 Error: Falló la descarga de la clave GPG de Raspberry Pi. Compruebe la conexión o la URL."
    exit 1
fi

# 1.3 Crear un keyring temporal con la clave descargada
echo "Creando keyring temporal: $RPI_TEMP_KEYRING"
# Inicializar el keyring
gpg --no-default-keyring --keyring "$RPI_TEMP_KEYRING" --import "$HOME/.gnupg/raspberrypi.key" 2>&1 | tee -a "$LOG_FILE"

if [ ! -f "$RPI_TEMP_KEYRING" ]; then
    echo "🚨 Error: Falló la creación del keyring GPG."
    exit 1
fi

KEYRING_OPTION="--keyring $RPI_TEMP_KEYRING"
echo "✅ Verificación GPG configurada para usar: $RPI_TEMP_KEYRING"
# ------------------------------------------------------------------

echo "Directorio de destino: $MIRROR_ROOT"
echo "Distribución: $DISTRIBUTION"
echo "Arquitecturas: $ARCHITECTURES (Incluyendo sources)"
echo "Host de origen: $RPI_HOST"
echo "------------------------------------------------------------------"

# Crear el directorio si no existe
mkdir -p "$MIRROR_ROOT"

# Eliminar el bloqueo obsoleto (robusto)
LOCK_FILE="$MIRROR_ROOT/lock"
if [ -f "$LOCK_FILE" ]; then
    echo "(!) Eliminando archivo de bloqueo obsoleto: $LOCK_FILE"
    rm -f "$LOCK_FILE"
fi

# Ejecutar la sincronización con debmirror
# Usamos el KEYRING_OPTION generado y el HOST/ROOT de RPi.
debmirror \
    --host="$RPI_HOST" \
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

# --- Limpieza de la clave temporal ---
echo "--- Limpiando clave temporal ---"
rm -f "$HOME/.gnupg/raspberrypi.key" "$RPI_TEMP_KEYRING"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------------------------"
    echo "✅ Sincronización de RPi OS completada con éxito."
    echo "El mirror selectivo está listo en $MIRROR_ROOT"
    echo "------------------------------------------------------------------"
else
    echo "------------------------------------------------------------------"
    echo "❌ Error durante la sincronización de RPi OS. Revisa $LOG_FILE"
    echo "------------------------------------------------------------------"
fi

