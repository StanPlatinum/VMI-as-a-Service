#ifndef _COMPAT_ARCH_X86_XEN_H
#define _COMPAT_ARCH_X86_XEN_H
#include <xen/compat.h>
#pragma pack(4)
#include "../xen.h"
#pragma pack(4)
#include "xen-x86_32.h"
#pragma pack(4)

typedef unsigned int compat_pfn_t;
typedef unsigned int compat_ulong_t;
struct compat_trap_info {
    uint8_t vector;
    uint8_t flags;
    uint16_t cs;
    unsigned int address;
};
typedef struct compat_trap_info trap_info_compat_t;
DEFINE_COMPAT_HANDLE(trap_info_compat_t);

typedef uint64_t tsc_timestamp_compat_t;
struct compat_vcpu_guest_context {

    struct { char x[512]; } fpu_ctxt;
    unsigned int flags;
    struct compat_cpu_user_regs user_regs;
    struct compat_trap_info trap_ctxt[256];
    unsigned int ldt_base, ldt_ents;
    unsigned int gdt_frames[16], gdt_ents;
    unsigned int kernel_ss, kernel_sp;

    unsigned int ctrlreg[8];
    unsigned int debugreg[8];

    unsigned int event_callback_cs;
    unsigned int event_callback_eip;
    unsigned int failsafe_callback_cs;
    unsigned int failsafe_callback_eip;
    unsigned int vm_assist;

};
typedef struct compat_vcpu_guest_context vcpu_guest_context_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_guest_context_compat_t);

struct compat_arch_shared_info {

    unsigned int max_pfn;

    compat_pfn_t pfn_to_mfn_frame_list_list;
    unsigned int nmi_reason;
    unsigned int p2m_cr3;
    unsigned int p2m_vaddr;
    unsigned int p2m_generation;

    uint32_t wc_sec_hi;

};
typedef struct compat_arch_shared_info arch_shared_info_compat_t;

struct compat_arch_domainconfig {
    char dummy;
};
#pragma pack()
#endif /* _COMPAT_ARCH_X86_XEN_H */
