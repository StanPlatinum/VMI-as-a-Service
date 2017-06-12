#ifndef _COMPAT_VCPU_H
#define _COMPAT_VCPU_H
#include <xen/compat.h>
#include <public/vcpu.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_vcpu_runstate_info {

    int state;

    uint64_t state_entry_time;

    uint64_t time[4];
};
typedef struct compat_vcpu_runstate_info vcpu_runstate_info_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_runstate_info_compat_t);
struct compat_vcpu_register_runstate_memory_area {
    union {
        COMPAT_HANDLE(vcpu_runstate_info_compat_t) h;
        struct compat_vcpu_runstate_info *v;
        uint64_t p;
    } addr;
};
typedef struct compat_vcpu_register_runstate_memory_area vcpu_register_runstate_memory_area_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_register_runstate_memory_area_compat_t);
struct compat_vcpu_set_periodic_timer {
    uint64_t period_ns;
};
typedef struct vcpu_set_periodic_timer vcpu_set_periodic_timer_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_set_periodic_timer_compat_t);

struct compat_vcpu_set_singleshot_timer {
    uint64_t timeout_abs_ns;
    uint32_t flags;
};
typedef struct compat_vcpu_set_singleshot_timer vcpu_set_singleshot_timer_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_set_singleshot_timer_compat_t);
struct compat_vcpu_register_vcpu_info {
    uint64_t mfn;
    uint32_t offset;
    uint32_t rsvd;
};
typedef struct vcpu_register_vcpu_info vcpu_register_vcpu_info_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_register_vcpu_info_compat_t);
struct compat_vcpu_get_physid {
    uint64_t phys_id;
};
typedef struct vcpu_get_physid vcpu_get_physid_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_get_physid_compat_t);
DEFINE_COMPAT_HANDLE(vcpu_time_info_compat_t);
struct compat_vcpu_register_time_memory_area {
    union {
        COMPAT_HANDLE(vcpu_time_info_compat_t) h;
        struct compat_vcpu_time_info *v;
        uint64_t p;
    } addr;
};
typedef struct compat_vcpu_register_time_memory_area vcpu_register_time_memory_area_compat_t;
DEFINE_COMPAT_HANDLE(vcpu_register_time_memory_area_compat_t);
#pragma pack()
#endif /* _COMPAT_VCPU_H */
