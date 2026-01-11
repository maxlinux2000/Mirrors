#!/bin/bash
# Script FINAL con lógica de retroceso para manejar referencias inconsistentes.

TARGET_DIR="$HOME/public_html/mirror/proxmox/source_code"

# Repositorios a procesar
declare -a REPOS=(
"aab.git"
"apparmor.git"
"arch-pacman.git"
"ceph.git"
"corosync-pve.git"
"corosync-qdevice.git"
"criu.git"
"dab-pve-appliances.git"
"dab.git"
"efi-boot-shim.git"
"extjs.git"
"fence-agents-pve.git"
"fonts-font-logos.git"
"framework7.git"
"frr.git"
"fwupd-efi.git"
"fwupd.git"
"grub2.git"
"ifupdown2.git"
"iproute2.git"
"kronosnet.git"
"ksm-control-daemon.git"
"libanyevent-http-perl.git"
"libarchive-perl.git"
"libgit2.git"
"libgtk3-webkit-perl.git"
"libhttp-daemon-perl.git"
"libiscsi.git"
"libjs-qrcodejs.git"
"libpve-u2f-server-perl.git"
"libqb.git"
"librados2-perl.git"
"libtpms.git"
"libxdgmime-perl.git"
"lvm.git"
"lxc.git"
"lxcfs.git"
"novnc-pve.git"
"ovs.git"
"package-rebuilds.git"
"pmg-api.git"
"pmg-docs.git"
"pmg-gui.git"
"pmg-log-tracker.git"
"proxmox-acme.git"
"proxmox-archive-keyring.git"
"proxmox-i18n.git"
"proxmox-kernel-helper.git"
"proxmox-mailgateway.git"
"proxmox-mini-journalreader.git"
"proxmox-perltidy.git"
"proxmox-rrd-migration-tool.git"
"proxmox-secure-boot-policies.git"
"proxmox-secure-boot-support.git"
"proxmox-spamassassin.git"
"proxmox-ve.git"
"proxmox-widget-toolkit.git"
"pve-access-control.git"
"pve-apiclient.git"
"pve-client.git"
"pve-cluster.git"
"pve-common.git"
"pve-container.git"
"pve-docs.git"
"pve-edk2-firmware.git"
"pve-eslint.git"
"pve-firewall.git"
"pve-firmware.git"
"pve-guest-common.git"
"pve-ha-manager.git"
"pve-http-server.git"
"pve-installer.git"
"pve-jslint.git"
"pve-kernel-meta.git"
"pve-kernel.git"
"pve-libseccomp2.4-dev.git"
"pve-libspice-server.git"
"pve-lxc-syscalld.git"
"pve-manager.git"
"pve-network.git"
"pve-omping.git"
"pve-qemu.git"
"pve-spice-protocol.git"
"pve-storage-plugin-examples.git"
"pve-storage.git"
"pve-vgpu-helper.git"
"pve-xtermjs.git"
"pve-zsync.git"
"qemu-defaults.git"
"qemu-server.git"
"qemu.git"
"sencha-touch.git"
"shim-signed.git"
"smartmontools.git"
"spiceterm.git"
"swtpm.git"
"systemd.git"
"tar.git"
"vncterm.git"
"zfs-grub.git"
"zfsonlinux.git"
"ui/pmg-yew-quarantine-gui.git"
"ui/proxmox-wasm-builder.git"
"ui/proxmox-yew-comp.git"
"ui/proxmox-yew-widget-toolkit-assets.git"
"ui/proxmox-yew-widget-toolkit-examples.git"
"ui/proxmox-yew-widget-toolkit.git"
"ui/pve-yew-mobile-gui.git"
"flutter/proxmox_dart_api_client.git"
"flutter/proxmox_login_manager.git"
"flutter/pve_flutter_frontend.git"
"cargo.git"
"debcargo-conf.git"
"dh-cargo.git"
"llvm-toolchain.git"
"pathpatterns.git"
"perlmod.git"
"pmg-rs.git"
"proxmox-acme-rs.git"
"proxmox-api-types.git"
"proxmox-apt.git"
"proxmox-backup-meta.git"
"proxmox-backup-qemu.git"
"proxmox-backup-restore-image.git"
"proxmox-backup.git"
"proxmox-biome.git"
"proxmox-datacenter-manager-meta.git"
"proxmox-datacenter-manager.git"
"proxmox-firewall.git"
"proxmox-fuse.git"
"proxmox-mail-forward.git"
"proxmox-network-interface-pinning.git"
"proxmox-offline-mirror.git"
"proxmox-openid-rs.git"
"proxmox-perl-rs.git"
"proxmox-resource-scheduling.git"
"proxmox-ve-rs.git"
"proxmox-websocket-tunnel.git"
"proxmox.git"
"pve-esxi-import-tools.git"
"pve-rs.git"
"pxar.git"
"rustc.git"
"vma-to-pbs.git"
"wasi-libc.git"
"ifupdown-pve.git"
"mirror_acme.sh.git"
"mirror_corosync-qdevice.git"
"mirror_corosync.git"
"mirror_dvb-firmware.git"
"mirror_edk2.git"
"mirror_frr.git"
"mirror_ifupdown2.git"
"mirror_iproute2.git"
"mirror_kronosnet.git"
"mirror_libseccomp.git"
"mirror_linux-firmware.git"
"mirror_lxc.git"
"mirror_lxcfs.git"
"mirror_novnc.git"
"mirror_ovs.git"
"mirror_qemu.git"
"mirror_smartmontools-debian.git"
"mirror_spl-debian.git"
"mirror_spl.git"
"mirror_xterm.js.git"
"mirror_zfs-debian.git"
"mirror_zfs.git"
"apt.git"
"cgmanager.git"
"dlm.git"
"drbd-utils.git"
"gfs2-utils.git"
"glusterfs.git"
"libnet-http-perl.git"
"libusb.git"
"openais-pve.git"
"openvswitch.git"
"parted.git"
"pve-kernel-2.6.32.git"
"pve-kernel-3.10.0.git"
"pve-kernel-jessie.git"
"pve-manager-legacy.git"
"pve-qemu-kvm.git"
"pve-sheepdog.git"
"pve2-api-doc.git"
"redhat-cluster-pve.git"
"resource-agents-pve.git"
"usb-redir.git"
"vzctl.git"
"vzquota.git"
)

echo "--- 🤖 INICIANDO CHECKOUT AUTOMÁTICO (LÓGICA DE RETROCESO) ---"
echo "Prioridad: 1) origin/stable-bookworm. 2) origin/master."
echo "-------------------------------------------------------------------"

if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ ERROR: Directorio $TARGET_DIR no encontrado."
    exit 1
fi

SUCCESS_COUNT=0
FAILURE_COUNT=0

for repo_name in "${REPOS[@]}"; do
    REPO_PATH="$TARGET_DIR/$repo_name"
    
    if [ ! -d "$REPO_PATH" ]; then
        echo "⚠️ ADVERTENCIA: Directorio $repo_name no encontrado. Saltando."
        continue
    fi
    
    (
        cd "$REPO_PATH" || exit 1
        echo ""
        echo "--- Procesando: $repo_name ---"
        
        # 1. Asegurar que las referencias remotas estén actualizadas.
        git fetch > /dev/null 2>&1
        
        # Definir referencias a probar en orden de prioridad
        # En el caso de Proxmox, si 'stable-bookworm' falla, la siguiente es 'master'
        declare -a REFS_TO_TRY=("origin/stable-bookworm" "origin/master")
        CURRENT_HASH=""
        PVE8_HASH=""

        for REF in "${REFS_TO_TRY[@]}"; do
            # 2. CAPTURA INTELIGENTE DEL HASH DE LA PUNTA
            CURRENT_HASH=$(git show-ref | grep "$REF" | awk '{print $1}')
            
            if [ -n "$CURRENT_HASH" ]; then
                echo "🔎 HASH encontrado en referencia: $REF"
                
                # 3. Obtener el HASH del padre (el último commit 8.x antes del 9.x)
                PVE8_HASH=$(git rev-parse "${CURRENT_HASH}^" 2>/dev/null)
                
                if [ -n "$PVE8_HASH" ]; then
                    # HASH VÁLIDO ENCONTRADO, SALIR DEL BUCLE DE REFERENCIAS
                    break
                fi
            fi
        done

        if [ -z "$PVE8_HASH" ]; then
            echo "❌ ERROR: No se encontró una referencia válida (stable-bookworm o master) para fijar PVE 8.x."
            exit 1 # Fallo en la subshell
        fi
        
        # 4. Ejecutar el checkout al HASH de la última versión 8.x.
        if git checkout "$PVE8_HASH" 2>/dev/null; then
            echo "✅ CHECKOUT: Correctamente fijado a la última versión 8.x (HASH: $PVE8_HASH)"
            exit 0 # Éxito en la subshell
        else
            echo "❌ ERROR FATAL: Falló el checkout al HASH $PVE8_HASH."
            exit 1 # Fallo en la subshell
        fi
    )
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
    fi
done

echo ""
echo "--- 🎉 PROCESO DE CHECKOUT AUTOMÁTICO COMPLETADO ---"
echo "Repositorios fijados correctamente: $SUCCESS_COUNT"
echo "Fallos/Advertencias: $FAILURE_COUNT"
echo "---------------------------------------------------"
