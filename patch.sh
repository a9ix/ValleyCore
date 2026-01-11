#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${CURRENT_DIR}"

# the architecture of PE executables and libraries is stored at 0x84
# we need to change it from 8664 to AA64
# it's little endian, so the byte to change is at 0x85
ARCH_POS=$((16#85))

filesfound=0

arch_as_hex() {
    # returns the upper arch byte as hex from file $1
    od -A n -j $ARCH_POS -N 1 -t x1 "$1" | grep -Eo "[0-9a-f]+" | tr -d "\n"
}

patch_dll() {
    printf "\xaa" | dd of="$1" bs=1 seek=$ARCH_POS conv=notrunc
}

patchifvalid() {
    if ! [ -e "$1" ]; then
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

# no unmanaged code is contained in these, so this works
patchifvalid "Stardew Valley.dll"
patchifvalid "MonoGame.Framework.dll"
patchifvalid "xTile.dll"
patchifvalid "StardewValley.GameData.dll"
patchifvalid "BmFont.dll"
patchifvalid "Lidgren.Network.dll"

if [ -e "Steamworks.NET.dll" ]; then
    patchifvalid "Steamworks.NET.dll"
    echo "Steam files found! Patching."
fi

if [ -e "StardewModdingAPI.dll" ]; then
    if ! [ -e "smapi-wrapper.sh" ]; then
        echo -e \
        "You have either:\n\
         * ran the patch.sh script twice, which isn't necessary\n\
         * or tried to upgrade with a non-SMAPI bundle\n\
           (please download ValleyCore-SMAPI.tar.gz instead)" >&2
        sleep 5 && exit 1
    fi

    patchifvalid "StardewModdingAPI.dll"

    cp "Stardew Valley.deps.json" StardewModdingAPI.deps.json

    mv -n StardewValley StardewValley-original
    mv smapi-wrapper.sh StardewValley

    find ./Mods/ -type f -name "*.dll" | while read -r filepath; do patchifvalid "$filepath"; done
fi

if ! [ $filesfound -eq 1 ]; then
    echo "No files could be patched. Make sure the patch.sh script is in the same directory as the dll files." >&2
    sleep 5 && exit 1
fi

echo "Done! Run 'StardewValley' (no spaces) to launch game. "

# ensures that the console stays open for a while
sleep 5 && exit 0
