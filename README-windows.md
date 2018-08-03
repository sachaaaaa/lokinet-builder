
## Building on Windows (mingw-w64 native, or wow64/linux/unix cross-compiler)

    #i686 or x86_64
    #if cross-compiling from anywhere other than wow64, export CC and CXX to
    #$ARCH-w64-mingw32-g[cc++] respectively
    $ pacman -Sy base-devel mingw-w64-$ARCH-toolchain git libtool autoconf cmake
    $ git clone --recursive https://github.com/loki-project/lokinet-builder
    $ cd lokinet-builder
    $ make ensure sodium
    $ cd build
    $ cmake ../deps/llarp -DSODIUM_LIBRARIES=./prefix/lib/libsodium.a -DSODIUM_INCLUDE_DIR=./prefix/include -G "Unix Makefiles" -DHAVE_CXX17_FILESYSTEM=ON
    $ make
    $ cp llarpd ../lokinet.exe

## Building on Windows using Microsoft C/C++ (Visual Studio 2017)

* clone https://github.com/loki-project/lokinet-builder from git-bash or whatever git browser you use
* open `%CLONE_PATH%/lokinet-builder/deps/sodium/builds/msvc/vs2017/libsodium.sln` and build one of the targets
* create a `build` folder in `%CLONE_PATH%/lokinet-builder`
* run cmake-gui from `%CLONE_PATH%/lokinet-builder/deps/llarp` as the source directory
  * define `SODIUM_LIB`  to `%CLONE_PATH%/lokinet-builder/deps/sodium/bin/win32/%CONFIG%/%TOOLSET%/%TARGET%/libsodium.lib`
  * define `SODIUM_INCLUDE_DIR` to `%CLONE_PATH%/lokinet-builder/deps/sodium/src/libsodium/include`
  * define `HAVE_CXX17_FILESYSTEM` to `TRUE`
  * select `Visual Studio 2017 15 %ARCH%` as the generator
  * enter a custom toolset if desired (usually `v141_xp`)
* generate the developer studio project files and open in the IDE
* select a configuration
* press F7 to build everything

to run:

    $ ./lokinet

or press `Debug`/`Local Windows Debugger` in the visual studio standard toolbar

## Boxed warning

<div style="border:5px solid #f00;padding:5px">
<p>Inbound sessions are unsupported on Windows Server systems.</p>
<p><strong><em>Ignore this warning at your own peril.</em></strong></p>
</div>