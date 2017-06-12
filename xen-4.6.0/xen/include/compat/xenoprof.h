#ifndef _COMPAT_XENOPROF_H
#define _COMPAT_XENOPROF_H
#include <xen/compat.h>
#include <public/xenoprof.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_event_log {
    uint64_t eip;
    uint8_t mode;
    uint8_t event;
};

struct compat_oprof_buf {
    uint32_t event_head;
    uint32_t event_tail;
    uint32_t event_size;
    uint32_t vcpu_id;
    uint64_t xen_samples;
    uint64_t kernel_samples;
    uint64_t user_samples;
    uint64_t lost_samples;
    struct compat_event_log event_log[1];
};

struct compat_oprof_init {
    int32_t num_events;
    int32_t is_primary;
    char cpu_type[64];
};
typedef struct xenoprof_init compat_oprof_init_t;
DEFINE_COMPAT_HANDLE(compat_oprof_init_t);

struct compat_oprof_get_buffer {
    int32_t max_samples;
    int32_t nbuf;
    int32_t bufsize;
    uint64_t buf_gmaddr;
};
typedef struct compat_oprof_get_buffer compat_oprof_get_buffer_t;
DEFINE_COMPAT_HANDLE(compat_oprof_get_buffer_t);

struct compat_oprof_counter {
    uint32_t ind;
    uint64_t count;
    uint32_t enabled;
    uint32_t event;
    uint32_t hypervisor;
    uint32_t kernel;
    uint32_t user;
    uint64_t unit_mask;
};
typedef struct compat_oprof_counter compat_oprof_counter_t;
DEFINE_COMPAT_HANDLE(compat_oprof_counter_t);

typedef struct compat_oprof_passive {
    uint16_t domain_id;
    int32_t max_samples;
    int32_t nbuf;
    int32_t bufsize;
    uint64_t buf_gmaddr;
} compat_oprof_passive_t;
DEFINE_COMPAT_HANDLE(compat_oprof_passive_t);

struct compat_oprof_ibs_counter {
    uint64_t op_enabled;
    uint64_t fetch_enabled;
    uint64_t max_cnt_fetch;
    uint64_t max_cnt_op;
    uint64_t rand_en;
    uint64_t dispatched_ops;
};
typedef struct compat_oprof_ibs_counter compat_oprof_ibs_counter_t;
DEFINE_COMPAT_HANDLE(compat_oprof_ibs_counter_t);
#pragma pack()
#endif /* _COMPAT_XENOPROF_H */
