# 📡 Servidor Mirror Offline (Debian 12 / RPi / Proxmox)

Este repositorio documenta el conjunto de scripts y la configuración necesaria para crear un **Servidor Mirror Offline** completamente autónomo. El servidor está diseñado para desplegar sistemas operativos y software crítico sin necesidad de conexión a Internet, ideal para estaciones de radio aisladas.

---

## 📍 Ficha Técnica del Despliegue

| Componente | Valor | Propósito |
| :--- | :--- | :--- |
| **IP del Servidor** | `192.168.10.1` | Punto de acceso de ejemplo a todos los servicios (HTTP, DHCP, TFTP). |
| **Subred de Despliegue** | `192.168.10.0/24` | Red aislada para evitar conflictos con la red principal. |
| **Tamaño Estimado** | ~375 GB | Tamaño inicial del contenido descargado. |
| **Servicios Activos** | Apache2, TFTP, DHCP | Infraestructura requerida para el arranque PXE y APT. |
| **Scripts Clave** | `build_full_mirror.sh`, `configure_pxe_mirror.sh` | Gestión de la descarga de contenido y la configuración de red. |

---

## 1. Contenido del Mirror (Estructura y Componentes)

El directorio principal del servidor web (`$HOME/public_html/`) alberga la siguiente estructura de contenidos:

### 1.1. Mirror Principal de Debian y RPi (`/mirror/debian/`)

Contenido central para la instalación del sistema operativo base.

| Repositorio | Arquitecturas | Secciones Incluidas | Notas |
| :--- | :--- | :--- | :--- |
| **Debian 12 (Bookworm)** | `amd64`, `arm64` | `main`, `contrib`, `non-free`, `non-free-firmware` | Incluye Fuentes (`deb-src`), Security, Updates y Backports. |
| **Raspberry Pi OS** | `arm64` | `main`, `contrib`, `non-free`, `non-free-firmware` | Paquetes específicos de hardware RPi. |

### 1.2. Contenido Específico de Proxmox (`/proxmox/`)

(Asume un script de sincronización `build_proxmox_mirror.sh` futuro).

| Componente | Tipo | Ubicación | Descripción |
| :--- | :--- | :--- | :--- |
| **Repositorio APT** | Binarios `amd64` | `/proxmox/apt/` | Paquetes de Proxmox VE y Backup Server (Bookworm). |
| **Código Fuente** | GIT | `/proxmox/git/` | Clon de los repositorios de código fuente Proxmox. |
| **ISOs de Instalación** | ISO | `/proxmox/iso/` | `proxmox-ve_8.4-1.iso`, `proxmox-backup-server_3.2-1.iso`. |
| **Imágenes de VM** | ZST/QEMU | `/proxmox/qemu/` | Imágenes precompiladas (`debian-12-standard`, etc.). |

### 1.3. Archivos de Despliegue PXE (`/`)

Archivos accesibles directamente en la raíz para la instalación automática.

* [`preseed.cfg`](http://192.168.10.1/preseed.cfg): Archivo de respuestas para la instalación desatendida de Debian 12 (particionado simple, sin LVM, solo paquetes `standard`).
* `pxelinux.0`, `vmlinuz`, `initrd.gz`: Archivos de arranque para PXE.

---

## 2. Instrucciones de Uso

### 2.1. Configuración Inicial del Servidor

1.  **Asegurar Conectividad:** El servidor necesita acceso temporal a Internet para la descarga inicial.
2.  **IP Estática:** Configurar la interfaz **`eth0`** con la IP estática `192.168.10.1` (`255.255.255.0`).
3.  **Ejecutar Sincronización:** Ejecutar `build_full_mirror.sh` (con la opción `--force-ipv4` y la gestión de claves RPi) para descargar todo el contenido. **Este proceso puede tardar horas.**
4.  **Ejecutar Infraestructura:** Ejecutar `configure_pxe_mirror.sh` para instalar y configurar Apache, TFTP y el DHCP en la subred `192.168.10.x`.

### 2.2. Instalación de Clientes (PXE)

1.  **Aislar la Red:** Asegúrese de que el servidor está conectado al cliente directamente o a través de un switch **sin otro servidor DHCP activo**.
2.  **Arranque PXE:** Inicie la máquina cliente y fuerce el arranque por red (PXE/Network Boot).
3.  **Instalación Desatendida:** Seleccione `Debian 12 AMD64` o `ARM64` del menú PXE. La instalación se completará automáticamente usando `preseed.cfg`.

### 2.3. Instalación de Channel-9 (Post-Instalación)

El software Channel-9 (CH9) se instala manualmente en la máquina recién instalada.

1.  **Acceso:** Conéctese a la máquina recién instalada (por ejemplo, vía SSH o consola).
2.  **Descarga y Ejecución:** Descargue el script de instalación (`.run` o `.sh`) y los archivos del proyecto desde la ruta específica:
    ```bash
    wget [http://192.168.10.1/ch9/install/ch9_install.run](http://192.168.10.1/ch9/install/ch9_install.run)
    bash ch9_install.run
    ```

---

## 3. Notas de Desarrollo

* **LVM Eliminado:** El particionado automático (`preseed.cfg`) utiliza un esquema simple (`/boot` + `/`) y no LVM, priorizando la facilidad de administración por parte del operador SysOp.
* **Clave GPG RPi:** El script de RPi gestiona la clave GPG específica de `archive.raspberrypi.org` para evitar errores de verificación.
* **Problemas de Timeout:** Los scripts usan la opción `--force-ipv4` en `debmirror` para mitigar problemas de *timeout* con el *fallback* de `rsync`/IPv6.
