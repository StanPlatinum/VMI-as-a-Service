
#define CHECK_evtchn_alloc_unbound \
    CHECK_SIZE_(struct, evtchn_alloc_unbound); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, dom); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, remote_dom); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, port)

#define CHECK_evtchn_bind_interdomain \
    CHECK_SIZE_(struct, evtchn_bind_interdomain); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, remote_dom); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, remote_port); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, local_port)

#define CHECK_evtchn_bind_ipi \
    CHECK_SIZE_(struct, evtchn_bind_ipi); \
    CHECK_FIELD_(struct, evtchn_bind_ipi, vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_ipi, port)

#define CHECK_evtchn_bind_pirq \
    CHECK_SIZE_(struct, evtchn_bind_pirq); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, pirq); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, flags); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, port)

#define CHECK_evtchn_bind_vcpu \
    CHECK_SIZE_(struct, evtchn_bind_vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_vcpu, port); \
    CHECK_FIELD_(struct, evtchn_bind_vcpu, vcpu)

#define CHECK_evtchn_bind_virq \
    CHECK_SIZE_(struct, evtchn_bind_virq); \
    CHECK_FIELD_(struct, evtchn_bind_virq, virq); \
    CHECK_FIELD_(struct, evtchn_bind_virq, vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_virq, port)

#define CHECK_evtchn_close \
    CHECK_SIZE_(struct, evtchn_close); \
    CHECK_FIELD_(struct, evtchn_close, port)

#define CHECK_evtchn_op \
    CHECK_SIZE_(struct, evtchn_op); \
    CHECK_FIELD_(struct, evtchn_op, cmd); \
    CHECK_evtchn_alloc_unbound; \
    CHECK_evtchn_bind_interdomain; \
    CHECK_evtchn_bind_virq; \
    CHECK_evtchn_bind_pirq; \
    CHECK_evtchn_bind_ipi; \
    CHECK_evtchn_close; \
    CHECK_evtchn_send; \
    CHECK_evtchn_status; \
    CHECK_evtchn_bind_vcpu; \
    CHECK_evtchn_unmask

#define CHECK_evtchn_send \
    CHECK_SIZE_(struct, evtchn_send); \
    CHECK_FIELD_(struct, evtchn_send, port)

#define CHECK_evtchn_status \
    CHECK_SIZE_(struct, evtchn_status); \
    CHECK_FIELD_(struct, evtchn_status, dom); \
    CHECK_FIELD_(struct, evtchn_status, port); \
    CHECK_FIELD_(struct, evtchn_status, status); \
    CHECK_FIELD_(struct, evtchn_status, vcpu); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, unbound, dom); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, interdomain, dom); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, interdomain, port); \
    CHECK_SUBFIELD_1_(struct, evtchn_status, u, pirq); \
    CHECK_SUBFIELD_1_(struct, evtchn_status, u, virq)

#define CHECK_evtchn_unmask \
    CHECK_SIZE_(struct, evtchn_unmask); \
    CHECK_FIELD_(struct, evtchn_unmask, port)
