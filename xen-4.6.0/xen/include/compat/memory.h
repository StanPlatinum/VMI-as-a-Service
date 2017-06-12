#ifndef _COMPAT_MEMORY_H
#define _COMPAT_MEMORY_H
#include <xen/compat.h>
#include <public/memory.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
#include "physdev.h"
#pragma pack(4)
struct compat_memory_reservation {
    COMPAT_HANDLE(compat_pfn_t) extent_start;

    compat_ulong_t nr_extents;
    unsigned int extent_order;

    unsigned int mem_flags;
    domid_compat_t domid;
};
typedef struct compat_memory_reservation compat_memory_reservation_t;
DEFINE_COMPAT_HANDLE(compat_memory_reservation_t);
struct compat_memory_exchange {

    struct compat_memory_reservation in;
    struct compat_memory_reservation out;
    compat_ulong_t nr_exchanged;
};
typedef struct compat_memory_exchange compat_memory_exchange_t;
DEFINE_COMPAT_HANDLE(compat_memory_exchange_t);
struct compat_machphys_mfn_list {

    unsigned int max_extents;

    COMPAT_HANDLE(compat_pfn_t) extent_start;

    unsigned int nr_extents;
};
typedef struct compat_machphys_mfn_list compat_machphys_mfn_list_t;
DEFINE_COMPAT_HANDLE(compat_machphys_mfn_list_t);
struct compat_machphys_mapping {
    compat_ulong_t v_start, v_end;
    compat_ulong_t max_mfn;
};
typedef struct compat_machphys_mapping compat_machphys_mapping_t;
DEFINE_COMPAT_HANDLE(compat_machphys_mapping_t);
struct compat_add_to_physmap {

    domid_compat_t domid;

    uint16_t size;

    unsigned int space;

    compat_ulong_t idx;

    compat_pfn_t gpfn;
};
typedef struct compat_add_to_physmap compat_add_to_physmap_t;
DEFINE_COMPAT_HANDLE(compat_add_to_physmap_t);

struct compat_add_to_physmap_batch {

    domid_compat_t domid;
    uint16_t space;

    uint16_t size;
    domid_compat_t foreign_domid;

    COMPAT_HANDLE(compat_ulong_t) idxs;

    COMPAT_HANDLE(compat_pfn_t) gpfns;

    COMPAT_HANDLE(int) errs;
};
typedef struct compat_add_to_physmap_batch compat_add_to_physmap_batch_t;
DEFINE_COMPAT_HANDLE(compat_add_to_physmap_batch_t);
struct compat_remove_from_physmap {

    domid_compat_t domid;

    compat_pfn_t gpfn;
};
typedef struct compat_remove_from_physmap compat_remove_from_physmap_t;
DEFINE_COMPAT_HANDLE(compat_remove_from_physmap_t);
struct compat_memory_map {

    unsigned int nr_entries;

    COMPAT_HANDLE(void) buffer;
};
typedef struct compat_memory_map compat_memory_map_t;
DEFINE_COMPAT_HANDLE(compat_memory_map_t);
struct compat_foreign_memory_map {
    domid_compat_t domid;
    struct compat_memory_map map;
};
typedef struct compat_foreign_memory_map compat_foreign_memory_map_t;
DEFINE_COMPAT_HANDLE(compat_foreign_memory_map_t);

struct compat_pod_target {

    uint64_t target_pages;

    uint64_t tot_pages;
    uint64_t pod_cache_pages;
    uint64_t pod_entries;

    domid_compat_t domid;
};
typedef struct compat_pod_target compat_pod_target_t;
struct compat_mem_paging_op {
    uint8_t op;
    domid_compat_t domain;

    uint64_t buffer;

    uint64_t gfn;
};
typedef struct compat_mem_paging_op compat_mem_paging_op_t;
DEFINE_COMPAT_HANDLE(compat_mem_paging_op_t);

typedef enum {
    COMPAT_MEM_access_n,
    COMPAT_MEM_access_r,
    COMPAT_MEM_access_w,
    COMPAT_MEM_access_rw,
    COMPAT_MEM_access_x,
    COMPAT_MEM_access_rx,
    COMPAT_MEM_access_wx,
    COMPAT_MEM_access_rwx,

    COMPAT_MEM_access_rx2rw,

    COMPAT_MEM_access_n2rwx,

    COMPAT_MEM_access_default
} compat_mem_access_t;

struct compat_mem_access_op {

    uint8_t op;

    uint8_t access;
    domid_compat_t domid;

    uint32_t nr;

    uint64_t pfn;
};
typedef struct xen_mem_access_op compat_mem_access_op_t;
DEFINE_COMPAT_HANDLE(compat_mem_access_op_t);
struct compat_mem_sharing_op {
    uint8_t op;
    domid_compat_t domain;

    union {
        struct compat_mem_sharing_op_nominate {
            union {
                uint64_t gfn;
                uint32_t grant_ref;
            } u;
            uint64_t handle;
        } nominate;
        struct compat_mem_sharing_op_share {
            uint64_t source_gfn;
            uint64_t source_handle;
            uint64_t client_gfn;
            uint64_t client_handle;
            domid_compat_t client_domain;
        } share;
        struct compat_mem_sharing_op_debug {
            union {
                uint64_t gfn;
                uint64_t mfn;
                uint32_t gref;
            } u;
        } debug;
    } u;
};
typedef struct compat_mem_sharing_op compat_mem_sharing_op_t;
DEFINE_COMPAT_HANDLE(compat_mem_sharing_op_t);
struct compat_reserved_device_memory {
    compat_pfn_t start_pfn;
    compat_ulong_t nr_pages;
};
typedef struct compat_reserved_device_memory compat_reserved_device_memory_t;
DEFINE_COMPAT_HANDLE(compat_reserved_device_memory_t);

struct compat_reserved_device_memory_map {

    uint32_t flags;

    unsigned int nr_entries;

    COMPAT_HANDLE(compat_reserved_device_memory_t) buffer;

    union {
        struct physdev_pci_device pci;
    } dev;
};
typedef struct compat_reserved_device_memory_map compat_reserved_device_memory_map_t;
DEFINE_COMPAT_HANDLE(compat_reserved_device_memory_map_t);
struct compat_vmemrange {
    uint64_t start, end;
    unsigned int flags;
    unsigned int nid;
};
typedef struct xen_vmemrange compat_vmemrange_t;
DEFINE_COMPAT_HANDLE(compat_vmemrange_t);
struct compat_vnuma_topology_info {

    domid_compat_t domid;
    uint16_t pad;

    unsigned int nr_vnodes;
    unsigned int nr_vcpus;
    unsigned int nr_vmemranges;

    union {
        COMPAT_HANDLE(uint) h;
        uint64_t pad;
    } vdistance;
    union {
        COMPAT_HANDLE(uint) h;
        uint64_t pad;
    } vcpu_to_vnode;
    union {
        COMPAT_HANDLE(compat_vmemrange_t) h;
        uint64_t pad;
    } vmemrange;
};
typedef struct compat_vnuma_topology_info compat_vnuma_topology_info_t;
DEFINE_COMPAT_HANDLE(compat_vnuma_topology_info_t);
#pragma pack()
#endif /* _COMPAT_MEMORY_H */
