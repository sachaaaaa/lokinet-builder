REPO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))


BUILD_DIR=$(REPO)/build

EXE = $(REPO)/llarpd

DEP_PREFIX=$(BUILD_DIR)/prefix
PREFIX_SRC=$(DEP_PREFIX)/src

SODIUM_SRC=$(REPO)/deps/sodium
LLARPD_SRC=$(REPO)/deps/llarp

SODIUM_BUILD=$(PREFIX_SRC)/sodium
SODIUM_CONFIG=$(SODIUM_SRC)/configure
SODIUM_LIB=$(SODIUM_PREFIX)/lib/libsodium.a
SODIUM_INC=$(SODIUM_PREFIX)/include

all: $(EXE)

ensure:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(DEP_PREFIX)
	mkdir -p $(PREFIX_SRC)
	mkdir -p $(SODIUM_BUILD)

$(SODIUM_CONFIG): ensure
	cd $(SODIUM_SRC) && $(SODIUM_SRC)/autogen.sh
	cd $(SODIUM_BUILD) && $(SODIUM_CONFIG) --prefix=$(SODIUM_BUILD) --enable-static --disable-shared

sodium: $(SODIUM_CONFIG)
	$(MAKE) -C $(SODIUM_BUILD) install

$(SODIUM_LIB): sodium

$(EXE): ensure sodium
	cd $(BUILD_DIR) && cmake $(LLARPD_SRC) -DSODIUM_LIBRARIES=$(SODIUM_LIB) -DSODIUM_INCLUDE_DIR=$(SODIUM_INC)
	$(MAKE) -C $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(EXE)
