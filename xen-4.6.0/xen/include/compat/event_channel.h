#ifndef _COMPAT_EVENT_CHANNEL_H
#define _COMPAT_EVENT_CHANNEL_H
#include <xen/compat.h>
#include <public/event_channel.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
typedef uint32_t evtchn_port_compat_t;
DEFINE_COMPAT_HANDLE(evtchn_port_compat_t);
struct compat_evtchn_alloc_unbound {

    domid_compat_t dom, remote_dom;

    evtchn_port_compat_t port;
};
typedef struct evtchn_alloc_unbound evtchn_alloc_unbound_compat_t;
struct compat_evtchn_bind_interdomain {

    domid_compat_t remote_dom;
    evtchn_port_compat_t remote_port;

    evtchn_port_compat_t local_port;
};
typedef struct evtchn_bind_interdomain evtchn_bind_interdomain_compat_t;
struct compat_evtchn_bind_virq {

    uint32_t virq;
    uint32_t vcpu;

    evtchn_port_compat_t port;
};
typedef struct evtchn_bind_virq evtchn_bind_virq_compat_t;

struct compat_evtchn_bind_pirq {

    uint32_t pirq;

    uint32_t flags;

    evtchn_port_compat_t port;
};
typedef struct evtchn_bind_pirq evtchn_bind_pirq_compat_t;

struct compat_evtchn_bind_ipi {
    uint32_t vcpu;

    evtchn_port_compat_t port;
};
typedef struct evtchn_bind_ipi evtchn_bind_ipi_compat_t;

struct compat_evtchn_close {

    evtchn_port_compat_t port;
};
typedef struct evtchn_close evtchn_close_compat_t;

struct compat_evtchn_send {

    evtchn_port_compat_t port;
};
typedef struct evtchn_send evtchn_send_compat_t;
struct compat_evtchn_status {

    domid_compat_t dom;
    evtchn_port_compat_t port;

    uint32_t status;
    uint32_t vcpu;
    union {
        struct {
            domid_compat_t dom;
        } unbound;
        struct {
            domid_compat_t dom;
            evtchn_port_compat_t port;
        } interdomain;
        uint32_t pirq;
        uint32_t virq;
    } u;
};
typedef struct evtchn_status evtchn_status_compat_t;
struct compat_evtchn_bind_vcpu {

    evtchn_port_compat_t port;
    uint32_t vcpu;
};
typedef struct evtchn_bind_vcpu evtchn_bind_vcpu_compat_t;

struct compat_evtchn_unmask {

    evtchn_port_compat_t port;
};
typedef struct evtchn_unmask evtchn_unmask_compat_t;
struct compat_evtchn_reset {

    domid_compat_t dom;
};
typedef struct compat_evtchn_reset evtchn_reset_compat_t;
struct compat_evtchn_init_control {

    uint64_t control_gfn;
    uint32_t offset;
    uint32_t vcpu;

    uint8_t link_bits;
    uint8_t _pad[7];
};
typedef struct compat_evtchn_init_control evtchn_init_control_compat_t;

struct compat_evtchn_expand_array {

    uint64_t array_gfn;
};
typedef struct compat_evtchn_expand_array evtchn_expand_array_compat_t;

struct compat_evtchn_set_priority {

    uint32_t port;
    uint32_t priority;
};
typedef struct compat_evtchn_set_priority evtchn_set_priority_compat_t;

struct compat_evtchn_op {
    uint32_t cmd;
    union {
        struct evtchn_alloc_unbound alloc_unbound;
        struct evtchn_bind_interdomain bind_interdomain;
        struct evtchn_bind_virq bind_virq;
        struct evtchn_bind_pirq bind_pirq;
        struct evtchn_bind_ipi bind_ipi;
        struct evtchn_close close;
        struct evtchn_send send;
        struct evtchn_status status;
        struct evtchn_bind_vcpu bind_vcpu;
        struct evtchn_unmask unmask;
    } u;
};
typedef struct evtchn_op evtchn_op_compat_t;
DEFINE_COMPAT_HANDLE(evtchn_op_compat_t);
typedef uint32_t event_word_compat_t;
struct compat_evtchn_fifo_control_block {
    uint32_t ready;
    uint32_t _rsvd;
    uint32_t head[(15 + 1)];
};
typedef struct compat_evtchn_fifo_control_block evtchn_fifo_control_block_compat_t;
#pragma pack()
#endif /* _COMPAT_EVENT_CHANNEL_H */
