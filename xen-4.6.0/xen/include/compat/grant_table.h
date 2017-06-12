#ifndef _COMPAT_GRANT_TABLE_H
#define _COMPAT_GRANT_TABLE_H
#include <xen/compat.h>
#include <public/grant_table.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
typedef uint32_t grant_ref_compat_t;
struct compat_grant_entry_v1 {

    uint16_t flags;

    domid_compat_t domid;

    uint32_t frame;
};
typedef struct grant_entry_v1 grant_entry_v1_compat_t;
struct compat_grant_entry_header {
    uint16_t flags;
    domid_compat_t domid;
};
typedef struct grant_entry_header grant_entry_header_compat_t;

union compat_grant_entry_v2 {
    grant_entry_header_compat_t hdr;
    struct {
        grant_entry_header_compat_t hdr;
        uint32_t pad0;
        uint64_t frame;
    } full_page;

    struct {
        grant_entry_header_compat_t hdr;
        uint16_t page_off;
        uint16_t length;
        uint64_t frame;
    } sub_page;
    struct {
        grant_entry_header_compat_t hdr;
        domid_compat_t trans_domid;
        uint16_t pad0;
        grant_ref_compat_t gref;
    } transitive;

    uint32_t __spacer[4];
};
typedef union grant_entry_v2 grant_entry_v2_compat_t;

typedef uint16_t grant_status_compat_t;
typedef uint32_t grant_handle_compat_t;
struct compat_gnttab_map_grant_ref {

    uint64_t host_addr;
    uint32_t flags;
    grant_ref_compat_t ref;
    domid_compat_t dom;

    int16_t status;
    grant_handle_compat_t handle;
    uint64_t dev_bus_addr;
};
typedef struct gnttab_map_grant_ref gnttab_map_grant_ref_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_map_grant_ref_compat_t);
struct compat_gnttab_unmap_grant_ref {

    uint64_t host_addr;
    uint64_t dev_bus_addr;
    grant_handle_compat_t handle;

    int16_t status;
};
typedef struct gnttab_unmap_grant_ref gnttab_unmap_grant_ref_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_unmap_grant_ref_compat_t);
struct compat_gnttab_setup_table {

    domid_compat_t dom;
    uint32_t nr_frames;

    int16_t status;

    COMPAT_HANDLE(compat_pfn_t) frame_list;

};
typedef struct compat_gnttab_setup_table gnttab_setup_table_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_setup_table_compat_t);

struct compat_gnttab_dump_table {

    domid_compat_t dom;

    int16_t status;
};
typedef struct gnttab_dump_table gnttab_dump_table_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_dump_table_compat_t);
struct compat_gnttab_transfer {

    compat_pfn_t mfn;
    domid_compat_t domid;
    grant_ref_compat_t ref;

    int16_t status;
};
typedef struct compat_gnttab_transfer gnttab_transfer_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_transfer_compat_t);
struct compat_gnttab_copy {

    struct compat_gnttab_copy_ptr {
        union {
            grant_ref_compat_t ref;
            compat_pfn_t gmfn;
        } u;
        domid_compat_t domid;
        uint16_t offset;
    } source, dest;
    uint16_t len;
    uint16_t flags;

    int16_t status;
};
typedef struct compat_gnttab_copy gnttab_copy_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_copy_compat_t);
struct compat_gnttab_query_size {

    domid_compat_t dom;

    uint32_t nr_frames;
    uint32_t max_nr_frames;
    int16_t status;
};
typedef struct compat_gnttab_query_size gnttab_query_size_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_query_size_compat_t);
struct compat_gnttab_unmap_and_replace {

    uint64_t host_addr;
    uint64_t new_addr;
    grant_handle_compat_t handle;

    int16_t status;
};
typedef struct gnttab_unmap_and_replace gnttab_unmap_and_replace_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_unmap_and_replace_compat_t);
struct compat_gnttab_set_version {

    uint32_t version;
};
typedef struct gnttab_set_version gnttab_set_version_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_set_version_compat_t);
struct compat_gnttab_get_status_frames {

    uint32_t nr_frames;
    domid_compat_t dom;

    int16_t status;
    COMPAT_HANDLE(uint64_t) frame_list;
};
typedef struct compat_gnttab_get_status_frames gnttab_get_status_frames_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_get_status_frames_compat_t);

struct compat_gnttab_get_version {

    domid_compat_t dom;
    uint16_t pad;

    uint32_t version;
};
typedef struct gnttab_get_version gnttab_get_version_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_get_version_compat_t);

struct compat_gnttab_swap_grant_ref {

    grant_ref_compat_t ref_a;
    grant_ref_compat_t ref_b;

    int16_t status;
};
typedef struct gnttab_swap_grant_ref gnttab_swap_grant_ref_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_swap_grant_ref_compat_t);

struct compat_gnttab_cache_flush {
    union {
        uint64_t dev_bus_addr;
        grant_ref_compat_t ref;
    } a;
    uint16_t offset;
    uint16_t length;

    uint32_t op;
};
typedef struct gnttab_cache_flush gnttab_cache_flush_compat_t;
DEFINE_COMPAT_HANDLE(gnttab_cache_flush_compat_t);
#pragma pack()
#endif /* _COMPAT_GRANT_TABLE_H */
