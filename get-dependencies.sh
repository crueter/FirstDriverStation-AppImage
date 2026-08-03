#!/bin/sh -e

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm --overwrite "*" \
	base-devel patchelf curl jq strace wget xorg-server-xvfb zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES"
chmod +x get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-mesa libxml2-mini opus-nano
