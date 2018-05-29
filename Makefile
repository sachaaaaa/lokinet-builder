REPO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))


BUILD_DIR=$(REPO)/build

EXE = $(REPO)/llarpd
SHARED = $(REPO)/libllarp.so

DEP_PREFIX=$(BUILD_DIR)/prefix
PREFIX_SRC=$(DEP_PREFIX)/src

SODIUM_SRC=$(REPO)/deps/sodium
LLARPD_SRC=$(REPO)/deps/llarp

SODIUM_BUILD=$(PREFIX_SRC)/sodium
SODIUM_CONFIG=$(SODIUM_SRC)/configure
SODIUM_LIB=$(DEP_PREFIX)/lib/libsodium.a

all: build

ensure:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(DEP_PREFIX)
	mkdir -p $(PREFIX_SRC)
	mkdir -p $(SODIUM_BUILD)

$(SODIUM_CONFIG): ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && $(SODIUM_CONFIG) --prefix=$(DEP_PREFIX) --enable-static --disable-shared

sodium: $(SODIUM_CONFIG)
	$(MAKE) -C $(SODIUM_BUILD) clean
	$(MAKE) -C $(SODIUM_BUILD) install CFLAGS=-fPIC

build: ensure sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(DEP_PREFIX)/include
	$(MAKE) -C $(BUILD_DIR)
	cp $(BUILD_DIR)/llarpd $(EXE)
	cp $(BUILD_DIR)/libllarp.so $(SHARED)


clean:
	rm -rf $(BUILD_DIR) $(EXE)
