#!/bin/sh -e

EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm --overwrite "*" \
	avahi base-devel curl fontconfig jack2 jq libcap libinput patchelf strace wget xorg-server-xvfb zsync \
	libxcursor libxrender libxfixes libxi libxinerama libxss libxtst libxcb libxkbcommon libxkbcommon-x11 \
	libpulse libsndfile libasyncns libogg libvorbis flac mpg123 lame libva libvdpau freetype2 bzip2 libpng \
	brotli xcb-util-wm xcb-util-cursor xcb-util-image xcb-util-renderutil

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES"
chmod +x get-debloated-pkgs.sh
./get-debloated-pkgs.sh --add-mesa libxml2-mini opus-nano
