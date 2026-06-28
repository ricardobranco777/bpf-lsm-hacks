# bpf-lsm-hacks

BPF LSM programs for Linux security policy enforcement.

## restrict\_userns

Restricts unprivileged user namespace creation. Functionally equivalent to the Debian
`kernel.unprivileged_userns_clone=0` sysctl
[patch](https://github.com/semplice/linux/blob/master/debian/patches/debian/add-sysctl-to-disallow-unprivileged-CLONE_NEWUSER-by-default.patch),
but without a runtime toggle and without modifying the kernel.

We can't rely on the
[user.max_user_namespaces=0](https://docs.kernel.org/admin-guide/sysctl/user.html#max-user-namespaces)
sysctl because it also applies to root.

### Requirements

- Linux kernel with `CONFIG_BPF_LSM=y` & `CONFIG_DEBUG_INFO_BTF=y` enabled.
- `bpf` in `lsm` parameter in kernel cmdline.

### Build requirements

- bpftool
- clang
- libbpf-devel (libbpf-dev on Debian based systems)
- make

### Build

```sh
make
```

### Test

```sh
make test
```

### Load

```sh
make load
```

The restriction survives loader exit and persists until unloaded or the system reboots.

### Unload

```sh
make unload
```

### Notes

Tested on:
- s390x: SLES 16.0 with kernel 6.12.x
- x86_64: Fedora 44 with kernel 7.0.x

### TODO

- Test on other architectures such as aarch64, ppc64le & riscv64.
- Test on kernels < 6.3
- Investigate distro-agnostic way to load at boot.
- Dockerfile to simplify compilation.
