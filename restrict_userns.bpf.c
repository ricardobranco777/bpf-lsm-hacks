/*
 * Restrict unprivileged user namespace creation via BPF LSM.
 *
 * Requires kernel >= 6.3 with CONFIG_BPF_LSM=y and "bpf" in lsm= cmdline.
 *
 * The lsm/userns_create hook fires for both clone(CLONE_NEWUSER) and
 * unshare(CLONE_NEWUSER) since both paths go through create_user_ns() ->
 * security_userns_create(), covering what the Debian/Ubuntu
 * kernel.unprivileged_userns_clone sysctl patch splits across two sites.
 *
 * Policy: deny unless the caller is in the initial user namespace (level 0)
 * AND has CAP_SYS_ADMIN in its effective capability set, matching the
 * semantics of capable(CAP_SYS_ADMIN) in the kernel patch.
 */
#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_core_read.h>
#include <bpf/bpf_tracing.h>

#define CAP_SYS_ADMIN	21
#define EPERM	1

char LICENSE[] SEC("license") = "GPL";

SEC("lsm/userns_create")
int BPF_PROG(restrict_userns_create, struct cred *cred)
{
	if (BPF_CORE_READ(cred, user_ns, level) != 0)
		return -EPERM;

	kernel_cap_t cap_eff = BPF_CORE_READ(cred, cap_effective);
	return (cap_eff.val & (1ULL << CAP_SYS_ADMIN)) ? 0 : -EPERM;
}
