#!/bin/bash
# Script: generate_dev_docs.sh
# Descripción: Genera el archivo HTML principal (index.html) con la lista de IDEs/Editores
#              para Debian 12 (Offline), incluyendo la entrada explícita para VSCodium.

OUTPUT_FILE="index.html"
VSC_VER="1.107.18605" # Versión de VSCodium descargada (Ajustar si cambia)

# Asegurarse de que la carpeta de documentación existe (para las imágenes)
mkdir -p img

# Función para generar el bloque HTML de un editor/IDE
generate_entry() {
    local NAME=$1
    local DESCRIPTION=$2
    local INSTALL_METHOD=$3
    local DOWNLOAD_INFO=$4
    local IMAGE_NAME=$5
    
    # URL de la imagen (placeholder, la cambiarás luego)
    IMAGE_URL="img/${IMAGE_NAME}.png" 

    # Imprimir el inicio del bloque
    printf "
        <div class=\"entry\">
            <h2><a id=\"$(echo $NAME | tr '[:upper:]' '[:lower:]' | tr -d ' ')\">$NAME</a></h2>
            <div class=\"content-grid\">
                <div class=\"text-content\">
                    <p>%s</p>
                    <h3>Instalación en Debian 12 (Offline)</h3>
                    %s
                    %s
                </div>
                <div class=\"image-content\">
                    <a href=\"%s\"><img src=\"%s\" alt=\"Captura de %s\" width=\"640\" height=\"360\"></a>
                </div>
            </div>
        </div>
        <hr>" "$DESCRIPTION" "$INSTALL_METHOD" "$DOWNLOAD_INFO" "$IMAGE_URL" "$IMAGE_URL" "$NAME"
}

# --- Inicio del Archivo HTML ---
cat > "$OUTPUT_FILE" <<-EOF
<!DOCTYPE html>
<html>
<head>
<title>IDE y Editores de Código Abierto para Debian 12 (Modo Offline)</title>
<meta charset="UTF-8">
<style>
  body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; margin: 30px; background-color: #f8f9fa; color: #333; }
  h1 { color: #004d99; border-bottom: 3px solid #004d99; padding-bottom: 10px; margin-bottom: 25px; }
  h2 { color: #cc5200; margin-top: 30px; }
  h3 { color: #34495e; margin-top: 15px; }
  pre { background-color: #ecf0f1; border: 1px solid #c0d1d7; padding: 15px; border-radius: 5px; overflow-x: auto; font-family: 'Consolas', 'Courier New', monospace; }
  .entry { margin-bottom: 40px; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background-color: #fff; }
  .content-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
  .image-content img { width: 100%; height: auto; display: block; border-radius: 5px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
  @media (max-width: 800px) {
    .content-grid { grid-template-columns: 1fr; }
  }
  .category-title { font-size: 1.5em; color: #004d99; margin-top: 40px; border-bottom: 2px solid #e0e0e0; padding-bottom: 5px; }
  hr { border: 0; height: 1px; background-color: #ccc; margin: 30px 0; }
</style>
</head>
<body>

<h1>Entornos de Programación de Código Abierto para Debian 12 (Offline)</h1>

<p>Esta documentación lista los mejores IDEs y Editores de Código Abierto para Debian 12 (Bookworm). Son esenciales para trabajar con los scripts de Channel-9, el código C/C++ de Whisper.cpp, y los módulos de Proxmox.</p>
<p><strong>Nota sobre imágenes:</strong> Los enlaces de las imágenes deben ser actualizados por el operador (carpeta <code>img/</code>) y las rutas de los archivos .deb asumen que se encuentran junto a este archivo <code>index.html</code>.</p>

<h2 class="category-title">I. Editores de Texto (Ligeros y Versátiles)</h2>
EOF

# -------------------------------------------------------------
# ENTRADA ESPECIAL: VSCodium (Archivos descargados manualmente)
# -------------------------------------------------------------
VSC_INSTALL="
<p>Al ser externo a Debian, debe ser instalado manualmente con <code>dpkg</code>:</p>
<pre>
# 1. Instalar la versión AMD64 o ARM64
sudo dpkg -i codium_${VSC_VER}_amd64.deb
# O para Raspberry Pi/ARM64:
sudo dpkg -i codium_${VSC_VER}_arm64.deb

# 2. Solucionar dependencias faltantes (usando el mirror local APT configurado)
sudo apt --fix-broken install
</pre>"

# NOTA DE LA CORRECCIÓN: Hemos unificado VSC_DOWNLOAD y VSC_FILES_INFO en una sola variable.
VSC_DOWNLOAD_INFO="
<h3>Archivos Locales</h3>
<p>Archivos binarios y código fuente guardados localmente:</p>
<ul>
    <li>Binario AMD64: <a href=\"VSCODIUM/codium_${VSC_VER}_amd64.deb\">codium_${VSC_VER}_amd64.deb</a></li>
    <li>Binario ARM64: <a href=\"VSCODIUM/codium_${VSC_VER}_arm64.deb\">codium_${VSC_VER}_arm64.deb</a></li>
    <li>Código Fuente: <a href=\"VSCODIUM/vscodium.git.tgz\">vscodium.git.tgz</a></li>
    <li>Extensiones: <a href=\"VSCODIUM/vscodium_vsix_mirror.tar.gz\">vscodium_vsix_mirror.tar.gz</a></li>
</ul>

<h3>Extensiones Offline (Instalación por VSIX)</h3>
<h4>...mientras internet sea disponible...</h4>
<p>Para evitar problemas con las rutas absolutas, la estrategia es descargar los paquetes <strong>.vsix</strong> (el formato nativo de extensión) y distribuirlos. Estos archivos se encuentran en el directorio <code>vscodium_vsix_mirror/</code> del mirror.</p>

<h4>1. Preparación (En la máquina con Internet):</h4>
<p>Ejecute el script <code>download_vsix_extensions.sh</code> que se encuentra en la carpeta de herramientas. Este script generará y comprimirá los paquetes VSIX en un directorio listo para copiar al mirror.</p>
<pre>
./download_vsix_extensions.sh
# El script crea el archivo 'vscodium_vsix_mirror.tar.gz'
</pre>

<h4>2. Instalación Offline (En la máquina de destino):</h4>
<p>Después de instalar VSCodium, el operador debe descomprimir los archivos y usar la línea de comandos de <code>codium</code> para instalarlos uno por uno. Esto registra correctamente las extensiones en el entorno del operador sin necesidad de conexión.</p>
<pre>
# Descomprimir los archivos VSIX en el disco local
tar -xzvf /ruta/del/mirror/vscodium_vsix_mirror.tar.gz

# Iterar e instalar todas las extensiones (ejemplo de script de instalación rápido)
cd vscodium_vsix_mirror
for VSIX_FILE in *.vsix; do
    codium --install-extension \${VSIX_FILE}
done
</pre>
<p><strong>Nota:</strong> Este proceso puede tomar varios minutos, dependiendo de la cantidad de extensiones.</p>
"


generate_entry \
    "VSCodium" \
    "La versión de Código Abierto de Visual Studio Code (VS Code), sin telemetría. Ofrece la misma interfaz, extensiones y potencia. Ideal para editar scripts de Bash, archivos de configuración y gestionar repositorios Git." \
    "$VSC_INSTALL" \
    "$VSC_DOWNLOAD_INFO" \
    "vscodium" >> "$OUTPUT_FILE"

# -------------------------------------------------------------
# EDITORES DE REPOSITORIO DEBIAN (APT)
# -------------------------------------------------------------
APT_INSTALL_TEMPLATE='
<p>Disponible directamente en el Mirror Local de Debian:</p>
<pre>sudo apt install %s</pre>'

APT_DOWNLOAD_TEMPLATE='
<p>El código fuente y binarios están incluidos en el Mirror APT (bookworm, security, updates, backports).</p>'

# --- Resto de Editores de Texto ---
generate_entry \
    "Geany" \
    "Un IDE/Editor muy ligero, rápido y estable. Perfecto para máquinas con recursos limitados. Soporta resaltado de sintaxis, autocompletado básico y tiene un terminal integrado." \
    "$(printf "$APT_INSTALL_TEMPLATE" "geany")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "geany" >> "$OUTPUT_FILE"

generate_entry \
    "Neovim / Vim" \
    "Editores clásicos de terminal. Extremadamente potentes y omnipresentes. Indispensables para tareas de administración remota o en terminal puro. Neovim es la versión moderna." \
    "$(printf "$APT_INSTALL_TEMPLATE" "neovim vim")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "neovim" >> "$OUTPUT_FILE"
    
generate_entry \
    "Emacs" \
    "Un entorno de desarrollo completo. Ofrece una funcionalidad inmensa, desde la edición de código avanzada hasta la gestión de documentación. Altamente productivo." \
    "$(printf "$APT_INSTALL_TEMPLATE" "emacs")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "emacs" >> "$OUTPUT_FILE"

# --- IDEs ---
echo -e "\n<h2 class=\"category-title\">II. IDEs (Entornos de Desarrollo Integrado)</h2>" >> "$OUTPUT_FILE"

generate_entry \
    "Qt Creator" \
    "Un IDE excepcional para C/C++. Es la herramienta recomendada para trabajar con el código de <code>whisper.cpp</code>. Ofrece un depurador avanzado, integración con CMake/Makefiles y excelente gestión de proyectos." \
    "$(printf "$APT_INSTALL_TEMPLATE" "qtcreator")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "qtcreator" >> "$OUTPUT_FILE"

generate_entry \
    "Eclipse IDE" \
    "Un IDE maduro y modular. Con paquetes específicos (como CDT para C/C++) ofrece todas las herramientas de depuración y refactorización para proyectos a gran escala." \
    "$(printf "$APT_INSTALL_TEMPLATE" "eclipse")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "eclipse" >> "$OUTPUT_FILE"

generate_entry \
    "Code::Blocks" \
    "Un IDE C/C++ más ligero que Eclipse. Rápido y fácil de usar, ideal para proyectos basados en el compilador GCC/G++. Alternativa simple y robusta." \
    "$(printf "$APT_INSTALL_TEMPLATE" "codeblocks")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "codeblocks" >> "$OUTPUT_FILE"

generate_entry \
    "Spyder" \
    "El IDE *open-source* ideal para desarrollo en Python. Ofrece una consola interactiva, visor de variables y todas las herramientas de un entorno científico." \
    "$(printf "$APT_INSTALL_TEMPLATE" "spyder")" \
    "$APT_DOWNLOAD_TEMPLATE" \
    "spyder" >> "$OUTPUT_FILE"

# --- Final del archivo HTML ---
echo -e "</body>\n</html>" >> "$OUTPUT_FILE"

echo "------------------------------------------------------------------------------------"
echo "✅ Documentación de IDEs/Editores generada en: $OUTPUT_FILE"
echo "   El bloque de VSCodium ha sido corregido para la visualización HTML."
echo "------------------------------------------------------------------------------------"

