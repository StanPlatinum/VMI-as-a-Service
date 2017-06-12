#ifndef _COMPAT_ARCH_X86_PMU_H
#define _COMPAT_ARCH_X86_PMU_H
#include <xen/compat.h>
#pragma pack(4)
struct compat_pmu_amd_ctxt {

    uint32_t counters;
    uint32_t ctrls;

    uint64_t regs[];

};
typedef struct xen_pmu_amd_ctxt compat_pmu_amd_ctxt_t;
DEFINE_COMPAT_HANDLE(compat_pmu_amd_ctxt_t);

struct compat_pmu_cntr_pair {
    uint64_t counter;
    uint64_t control;
};
typedef struct xen_pmu_cntr_pair compat_pmu_cntr_pair_t;
DEFINE_COMPAT_HANDLE(compat_pmu_cntr_pair_t);

struct compat_pmu_intel_ctxt {

    uint32_t fixed_counters;
    uint32_t arch_counters;

    uint64_t global_ctrl;
    uint64_t global_ovf_ctrl;
    uint64_t global_status;
    uint64_t fixed_ctrl;
    uint64_t ds_area;
    uint64_t pebs_enable;
    uint64_t debugctl;

    uint64_t regs[];

};
typedef struct xen_pmu_intel_ctxt compat_pmu_intel_ctxt_t;
DEFINE_COMPAT_HANDLE(compat_pmu_intel_ctxt_t);

struct compat_pmu_regs {
    uint64_t ip;
    uint64_t sp;
    uint64_t flags;
    uint16_t cs;
    uint16_t ss;
    uint8_t cpl;
    uint8_t pad[3];
};
typedef struct xen_pmu_regs compat_pmu_regs_t;
DEFINE_COMPAT_HANDLE(compat_pmu_regs_t);
struct compat_pmu_arch {
    union {

        struct xen_pmu_regs regs;

        uint8_t pad[64];
    } r;

    uint64_t pmu_flags;

    union {
        uint32_t lapic_lvtpc;
        uint64_t pad;
    } l;

    union {
        struct xen_pmu_amd_ctxt amd;
        struct xen_pmu_intel_ctxt intel;

        uint8_t pad[128];
    } c;
};
typedef struct xen_pmu_arch compat_pmu_arch_t;
DEFINE_COMPAT_HANDLE(compat_pmu_arch_t);
#pragma pack()
#endif /* _COMPAT_ARCH_X86_PMU_H */
