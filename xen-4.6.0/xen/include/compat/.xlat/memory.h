
#define XLAT_add_to_physmap(_d_, _s_) do { \
    (_d_)->domid = (_s_)->domid; \
    (_d_)->size = (_s_)->size; \
    (_d_)->space = (_s_)->space; \
    (_d_)->idx = (_s_)->idx; \
    (_d_)->gpfn = (_s_)->gpfn; \
} while (0)

#define XLAT_add_to_physmap_batch(_d_, _s_) do { \
    (_d_)->domid = (_s_)->domid; \
    (_d_)->space = (_s_)->space; \
    (_d_)->size = (_s_)->size; \
    (_d_)->foreign_domid = (_s_)->foreign_domid; \
    XLAT_add_to_physmap_batch_HNDL_idxs(_d_, _s_); \
    XLAT_add_to_physmap_batch_HNDL_gpfns(_d_, _s_); \
    XLAT_add_to_physmap_batch_HNDL_errs(_d_, _s_); \
} while (0)

#define XLAT_foreign_memory_map(_d_, _s_) do { \
    (_d_)->domid = (_s_)->domid; \
    XLAT_memory_map(&(_d_)->map, &(_s_)->map); \
} while (0)

#define XLAT_memory_exchange(_d_, _s_) do { \
    XLAT_memory_reservation(&(_d_)->in, &(_s_)->in); \
    XLAT_memory_reservation(&(_d_)->out, &(_s_)->out); \
    (_d_)->nr_exchanged = (_s_)->nr_exchanged; \
} while (0)

#define XLAT_memory_map(_d_, _s_) do { \
    (_d_)->nr_entries = (_s_)->nr_entries; \
    XLAT_memory_map_HNDL_buffer(_d_, _s_); \
} while (0)

#define XLAT_memory_reservation(_d_, _s_) do { \
    XLAT_memory_reservation_HNDL_extent_start(_d_, _s_); \
    (_d_)->nr_extents = (_s_)->nr_extents; \
    (_d_)->extent_order = (_s_)->extent_order; \
    (_d_)->mem_flags = (_s_)->mem_flags; \
    (_d_)->domid = (_s_)->domid; \
} while (0)

#define CHECK_mem_access_op \
    CHECK_SIZE_(struct, mem_access_op); \
    CHECK_FIELD_(struct, mem_access_op, op); \
    CHECK_FIELD_(struct, mem_access_op, access); \
    CHECK_FIELD_(struct, mem_access_op, domid); \
    CHECK_FIELD_(struct, mem_access_op, nr); \
    CHECK_FIELD_(struct, mem_access_op, pfn)

#define XLAT_pod_target(_d_, _s_) do { \
    (_d_)->target_pages = (_s_)->target_pages; \
    (_d_)->tot_pages = (_s_)->tot_pages; \
    (_d_)->pod_cache_pages = (_s_)->pod_cache_pages; \
    (_d_)->pod_entries = (_s_)->pod_entries; \
    (_d_)->domid = (_s_)->domid; \
} while (0)

#define XLAT_remove_from_physmap(_d_, _s_) do { \
    (_d_)->domid = (_s_)->domid; \
    (_d_)->gpfn = (_s_)->gpfn; \
} while (0)

enum XLAT_reserved_device_memory_map {
    XLAT_reserved_device_memory_map_flags,
    XLAT_reserved_device_memory_map_nr_entries,
    XLAT_reserved_device_memory_map_buffer,
    XLAT_reserved_device_memory_map_dev,
};

#define XLAT_reserved_device_memory_map(_d_, _s_) do { \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->nr_entries = (_s_)->nr_entries; \
    XLAT_reserved_device_memory_map_HNDL_buffer(_d_, _s_); \
    switch (dev) { \
    case XLAT_reserved_device_memory_map_dev_pci: \
        XLAT_physdev_pci_device(&(_d_)->dev.pci, &(_s_)->dev.pci); \
        break; \
    } \
} while (0)

#define CHECK_vmemrange \
    CHECK_SIZE_(struct, vmemrange); \
    CHECK_FIELD_(struct, vmemrange, start); \
    CHECK_FIELD_(struct, vmemrange, end); \
    CHECK_FIELD_(struct, vmemrange, flags); \
    CHECK_FIELD_(struct, vmemrange, nid)

enum XLAT_vnuma_topology_info_vdistance {
    XLAT_vnuma_topology_info_vdistance_h,
    XLAT_vnuma_topology_info_vdistance_pad,
};

enum XLAT_vnuma_topology_info_vcpu_to_vnode {
    XLAT_vnuma_topology_info_vcpu_to_vnode_h,
    XLAT_vnuma_topology_info_vcpu_to_vnode_pad,
};

enum XLAT_vnuma_topology_info_vmemrange {
    XLAT_vnuma_topology_info_vmemrange_h,
    XLAT_vnuma_topology_info_vmemrange_pad,
};

#define XLAT_vnuma_topology_info(_d_, _s_) do { \
    (_d_)->domid = (_s_)->domid; \
    (_d_)->pad = (_s_)->pad; \
    (_d_)->nr_vnodes = (_s_)->nr_vnodes; \
    (_d_)->nr_vcpus = (_s_)->nr_vcpus; \
    (_d_)->nr_vmemranges = (_s_)->nr_vmemranges; \
    switch (vdistance) { \
    case XLAT_vnuma_topology_info_vdistance_h: \
        XLAT_vnuma_topology_info_HNDL_vdistance_h(_d_, _s_); \
        break; \
    case XLAT_vnuma_topology_info_vdistance_pad: \
        (_d_)->vdistance.pad = (_s_)->vdistance.pad; \
        break; \
    } \
    switch (vcpu_to_vnode) { \
    case XLAT_vnuma_topology_info_vcpu_to_vnode_h: \
        XLAT_vnuma_topology_info_HNDL_vcpu_to_vnode_h(_d_, _s_); \
        break; \
    case XLAT_vnuma_topology_info_vcpu_to_vnode_pad: \
        (_d_)->vcpu_to_vnode.pad = (_s_)->vcpu_to_vnode.pad; \
        break; \
    } \
    switch (vmemrange) { \
    case XLAT_vnuma_topology_info_vmemrange_h: \
        XLAT_vnuma_topology_info_HNDL_vmemrange_h(_d_, _s_); \
        break; \
    case XLAT_vnuma_topology_info_vmemrange_pad: \
        (_d_)->vmemrange.pad = (_s_)->vmemrange.pad; \
        break; \
    } \
} while (0)
