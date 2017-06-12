
#define CHECK_pmu_data \
    CHECK_SIZE_(struct, pmu_data); \
    CHECK_FIELD_(struct, pmu_data, vcpu_id); \
    CHECK_FIELD_(struct, pmu_data, pcpu_id); \
    CHECK_FIELD_(struct, pmu_data, domain_id); \
    CHECK_FIELD_(struct, pmu_data, pad); \
    CHECK_pmu_arch

#define CHECK_pmu_params \
    CHECK_SIZE_(struct, pmu_params); \
    CHECK_SUBFIELD_1_(struct, pmu_params, version, maj); \
    CHECK_SUBFIELD_1_(struct, pmu_params, version, min); \
    CHECK_FIELD_(struct, pmu_params, val); \
    CHECK_FIELD_(struct, pmu_params, vcpu); \
    CHECK_FIELD_(struct, pmu_params, pad)
