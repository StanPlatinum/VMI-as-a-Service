#ifndef _COMPAT_PMU_H
#define _COMPAT_PMU_H
#include <xen/compat.h>
#include <public/pmu.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)

#include "arch-x86/pmu.h"
#pragma pack(4)
struct compat_pmu_params {

    struct {
        uint32_t maj;
        uint32_t min;
    } version;
    uint64_t val;

    uint32_t vcpu;
    uint32_t pad;
};
typedef struct xen_pmu_params compat_pmu_params_t;
DEFINE_COMPAT_HANDLE(compat_pmu_params_t);
struct compat_pmu_data {

    uint32_t vcpu_id;

    uint32_t pcpu_id;

    domid_compat_t domain_id;

    uint8_t pad[6];

    struct xen_pmu_arch pmu;
};
#pragma pack()
#endif /* _COMPAT_PMU_H */
