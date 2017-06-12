
#define CHECK_vcpu_get_physid \
    CHECK_SIZE_(struct, vcpu_get_physid); \
    CHECK_FIELD_(struct, vcpu_get_physid, phys_id)

#define CHECK_vcpu_register_vcpu_info \
    CHECK_SIZE_(struct, vcpu_register_vcpu_info); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, mfn); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, offset); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, rsvd)

#define XLAT_vcpu_runstate_info(_d_, _s_) do { \
    (_d_)->state = (_s_)->state; \
    (_d_)->state_entry_time = (_s_)->state_entry_time; \
    { \
        unsigned int i0; \
        for (i0 = 0; i0 <  4; ++i0) { \
            (_d_)->time[i0] = (_s_)->time[i0]; \
        } \
    } \
} while (0)

#define CHECK_vcpu_set_periodic_timer \
    CHECK_SIZE_(struct, vcpu_set_periodic_timer); \
    CHECK_FIELD_(struct, vcpu_set_periodic_timer, period_ns)

#define XLAT_vcpu_set_singleshot_timer(_d_, _s_) do { \
    (_d_)->timeout_abs_ns = (_s_)->timeout_abs_ns; \
    (_d_)->flags = (_s_)->flags; \
} while (0)
