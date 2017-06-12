
#define CHECK_pmu_amd_ctxt \
    CHECK_SIZE_(struct, pmu_amd_ctxt); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, counters); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, ctrls); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, regs)

#define CHECK_pmu_arch \
    CHECK_SIZE_(struct, pmu_arch); \
    CHECK_pmu_regs; \
    CHECK_SUBFIELD_1_(struct, pmu_arch, r, pad); \
    CHECK_FIELD_(struct, pmu_arch, pmu_flags); \
    CHECK_SUBFIELD_1_(struct, pmu_arch, l, lapic_lvtpc); \
    CHECK_SUBFIELD_1_(struct, pmu_arch, l, pad); \
    CHECK_pmu_amd_ctxt; \
    CHECK_pmu_intel_ctxt; \
    CHECK_SUBFIELD_1_(struct, pmu_arch, c, pad)

#define CHECK_pmu_cntr_pair \
    CHECK_SIZE_(struct, pmu_cntr_pair); \
    CHECK_FIELD_(struct, pmu_cntr_pair, counter); \
    CHECK_FIELD_(struct, pmu_cntr_pair, control)

#define CHECK_pmu_intel_ctxt \
    CHECK_SIZE_(struct, pmu_intel_ctxt); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, fixed_counters); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, arch_counters); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_ovf_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_status); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, fixed_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, ds_area); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, pebs_enable); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, debugctl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, regs)

#define CHECK_pmu_regs \
    CHECK_SIZE_(struct, pmu_regs); \
    CHECK_FIELD_(struct, pmu_regs, ip); \
    CHECK_FIELD_(struct, pmu_regs, sp); \
    CHECK_FIELD_(struct, pmu_regs, flags); \
    CHECK_FIELD_(struct, pmu_regs, cs); \
    CHECK_FIELD_(struct, pmu_regs, ss); \
    CHECK_FIELD_(struct, pmu_regs, cpl); \
    CHECK_FIELD_(struct, pmu_regs, pad)
