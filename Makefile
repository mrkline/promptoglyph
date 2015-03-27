DC = dmd
DFLAGS = -wi -g
BUILD_DIR = build
INSTALL_DIR = /usr/local/bin

debug: DFLAGS += -debug
debug: all

release: DFLAGS += -O -release
release: all

all: promptd-path promptd-vcs

package: clean release
	mkdir promptd
	cp $(BUILD_DIR)/promptd-path $(BUILD_DIR)/promptd-vcs promptd
	tar cf promptd.tar promptd
	gzip -f9 promptd.tar
	rm -r promptd

promptd-path: promptd-path.d help.d
	@mkdir -p $(BUILD_DIR)
	$(DC) $(DFLAGS) -of$(BUILD_DIR)/$@ $^

promptd-vcs: promptd-vcs.d help.d vcs.d time.d color.d git.d
	@mkdir -p $(BUILD_DIR)
	$(DC) $(DFLAGS) -of$(BUILD_DIR)/$@ $^

install: clean release
	cp $(BUILD_DIR)/promptd-path $(BUILD_DIR)/promptd-vcs $(INSTALL_DIR)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: clean debug release all package install
