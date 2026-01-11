#!/bin/bash
# Script: download_vsix_extensions.sh
# Descripción: Extrae IDs de extensiones instaladas de VSCodium y descarga
#              los archivos VSIX (paquetes offline) desde el Marketplace.

# ----------------------------------------------------------------------
# 1. Configuración de Rutas y Archivos
# ----------------------------------------------------------------------
VSC_EXTENSIONS_DIR="$HOME/.vscode-oss/extensions"
EXTENSIONS_JSON="$VSC_EXTENSIONS_DIR/extensions.json"
OUTPUT_DIR="vscodium_vsix_mirror"

if [ ! -f "$EXTENSIONS_JSON" ]; then
    echo "ERROR: Archivo de metadatos de VSCodium no encontrado en $EXTENSIONS_JSON"
    echo "Asegúrese de que VSCodium está instalado y ha abierto una vez."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
echo "Directorio de salida creado: $OUTPUT_DIR"
echo "------------------------------------------------------------------"

# ----------------------------------------------------------------------
# 2. Extracción de IDs y Versiones
# ----------------------------------------------------------------------
echo "Extrayendo IDs de extensiones de VSCodium..."

# Usamos jq para extraer el ID completo (publisher.name) y la versión
# La versión es crucial, ya que la URL de descarga la requiere.
jq -r '.[] | "\(.identifier.id) \(.version) \(.relativeLocation)"' "$EXTENSIONS_JSON" | while read -r ID VERSION RELATIVE_LOCATION
do
    # El ID es "publisher.name"
    PUBLISHER=$(echo "$ID" | cut -d. -f1)
    NAME=$(echo "$ID" | cut -d. -f2-)
    
    # El nombre de archivo lo podemos inferir del relativeLocation:
    # Ej: vscodevim.vim-1.32.4-universal
    VSIX_FILENAME="${RELATIVE_LOCATION}.vsix" 
    
    # Construir la URL de descarga. Usamos la URL que requiere la versión
    # para asegurar que descargamos la versión que el usuario ya probó.
    DOWNLOAD_URL="https://${PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${PUBLISHER}/extension/${NAME}/${VERSION}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

    echo ""
    echo "-> Procesando: $ID (v$VERSION)"
    echo "   URL: $DOWNLOAD_URL"
    
    # ----------------------------------------------------------------------
    # 3. Descarga con CURL
    # ----------------------------------------------------------------------
    # Usamos -L para seguir redirecciones, -o para el nombre de archivo de salida
    # y --fail para que curl falle si el código de respuesta es >= 400
    if curl -L --fail -o "$OUTPUT_DIR/$VSIX_FILENAME" "$DOWNLOAD_URL"; then
        echo "   ✅ DESCARGADO como $VSIX_FILENAME"
    else
        echo "   ❌ ERROR AL DESCARGAR: La extensión podría no estar en el Marketplace o la URL es incorrecta."
        echo "      Intente buscar $ID en https://open-vsx.org/ o descargarlo manualmente."
        # Intentar una descarga alternativa simple (sin versión específica)
        VSIX_FILENAME_ALT="${ID}-${VERSION}.vsix" 
        DOWNLOAD_URL_ALT="https://open-vsx.org/api/${ID}/latest/file/${VSIX_FILENAME_ALT}"
        echo "   -> Intentando desde Open VSX: $DOWNLOAD_URL_ALT"
        if curl -L --fail -o "$OUTPUT_DIR/$VSIX_FILENAME_ALT" "$DOWNLOAD_URL_ALT"; then
             echo "   ✅ DESCARGADO ALTERNATIVO (OpenVSX) como $VSIX_FILENAME_ALT"
        else
             echo "   ❌ ERROR: Falló la descarga alternativa. Debe descargar esta extensión manualmente."
        fi
    fi
done

echo ""
echo "------------------------------------------------------------------"
echo "✅ Proceso completado. Los archivos VSIX están en la carpeta '$OUTPUT_DIR'."
echo "   Debe copiar toda esta carpeta a su mirror offline."
echo "------------------------------------------------------------------"

# Comprimir la carpeta de VSIX para el mirror
tar -czvf ${OUTPUT_DIR}.tar.gz $OUTPUT_DIR/
echo "Archivo comprimido para el mirror: ${OUTPUT_DIR}.tar.gz"
