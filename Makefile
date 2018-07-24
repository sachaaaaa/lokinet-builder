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

all: build

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
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_SRC)/libsodium-android-armv6/lib/libsodium.a -DSODIUM_INCLUDE_DIR=$(SODIUM_SRC)/libsodium-android-armv6/include -DSTATIC_LINK=ON -DCMAKE_C_COMPILER=$(NDK_INSTALL_DIR)/bin/clang -DCMAKE_CXX_COMPILER=$(NDK_INSTALL_DIR)/bin/clang++
	$(MAKE) -C $(BUILD_DIR) 


motto:
	figlet "$(shell cat $(MOTTO))"

release: static-sodium motto
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include -DSTATIC_LINK=ON -DCMAKE_C_COMPILER=ecc -DCMAKE_CXX_COMPILER=ecc++ -DCMAKE_BUILD_TYPE=Release -DRELEASE_MOTTO="$(shell cat $(MOTTO))"
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)
	gpg --sign --detach $(EXE)

clean:
	rm -rf $(BUILD_DIR) $(EXE)
