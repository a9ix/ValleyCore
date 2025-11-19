#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CURRENT_DIR}"

# the architecture of PE executables and libraries is stored at 0x84
# we need to change it from 8664 to AA64
# it's little endian, so the byte to change is at 0x85
arch_pos=$((16#85))

filesfound=0

arch_as_hex() {
    # returns the upper arch byte as hex from file $1
    od -A n -j $arch_pos -N 1 -t x1 "$1" | grep -Eo "[0-9a-f]+" | tr -d "\n"
}

patch_dll() {
    printf "\xaa" | dd of="$1" bs=1 seek=$arch_pos conv=notrunc
}

patchifvalid() {
    if ! [ -a "$1" ]; then
        echo "$1 does not exist in this directory"
        return
    fi

    filesfound=1
    arch=$(arch_as_hex "$1")
    if [ $arch = "86" ]; then
        patch_dll "$1"
    elif [ $arch = "aa" ]; then
        echo "$1 seems to be already patched"
    else
        echo "$1 may be malformed"
    fi
}

warn() {
    echo "No files could be patched. Make sure the patch.sh script is in the same directory as the dll files."
}

mkdir temp
pushd temp
curl -fLo SkiaSharp.zip https://www.nuget.org/api/v2/package/SkiaSharp.NativeAssets.Linux/2.80.3
curl -fLO https://github.com/Pathoschild/SMAPI/releases/download/4.3.2/SMAPI-4.3.2-installer.zip
unzip SkiaSharp.zip
unzip SMAPI-4.3.2-installer.zip
popd

unzip "temp/SMAPI 4.3.2 installer/internal/linux/install.dat"
cp temp/runtimes/linux-arm64/native/libSkiaSharp.so .
cp "Stardew Valley.deps.json" StardewModdingAPI.deps.json

# no unmanaged code is contained in these, so this works
patchifvalid "Stardew Valley.dll"
patchifvalid "MonoGame.Framework.dll"
patchifvalid "xTile.dll"
patchifvalid "StardewValley.GameData.dll"
patchifvalid "BmFont.dll"
patchifvalid "Lidgren.Network.dll"
patchifvalid "StardewModdingAPI.dll"

mv StardewValley StardewValley-original

cat <<EOF > StardewValley
#!/usr/bin/env bash
dotnet StardewModdingAPI.dll
EOF
chmod +x StardewValley

export -f patchifvalid arch_as_hex patch_dll
export arch_pos
find ./Mods/ -type f -name "*.dll" -exec bash -c 'patchifvalid "{}"' \;

if ! [ $filesfound -eq 1 ]; then
    warn
else
    echo "Done! Run 'StardewValley' to launch game. Remember to run patch-mods.sh after installing mods!"
fi
