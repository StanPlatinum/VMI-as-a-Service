
#define CHECK_oprof_init \
    CHECK_SIZE_(struct, oprof_init); \
    CHECK_FIELD_(struct, oprof_init, num_events); \
    CHECK_FIELD_(struct, oprof_init, is_primary); \
    CHECK_FIELD_(struct, oprof_init, cpu_type)

#define CHECK_oprof_passive \
    CHECK_SIZE_(struct, oprof_passive); \
    CHECK_FIELD_(struct, oprof_passive, domain_id); \
    CHECK_FIELD_(struct, oprof_passive, max_samples); \
    CHECK_FIELD_(struct, oprof_passive, nbuf); \
    CHECK_FIELD_(struct, oprof_passive, bufsize); \
    CHECK_FIELD_(struct, oprof_passive, buf_gmaddr)
