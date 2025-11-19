# ValleyCore with SMAPI
Play Stardew Valley natively on 64-bit ARM systems running Linux, now with modding ability!
<img width="2560" height="1600" alt="image" src="https://github.com/user-attachments/assets/3d37df9b-8a4f-4355-a24f-706d1052377b" />

## Installation
0. Purchase and download [Stardew Valley from GOG](https://www.gog.com/en/game/stardew_valley). Steam version might work.
1. Make sure that both SDL2 and OpenAL are installed (on Debian-based distros: `sudo apt install libsdl2-2.0-0 libopenal1`)
2. Download the latest version of ValleyCore from releases, and extract the files to the game directory (if the game is directly in your home directory: `cd ~/Stardew\ Valley/game && tar -xzf ~/Downloads/ValleyCore.tar.gz`)
3. Run the patch.sh script (e.g. `~/Stardew\ Valley/game/patch.sh`)

## Performance
*Tested on a Raspberry Pi 4 (running at 1.5GHz, box64-rpi4 0.3.4 from Debian repos)*

* Startup
  * Native: ~40 s
  * Box64: ~2 min 30 s
* Time to load a save
  * Native: ~30 s
  * Box64: ~1 min 30 s
* Performance in game
  * Native: ~60 fps, infrequent stutters
  * Box64: ~40 fps, frequent stutters

## FAQ

### Does this work on Windows/macOS?
At this time, only Linux is supported. 
### Is this really native?
Yes! No x86 emulation is used.
### How does it work?
Since Stardew Valley is written in C# (but doesn't use Unity), it's compiled to portable CIL bytecode instead of a native binary. While the runtime bundled with the vanilla game only supports x86-64, it can be easily swapped out with an ARM64 version.
#### Why does the main dll have to be patched then?
The architecture is marked in the header as x86-64, resulting in a BadImageFormatException. By patching a single byte, it can be "converted" so that the ARM-native runtime accepts it.
### The GOG installer doesn't run, how do I extract the game files?
`cd` into an empty directory and run `unzip [installer name here.sh]` (replace the square brackets with the filename and path). All of the important game files are located in `data/noarch/`.

## Copyright
The published builds use binaries courtesy of:
* .NET Foundation ([under the MIT license](https://github.com/dotnet/core/blob/main/LICENSE.TXT))
* Mono Project ([under the MIT license](https://github.com/mono/SkiaSharp/blob/main/LICENSE.md))
* LWJGL ([under the BSD 3-clause license](https://www.lwjgl.org/license))
* SMAPI ([under the LGPLv3 license](https://github.com/Pathoschild/SMAPI/blob/develop/LICENSE.txt))