#ifndef _COMPAT_SCHED_H
#define _COMPAT_SCHED_H
#include <xen/compat.h>
#include <public/sched.h>
#pragma pack(4)
#include "event_channel.h"
#pragma pack(4)
struct compat_sched_shutdown {
    unsigned int reason;
};
typedef struct sched_shutdown sched_shutdown_compat_t;
DEFINE_COMPAT_HANDLE(sched_shutdown_compat_t);

struct compat_sched_poll {
    COMPAT_HANDLE(evtchn_port_compat_t) ports;
    unsigned int nr_ports;
    uint64_t timeout;
};
typedef struct compat_sched_poll sched_poll_compat_t;
DEFINE_COMPAT_HANDLE(sched_poll_compat_t);

struct compat_sched_remote_shutdown {
    domid_compat_t domain_id;
    unsigned int reason;
};
typedef struct sched_remote_shutdown sched_remote_shutdown_compat_t;
DEFINE_COMPAT_HANDLE(sched_remote_shutdown_compat_t);

struct compat_sched_watchdog {
    uint32_t id;
    uint32_t timeout;
};
typedef struct compat_sched_watchdog sched_watchdog_compat_t;
DEFINE_COMPAT_HANDLE(sched_watchdog_compat_t);
#pragma pack()
#endif /* _COMPAT_SCHED_H */
