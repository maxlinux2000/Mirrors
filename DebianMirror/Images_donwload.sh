#!/bin/bash

DownloadDir="/$HOME/public_html/mirror/cdimages"
mkdir -p $DownloadDir

cd $DownloadDir

mkdir -p netinst
cd netinst
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/SHA256SUMS
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/SHA256SUMS.sign
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/SHA512SUMS
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/SHA512SUMS.sign
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/debian-12.12.0-amd64-netinst.iso
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/debian-edu-12.12.0-amd64-netinst.iso
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/debian-mac-12.12.0-amd64-netinst.iso
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-cd/
cd ..

mkdir -p jigdo-16G
cd jigdo-16G
wget -c -m -np https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/jigdo-16G/
cd ..
mkdir -p iso-dvd
cd iso-dvd
wget -c -m -np https://cdimage.debian.org/mirror/cdimage/archive/12.12.0/amd64/iso-dvd/
cd ..

mkdir LiveUSB
cd LiveUSB
wget -c https://cdimage.debian.org/mirror/cdimage/archive/12.12.0-live/amd64/iso-hybrid/debian-live-12.12.0-amd64-standard.iso
cd ..

mkdir RaspberryPi_64bit
cd RaspberryPi_64bit

wget -c https://downloads.raspberrypi.com/raspios_oldstable_arm64/images/raspios_oldstable_arm64-2025-11-24/2025-11-24-raspios-bookworm-arm64.img.xz
wget -c https://downloads.raspberrypi.com/raspios_oldstable_lite_arm64/images/raspios_oldstable_lite_arm64-2025-11-24/2025-11-24-raspios-bookworm-arm64-lite.img.xz
cd ..


cd -
exit