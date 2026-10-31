# SPDX-License-Identifier: GPL-2.0-only
#
# Nimbus OS build entry points. Usage: make -C distro <kernel|image|qemu|clean>

DISTRO := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SRCTREE := $(abspath $(DISTRO)/..)
MKOSI ?= mkosi

.PHONY: all kernel image qemu clean

all: image

kernel:
	cd $(SRCTREE) && bash distro/kernel/build-kernel.sh

image:
	mkdir -p $(DISTRO)/out/image $(DISTRO)/out/kernel
	cd $(DISTRO)/mkosi && $(MKOSI) -f build

qemu:
	cd $(DISTRO)/mkosi && $(MKOSI) qemu

clean:
	cd $(DISTRO)/mkosi && $(MKOSI) clean || true
	rm -rf $(DISTRO)/out/image
