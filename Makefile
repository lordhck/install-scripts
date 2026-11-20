SHELL := /bin/bash

TOOLS := bin/corefs bin/mkinitfs bin/core-chroot bin/genfstab

.PHONY: build clean

build: $(TOOLS) ## Build the standalone scripts

# -P: only m4_* names are macros, so shell code like awk's index() is safe.
bin/%: src/%.in $(shell find src -type f)
	@mkdir -p bin
	m4 -P -I src $< > $@
	chmod 755 $@

clean: ## Remove the built scripts
	rm -rf bin
