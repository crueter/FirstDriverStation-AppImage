#!/bin/sh -e

owner=wpilibsuite
name=FirstDriverStation-Public
repo="$owner/$name"

api="https://api.github.com/repos/$repo/releases"
tag=$(curl -sSfL "$api" | jq -r '.[0].tag_name')
version=$(echo "$tag" | tr -d 'v')

case "$(uname -m)" in
    x86_64) arch=x64 ;;
    *) arch=arm64 ;;
esac

artifact="FirstDriverStation-linux-$arch-$version.tar.gz"
url="https://github.com/$repo/releases/download/$tag/$artifact"

if [ ! -d extracted ]; then
    mkdir extracted
    if [ ! -f "$artifact" ]; then
        curl -sSfL "$url" -o "$artifact"
    fi

    tar xf "$artifact" -C extracted
    sudo chgrp input extracted/FirstDriverStation
    sudo chmod g+s extracted/FirstDriverStation
fi

# now make appimage
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# variables to be used on quick-sharun and uruntime2appimage
export ICON=FirstDriverStation.png
export DESKTOP=FirstDriverStation.desktop
export OPTIMIZE_LAUNCH=1
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=0
export VERSION="$tag"

export ADD_HOOKS="wayland-is-broken.hook"
export OUTPATH="artifacts"
export OUTNAME="FirstDriverStation-linux-${arch}-${version}.AppImage"
export UPINFO="gh-releases-zsync|$owner|$name|latest|*$arch*.AppImage.zsync"

# cleanup
rm -rf "$APPDIR"

# deploy
if [ ! -f quick-sharun ]; then
    curl -fL --retry 30 "$SHARUN" -o quick-sharun
    chmod a+x quick-sharun
fi

mkdir -p AppDir/bin
mv extracted/*.so AppDir/bin
mv extracted/FirstDriverStation AppDir/bin

./quick-sharun AppDir/bin/*

# udev
udev_dir=AppDir/etc/udev/rules.d
udev_file=72-hidraw.rules
mkdir -p "$udev_dir"
cp "$udev_file" "$udev_dir"

# custom hook
cp input.hook AppDir/bin

# MAKE APPIMAGE WITH URUNTIME
echo "-- Generating AppImage... --"
./quick-sharun --make-appimage

echo "-- Done --"
