
#define CHECK_cpu_offline_action \
    CHECK_SIZE_(struct, cpu_offline_action); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_socketid); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_coreid); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_core_threadid)

#define CHECK_mc \
    CHECK_SIZE_(struct, mc); \
    CHECK_FIELD_(struct, mc, cmd); \
    CHECK_FIELD_(struct, mc, interface_version); \
    CHECK_compat_mc_fetch; \
    CHECK_mc_notifydomain; \
    CHECK_compat_mc_physcpuinfo; \
    CHECK_mc_msrinject; \
    CHECK_mc_mceinject; \
    CHECK_compat_mc_inject_v2

#define CHECK_mcinfo_bank \
    CHECK_SIZE_(struct, mcinfo_bank); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_bank, mc_bank); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_domid); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_status); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_addr); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_misc); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_ctrl2); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_tsc)

#define CHECK_mcinfo_common \
    CHECK_SIZE_(struct, mcinfo_common); \
    CHECK_FIELD_(struct, mcinfo_common, type); \
    CHECK_FIELD_(struct, mcinfo_common, size)

#define CHECK_mcinfo_extended \
    CHECK_SIZE_(struct, mcinfo_extended); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_extended, mc_msrs); \
    CHECK_mcinfo_msr

#define CHECK_mcinfo_global \
    CHECK_SIZE_(struct, mcinfo_global); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_global, mc_domid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_vcpuid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_socketid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_coreid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_core_threadid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_apicid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_flags); \
    CHECK_FIELD_(struct, mcinfo_global, mc_gstatus)

#define CHECK_mcinfo_logical_cpu \
    CHECK_SIZE_(struct, mcinfo_logical_cpu); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpunr); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_chipid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_coreid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_threadid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_apicid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_clusterid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_ncores); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_ncores_active); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_nthreads); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpuid_level); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_family); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_vendor); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_model); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_step); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_vendorid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_brandid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpu_caps); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cache_size); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cache_alignment); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_nmsrvals); \
    CHECK_mcinfo_msr

#define CHECK_mcinfo_msr \
    CHECK_SIZE_(struct, mcinfo_msr); \
    CHECK_FIELD_(struct, mcinfo_msr, reg); \
    CHECK_FIELD_(struct, mcinfo_msr, value)

#define CHECK_mcinfo_recovery \
    CHECK_SIZE_(struct, mcinfo_recovery); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_recovery, mc_bank); \
    CHECK_FIELD_(struct, mcinfo_recovery, action_flags); \
    CHECK_FIELD_(struct, mcinfo_recovery, action_types); \
    CHECK_page_offline_action; \
    CHECK_cpu_offline_action; \
    CHECK_SUBFIELD_1_(struct, mcinfo_recovery, action_info, pad)

#define XLAT_mc_fetch(_d_, _s_) do { \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->fetch_id = (_s_)->fetch_id; \
    XLAT_mc_fetch_HNDL_data(_d_, _s_); \
} while (0)

#define CHECK_mc_info \
    CHECK_SIZE_(struct, mc_info); \
    CHECK_FIELD_(struct, mc_info, mi_nentries); \
    CHECK_FIELD_(struct, mc_info, flags); \
    CHECK_FIELD_(struct, mc_info, mi_data)

#define CHECK_mc_mceinject \
    CHECK_SIZE_(struct, mc_mceinject); \
    CHECK_FIELD_(struct, mc_mceinject, mceinj_cpunr)

#define CHECK_mc_msrinject \
    CHECK_SIZE_(struct, mc_msrinject); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_cpunr); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_flags); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_count); \
    CHECK_mcinfo_msr

#define CHECK_mc_notifydomain \
    CHECK_SIZE_(struct, mc_notifydomain); \
    CHECK_FIELD_(struct, mc_notifydomain, mc_domid); \
    CHECK_FIELD_(struct, mc_notifydomain, mc_vcpuid); \
    CHECK_FIELD_(struct, mc_notifydomain, flags)

#define XLAT_mc_physcpuinfo(_d_, _s_) do { \
    (_d_)->ncpus = (_s_)->ncpus; \
    (_d_)->info = (_s_)->info; \
} while (0)

#define CHECK_page_offline_action \
    CHECK_SIZE_(struct, page_offline_action); \
    CHECK_FIELD_(struct, page_offline_action, mfn); \
    CHECK_FIELD_(struct, page_offline_action, status)
