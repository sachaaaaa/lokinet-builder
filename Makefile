REPO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))


BUILD_DIR=$(REPO)/build

EXE = $(REPO)/lokinet

DEP_PREFIX=$(BUILD_DIR)/prefix
PREFIX_SRC=$(DEP_PREFIX)/src

SODIUM_SRC=$(REPO)/deps/sodium
LLARPD_SRC=$(REPO)/deps/llarp
MOTTO=$(LLARPD_SRC)/motto.txt

SODIUM_BUILD=$(PREFIX_SRC)/sodium
SODIUM_CONFIG=$(SODIUM_SRC)/configure
SODIUM_LIB=$(DEP_PREFIX)/lib/libsodium.a

NDK ?= $(HOME)/android-ndk
NDK_INSTALL_DIR = $(BUILD_DIR)/ndk

CROSS_TARGET ?=arm-bcm2708hardfp-linux-gnueabi

CROSS_CC ?=$(CROSS_TARGET)-gcc
CROSS_CXX ?=$(CROSS_TARGET)-g++

MINGW_TOOLCHAIN = $(REPO)/contrib/cross/mingw.cmake

all: build wizard

ensure:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(DEP_PREFIX)
	mkdir -p $(PREFIX_SRC)
	mkdir -p $(SODIUM_BUILD)

sodium-configure: ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && $(SODIUM_CONFIG) --prefix=$(DEP_PREFIX) --enable-static --disable-shared

sodium: sodium-configure
	$(MAKE) -C $(SODIUM_BUILD) clean
	$(MAKE) -C $(SODIUM_BUILD) install CFLAGS=-fPIC

build: ensure sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)

static-sodium-configure: ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && CC=ecc CXX=ecc++ $(SODIUM_CONFIG) --prefix=$(DEP_PREFIX) --enable-static --disable-shared

static-sodium: static-sodium-configure
	$(MAKE) -C $(SODIUM_BUILD) clean
	$(MAKE) -C $(SODIUM_BUILD) install CFLAGS=-fPIC CC=ecc CXX=ecc++

static: static-sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include -DSTATIC_LINK=ON -DCMAKE_C_COMPILER=ecc -DCMAKE_CXX_COMPILER=ecc++
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)

android-arm-sodium:
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh && ANDROID_NDK_HOME=$(NDK) $(SODIUM_SRC)/dist-build/android-arm.sh

android-arm: android-arm-sodium
	$(NDK)/build/tools/make_standalone_toolchain.py --force --api=16 --arch=arm --install-dir=$(NDK_INSTALL_DIR) 
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_SRC)/libsodium-android-armv6/lib/libsodium.a -DSODIUM_INCLUDE_DIR=$(SODIUM_SRC)/libsodium-android-armv6/include -DCMAKE_C_COMPILER=$(NDK_INSTALL_DIR)/bin/clang -DCMAKE_CXX_COMPILER=$(NDK_INSTALL_DIR)/bin/clang++ -DCMAKE_SYSROOT=$(NDK_INSTALL_DIR)/sysroot -DANDROID=ON
	$(MAKE) -C $(BUILD_DIR) 

cross-sodium: ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && $(SODIUM_CONFIG) --prefix=$(DEP_PREFIX) --enable-static --disable-shared --host=$(CROSS_TARGET)
	$(MAKE) -C $(SODIUM_BUILD) install

cross: cross-sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSTATIC_LINK=ON -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include -DCMAKE_C_COMPILER=$(CROSS_CC) -DCMAKE_CXX_COMPILER=$(CROSS_CXX) -DCMAKE_CROSS_COMPILING=ON
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)

windows-sodium: ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && $(SODIUM_CONFIG) --prefix=$(DEP_PREFIX) --enable-static --disable-shared --host=x86_64-w64-mingw32
	$(MAKE) -C $(SODIUM_BUILD) install


windows: windows-sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSTATIC_LINK=ON -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include -DCMAKE_TOOLCHAIN_FILE=$(MINGW_TOOLCHAIN)
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)

motto:
	figlet "$(shell cat $(MOTTO))"

release: static-sodium motto
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include -DSTATIC_LINK=ON -DCMAKE_C_COMPILER=ecc -DCMAKE_CXX_COMPILER=ecc++ -DCMAKE_BUILD_TYPE=Release -DRELEASE_MOTTO="$(shell cat $(MOTTO))"
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)
	#gpg --sign --detach $(EXE)

clean:
	rm -rf $(BUILD_DIR) $(EXE)

wizard:
	$(LLARPD_SRC)/contrib/wizard/lokinet-wizard.sh