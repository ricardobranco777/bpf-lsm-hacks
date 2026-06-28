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

- Linux kernel >= 6.3
- `CONFIG_BPF_LSM=y`
- `lsm=...,bpf` in kernel cmdline

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

Tested on x86-64 with kernel 7.0.x

### TODO

- Test on other architectures such as aarch64, ppc64le & s390x.  Maybe also riscv64.
- Test on kernels < 6.3
- Investigate distro-agnostic way to load at boot.
- Dockerfile to simplify compilation.
