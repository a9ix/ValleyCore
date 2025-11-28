#!/usr/bin/env sh

CURRENT_DIR="$( cd "$( dirname "$(realpath "$0")" )" && pwd )"
cd "${CURRENT_DIR}"

# the architecture of PE executables and libraries is stored at 0x84
# we need to change it from 8664 to AA64
# it's little endian, so the byte to change is at 0x85
# arch_pos=$((16#85))
arch_pos=133

arch_as_hex() {
    # returns the upper arch byte as hex from file $1
    od -A n -j $arch_pos -N 1 -t x1 "$1" | grep -Eo "[0-9a-f]+" | tr -d "\n"
}

patch_dll() {
    # 252 is 0xAA in octal
    printf "\252" | dd of="$1" bs=1 seek=$arch_pos conv=notrunc
}

patchifvalid() {
    if ! [ -e "$1" ]; then
        echo "$1 does not exist in this directory"
        return
    fi

    arch=$(arch_as_hex "$1")
    if [ $arch = "86" ]; then
        patch_dll "$1"
#   elif [ $arch = "aa" ]; then
#       echo "$1 seems to be already patched"
#   else
#       echo "$1 may be malformed"
    fi
}

# using "read" here as launching multiple shells isn't ideal for performance
find ./Mods/ -type f -name "*.dll" | while read -r filepath; do patchifvalid "$filepath"; done

./unix-launcher.sh
