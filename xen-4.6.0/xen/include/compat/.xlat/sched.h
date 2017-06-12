
#define XLAT_sched_poll(_d_, _s_) do { \
    XLAT_sched_poll_HNDL_ports(_d_, _s_); \
    (_d_)->nr_ports = (_s_)->nr_ports; \
    (_d_)->timeout = (_s_)->timeout; \
} while (0)

#define CHECK_sched_remote_shutdown \
    CHECK_SIZE_(struct, sched_remote_shutdown); \
    CHECK_FIELD_(struct, sched_remote_shutdown, domain_id); \
    CHECK_FIELD_(struct, sched_remote_shutdown, reason)

#define CHECK_sched_shutdown \
    CHECK_SIZE_(struct, sched_shutdown); \
    CHECK_FIELD_(struct, sched_shutdown, reason)
