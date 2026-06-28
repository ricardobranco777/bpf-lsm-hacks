# SPDX-License-Identifier: 0BSD
# Build dependencies: bpftool clang libbpf-devel

ARCH := $(shell uname -m | sed 's/x86_64/x86/;s/aarch64/arm64/;s/arm.*/arm/;s/s390x/s390/;s/ppc64le/powerpc/')
BPFTOOL ?= bpftool
CLANG   ?= clang
CFLAGS  := -g -O2 -Wno-missing-declarations
SUDO	:= sudo

.PHONY: all clean load unload

all: restrict_userns.bpf.o

vmlinux.h:
	$(BPFTOOL) btf dump file /sys/kernel/btf/vmlinux format c > $@

restrict_userns.bpf.o: restrict_userns.bpf.c vmlinux.h
	$(CLANG) $(CFLAGS) -target bpf -D__TARGET_ARCH_$(ARCH) -I. -c $< -o $@

clean:
	rm -f vmlinux.h restrict_userns.bpf.o restrict_userns.skel.h restrict_userns

load: restrict_userns.bpf.o
	$(SUDO) $(BPFTOOL) prog loadall $< /sys/fs/bpf/ autoattach && \
	$(SUDO)	$(BPFTOOL) prog list | grep restrict_userns_create

unload:
	$(SUDO) $(RM) /sys/fs/bpf/restrict_userns_create

test:
	@unshare -U echo ok 2>&1 | grep -q "Operation not permitted" && \
		echo "PASS: unprivileged userns blocked" || \
		echo "FAIL: unprivileged userns allowed"
	@$(SUDO) unshare -U echo ok 2>&1 | grep -q "^ok$$" && \
		echo "PASS: privileged userns allowed" || \
		echo "FAIL: privileged userns blocked"
