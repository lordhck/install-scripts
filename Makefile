SHELL := /bin/bash

PREFIX ?= /usr
TOOLS := bin/corefs bin/mkinitfs bin/core-chroot bin/genfstab

.PHONY: build install package clean

build: $(TOOLS) ## Build the standalone scripts

# -P: only m4_* names are macros, so shell code like awk's index() is safe.
bin/%: src/%.in $(shell find src -type f)
	@mkdir -p bin
	m4 -P -I src $< > $@
	chmod 755 $@

install: build ## Install the scripts to $(DESTDIR)$(PREFIX)/bin
	install -Dm755 -t $(DESTDIR)$(PREFIX)/bin $(TOOLS)

package: build ## Build install-scripts.tar.xz
	rm -rf pkg
	$(MAKE) install DESTDIR=pkg
	tar -cJf install-scripts.tar.xz --owner=0 --group=0 -C pkg usr
	rm -rf pkg

clean: ## Remove the built scripts and package
	rm -rf bin install-scripts.tar.xz
