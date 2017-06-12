#ifndef _COMPAT_ARCH_X86_XEN_MCA_H
#define _COMPAT_ARCH_X86_XEN_MCA_H
#include <xen/compat.h>
#pragma pack(4)
struct compat_mcinfo_common {
    uint16_t type;
    uint16_t size;
};
struct compat_mcinfo_global {
    struct mcinfo_common common;

    uint16_t mc_domid;
    uint16_t mc_vcpuid;
    uint32_t mc_socketid;
    uint16_t mc_coreid;
    uint16_t mc_core_threadid;
    uint32_t mc_apicid;
    uint32_t mc_flags;
    uint64_t mc_gstatus;
};

struct compat_mcinfo_bank {
    struct mcinfo_common common;

    uint16_t mc_bank;
    uint16_t mc_domid;

    uint64_t mc_status;
    uint64_t mc_addr;

    uint64_t mc_misc;
    uint64_t mc_ctrl2;
    uint64_t mc_tsc;
};

struct compat_mcinfo_msr {
    uint64_t reg;
    uint64_t value;
};

struct compat_mcinfo_extended {
    struct mcinfo_common common;

    uint32_t mc_msrs;

    struct mcinfo_msr mc_msr[sizeof(void *) * 4];
};
struct compat_page_offline_action
{

    uint64_t mfn;
    uint64_t status;
};

struct compat_cpu_offline_action
{

    uint32_t mc_socketid;
    uint16_t mc_coreid;
    uint16_t mc_core_threadid;
};

struct compat_mcinfo_recovery
{
    struct mcinfo_common common;
    uint16_t mc_bank;
    uint8_t action_flags;
    uint8_t action_types;
    union {
        struct page_offline_action page_retire;
        struct cpu_offline_action cpu_offline;
        uint8_t pad[16];
    } action_info;
};

struct compat_mc_info {

    uint32_t mi_nentries;
    uint32_t flags;
    uint64_t mi_data[(768 - 1) / 8];
};
typedef struct mc_info mc_info_compat_t;
DEFINE_COMPAT_HANDLE(mc_info_compat_t);
struct compat_mcinfo_logical_cpu {
    uint32_t mc_cpunr;
    uint32_t mc_chipid;
    uint16_t mc_coreid;
    uint16_t mc_threadid;
    uint32_t mc_apicid;
    uint32_t mc_clusterid;
    uint32_t mc_ncores;
    uint32_t mc_ncores_active;
    uint32_t mc_nthreads;
    int32_t mc_cpuid_level;
    uint32_t mc_family;
    uint32_t mc_vendor;
    uint32_t mc_model;
    uint32_t mc_step;
    char mc_vendorid[16];
    char mc_brandid[64];
    uint32_t mc_cpu_caps[7];
    uint32_t mc_cache_size;
    uint32_t mc_cache_alignment;
    int32_t mc_nmsrvals;
    struct mcinfo_msr mc_msrvalues[8];
};
typedef struct mcinfo_logical_cpu compat_mc_logical_cpu_t;
DEFINE_COMPAT_HANDLE(compat_mc_logical_cpu_t);
struct compat_mc_fetch {

    uint32_t flags;

    uint32_t _pad0;
    uint64_t fetch_id;

    COMPAT_HANDLE(mc_info_compat_t) data;
};
typedef struct compat_mc_fetch compat_mc_fetch_t;
DEFINE_COMPAT_HANDLE(compat_mc_fetch_t);

struct compat_mc_notifydomain {

    uint16_t mc_domid;
    uint16_t mc_vcpuid;

    uint32_t flags;

};
typedef struct xen_mc_notifydomain compat_mc_notifydomain_t;
DEFINE_COMPAT_HANDLE(compat_mc_notifydomain_t);

struct compat_mc_physcpuinfo {

 uint32_t ncpus;
 uint32_t _pad0;

 COMPAT_HANDLE(compat_mc_logical_cpu_t) info;
};

struct compat_mc_msrinject {

 uint32_t mcinj_cpunr;
 uint32_t mcinj_flags;
 uint32_t mcinj_count;
 uint32_t _pad0;
 struct mcinfo_msr mcinj_msr[8];
};

struct compat_mc_mceinject {
 unsigned int mceinj_cpunr;
};
struct compat_mc_inject_v2 {
 uint32_t flags;
 struct xenctl_bitmap cpumap;
};

struct compat_mc {
    uint32_t cmd;
    uint32_t interface_version;
    union {
        struct compat_mc_fetch mc_fetch;
        struct xen_mc_notifydomain mc_notifydomain;
        struct compat_mc_physcpuinfo mc_physcpuinfo;
        struct xen_mc_msrinject mc_msrinject;
        struct xen_mc_mceinject mc_mceinject;

        struct compat_mc_inject_v2 mc_inject_v2;

    } u;
};
typedef struct xen_mc compat_mc_t;
DEFINE_COMPAT_HANDLE(compat_mc_t);
#pragma pack()
#endif /* _COMPAT_ARCH_X86_XEN_MCA_H */
