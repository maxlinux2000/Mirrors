#!/bin/bash
# Script para generar la documentación de configuración del mirror APT de Proxmox.

# --- 1. CONFIGURACIÓN ---
TARGET_DIR="$HOME/public_html/proxmox"
MIRROR_IP="192.168.1.100" # ¡MODIFICAR ESTA IP SI ES NECESARIO!
MIRROR_BASE="http://$MIRROR_IP/apt" 

echo "--- 📝 GENERANDO DOCUMENTACIÓN DE CONFIGURACIÓN DEL MIRROR ---"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ ERROR: Directorio $TARGET_DIR no encontrado. Saliendo."
    exit 1
fi

cd "$TARGET_DIR" || { echo "Error al cambiar al directorio $TARGET_DIR. Saliendo."; exit 1; }

# --- 2. CONTENIDO DEL ARCHIVO TXT ---
TXT_FILE="config_sources.txt"
echo "Generando archivo de texto ($TXT_FILE)..."

cat <<EOF > "$TXT_FILE"
# =======================================================
# INSTRUCCIONES DE CONFIGURACIÓN DE REPOSITORIOS (PVE 8.x)
# =======================================================

# Antes de usar este mirror, asegúrese de que la IP $MIRROR_IP sea correcta
# y de que el servicio web esté activo en su servidor mirror.

# 1. ELIMINAR EL REPOSITORIO ENTERPRISE (Paso Obligatorio)
# Comentar la línea del repositorio de pago en /etc/apt/sources.list.d/pve-enterprise.list
#
# Comente la línea que comienza por 'deb https://enterprise.proxmox.com/'
# Ejemplo:
# # deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise

# 2. CREAR ARCHIVO DE REPOSITORIOS LOCALES
# Cree un nuevo archivo llamado /etc/apt/sources.list.d/local-mirror.list
#
# nano /etc/apt/sources.list.d/local-mirror.list
#
# Y pegue el siguiente contenido:

deb $MIRROR_BASE/proxmox bookworm pve-no-subscription
deb $MIRROR_BASE/debian bookworm main contrib non-free
# deb $MIRROR_BASE/debian-security bookworm-security main contrib non-free

# 3. COMENTAR REPOSITORIOS PÚBLICOS DE INTERNET
# Para garantizar la operación OFFLINE, comente todas las líneas en /etc/apt/sources.list:
#
# nano /etc/apt/sources.list

# 4. ACTUALIZAR EL ÍNDICE
# Ejecute este comando para que el sistema reconozca los nuevos repositorios:
#
# apt update

# NOTA: Si apt update funciona, su sistema está listo para operar OFFLINE.
EOF

echo "✅ Archivo $TXT_FILE generado."

# --- 3. CONTENIDO DEL ARCHIVO HTML ---
HTML_FILE="install_instructions.html"
echo "Generando archivo HTML ($HTML_FILE)..."

cat <<EOF > "$HTML_FILE"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Instrucciones de Configuración Offline de Proxmox VE</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        code { background-color: #eee; padding: 2px 4px; border-radius: 3px; }
        pre { background-color: #f4f4f4; padding: 15px; border: 1px solid #ddd; overflow-x: auto; }
        h2 { border-bottom: 2px solid #333; padding-bottom: 5px; }
        .alert { background-color: #ffdddd; border-left: 6px solid #f44336; padding: 10px; margin-top: 20px; }
    </style>
</head>
<body>
    <h1>⚙️ Configuración del Servidor Proxmox VE 8.x para Operación OFFLINE</h1>
    <p>Este documento explica cómo configurar el servidor Proxmox recién instalado para que utilice el <strong>Mirror APT Local</strong> ubicado en <code>$MIRROR_IP</code>.</p>
    
    <div class="alert">
        <strong>¡ATENCIÓN!</strong> La IP del servidor Mirror es <code>$MIRROR_IP</code>. Si esta IP no es correcta, edite el archivo <code>/etc/apt/sources.list.d/local-mirror.list</code> manualmente.
    </div>

    <h2>Paso 1: Deshabilitar Repositorios de Internet</h2>
    <p>Es crucial deshabilitar todos los repositorios que accedan a Internet para garantizar que el sistema no intente conectarse cuando esté offline.</p>
    
    <h3>1.1. Deshabilitar Repositorio Enterprise (De pago)</h3>
    <p>Comente (añada <code>#</code> al inicio) la línea de la suscripción de pago en <code>/etc/apt/sources.list.d/pve-enterprise.list</code>.</p>
    
    <pre># deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise</pre>

    <h3>1.2. Comentar Fuentes de Debian Públicas</h3>
    <p>Comente todas las líneas en el archivo principal <code>/etc/apt/sources.list</code>.</p>
    
    <h2>Paso 2: Agregar el Mirror Local</h2>
    <p>Cree un nuevo archivo llamado <code>/etc/apt/sources.list.d/local-mirror.list</code>.</p>
    
    <p>Ejecute:</p>
    <pre>nano /etc/apt/sources.list.d/local-mirror.list</pre>
    
    <p>Y pegue el siguiente contenido, que apunta a su mirror local (<code>$MIRROR_BASE</code>):</p>
    <pre>deb $MIRROR_BASE/proxmox bookworm pve-no-subscription
deb $MIRROR_BASE/debian bookworm main contrib non-free
# deb $MIRROR_BASE/debian-security bookworm-security main contrib non-free</pre>
    
    <h2>Paso 3: Actualizar el Sistema</h2>
    <p>Una vez que los archivos estén configurados, ejecute el comando de actualización para probar la conectividad con el mirror local:</p>
    
    <pre>apt update</pre>
    
    <p>Si no hay errores, su servidor Proxmox está configurado y listo para operar y recibir actualizaciones OFFLINE.</p>
</body>
</html>
EOF

echo "✅ Archivo $HTML_FILE generado."
echo "--- 🎉 DOCUMENTACIÓN LISTA EN $TARGET_DIR ---"

# Nota para el usuario sobre el próximo paso
echo ""
echo "El código fuente está ahora en la rama 'main' (la más reciente)."

