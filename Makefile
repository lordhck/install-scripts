SHELL := /bin/bash

TOOLS := mkinitfs core-chroot

.PHONY: build clean

build: $(TOOLS) ## Build the standalone scripts

# -P: only m4_* names are macros, so shell code like awk's index() is safe.
%: %.in $(wildcard lib/*.m4 lib/*/*)
	m4 -P -I lib $< > $@
	chmod 755 $@

clean: ## Remove the built scripts
	rm -f $(TOOLS)
