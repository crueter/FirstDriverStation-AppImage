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
fi

# now make appimage
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# variables to be used on quick-sharun and uruntime2appimage
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

mv extracted/*.so AppDir/bin
mv extracted/FirstDriverStation AppDir/bin

# setcap/getcap are bundled so the input.hook can give the binary capabilities
./quick-sharun AppDir/bin/* /usr/bin/getcap /usr/bin/setcap

# MAKE APPIMAGE WITH URUNTIME
./quick-sharun --make-appimage
