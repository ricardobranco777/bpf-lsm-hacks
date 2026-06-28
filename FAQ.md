**Why does rootless Podman still work after loading?**

Rootless Podman uses `catatonit -P` as a pause process that holds the user
namespace open. If the BPF program is loaded after Podman is already running,
the existing user namespace is unaffected. `userns_create` only fires on
creation, not on existing namespaces.

Killing the catatonit process tears down the user namespace. When Podman tries
to recreate it, `CLONE_NEWUSER` is blocked by the LSM and it gets `EPERM`.
