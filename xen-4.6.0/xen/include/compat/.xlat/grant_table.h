
#define CHECK_gnttab_cache_flush \
    CHECK_SIZE_(struct, gnttab_cache_flush); \
    CHECK_SUBFIELD_1_(struct, gnttab_cache_flush, a, dev_bus_addr); \
    CHECK_SUBFIELD_1_(struct, gnttab_cache_flush, a, ref); \
    CHECK_FIELD_(struct, gnttab_cache_flush, offset); \
    CHECK_FIELD_(struct, gnttab_cache_flush, length); \
    CHECK_FIELD_(struct, gnttab_cache_flush, op)

enum XLAT_gnttab_copy_source_u {
    XLAT_gnttab_copy_source_u_ref,
    XLAT_gnttab_copy_source_u_gmfn,
};

enum XLAT_gnttab_copy_dest_u {
    XLAT_gnttab_copy_dest_u_ref,
    XLAT_gnttab_copy_dest_u_gmfn,
};

#define XLAT_gnttab_copy(_d_, _s_) do { \
    switch (source_u) { \
    case XLAT_gnttab_copy_source_u_ref: \
        (_d_)->source.u.ref = (_s_)->source.u.ref; \
        break; \
    case XLAT_gnttab_copy_source_u_gmfn: \
        (_d_)->source.u.gmfn = (_s_)->source.u.gmfn; \
        break; \
    } \
    (_d_)->source.domid = (_s_)->source.domid; \
    (_d_)->source.offset = (_s_)->source.offset; \
    switch (dest_u) { \
    case XLAT_gnttab_copy_dest_u_ref: \
        (_d_)->dest.u.ref = (_s_)->dest.u.ref; \
        break; \
    case XLAT_gnttab_copy_dest_u_gmfn: \
        (_d_)->dest.u.gmfn = (_s_)->dest.u.gmfn; \
        break; \
    } \
    (_d_)->dest.domid = (_s_)->dest.domid; \
    (_d_)->dest.offset = (_s_)->dest.offset; \
    (_d_)->len = (_s_)->len; \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->status = (_s_)->status; \
} while (0)

#define CHECK_gnttab_dump_table \
    CHECK_SIZE_(struct, gnttab_dump_table); \
    CHECK_FIELD_(struct, gnttab_dump_table, dom); \
    CHECK_FIELD_(struct, gnttab_dump_table, status)

#define CHECK_gnttab_map_grant_ref \
    CHECK_SIZE_(struct, gnttab_map_grant_ref); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, host_addr); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, flags); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, ref); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, dom); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, status); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, handle); \
    CHECK_FIELD_(struct, gnttab_map_grant_ref, dev_bus_addr)

#define XLAT_gnttab_setup_table(_d_, _s_) do { \
    (_d_)->dom = (_s_)->dom; \
    (_d_)->nr_frames = (_s_)->nr_frames; \
    (_d_)->status = (_s_)->status; \
    XLAT_gnttab_setup_table_HNDL_frame_list(_d_, _s_); \
} while (0)

#define XLAT_gnttab_transfer(_d_, _s_) do { \
    (_d_)->mfn = (_s_)->mfn; \
    (_d_)->domid = (_s_)->domid; \
    (_d_)->ref = (_s_)->ref; \
    (_d_)->status = (_s_)->status; \
} while (0)

#define CHECK_gnttab_unmap_grant_ref \
    CHECK_SIZE_(struct, gnttab_unmap_grant_ref); \
    CHECK_FIELD_(struct, gnttab_unmap_grant_ref, host_addr); \
    CHECK_FIELD_(struct, gnttab_unmap_grant_ref, dev_bus_addr); \
    CHECK_FIELD_(struct, gnttab_unmap_grant_ref, handle); \
    CHECK_FIELD_(struct, gnttab_unmap_grant_ref, status)

#define CHECK_gnttab_unmap_and_replace \
    CHECK_SIZE_(struct, gnttab_unmap_and_replace); \
    CHECK_FIELD_(struct, gnttab_unmap_and_replace, host_addr); \
    CHECK_FIELD_(struct, gnttab_unmap_and_replace, new_addr); \
    CHECK_FIELD_(struct, gnttab_unmap_and_replace, handle); \
    CHECK_FIELD_(struct, gnttab_unmap_and_replace, status)

#define CHECK_gnttab_set_version \
    CHECK_SIZE_(struct, gnttab_set_version); \
    CHECK_FIELD_(struct, gnttab_set_version, version)

#define CHECK_gnttab_get_version \
    CHECK_SIZE_(struct, gnttab_get_version); \
    CHECK_FIELD_(struct, gnttab_get_version, dom); \
    CHECK_FIELD_(struct, gnttab_get_version, pad); \
    CHECK_FIELD_(struct, gnttab_get_version, version)

#define XLAT_gnttab_get_status_frames(_d_, _s_) do { \
    (_d_)->nr_frames = (_s_)->nr_frames; \
    (_d_)->dom = (_s_)->dom; \
    (_d_)->status = (_s_)->status; \
    XLAT_gnttab_get_status_frames_HNDL_frame_list(_d_, _s_); \
} while (0)

#define CHECK_grant_entry_v1 \
    CHECK_SIZE_(struct, grant_entry_v1); \
    CHECK_FIELD_(struct, grant_entry_v1, flags); \
    CHECK_FIELD_(struct, grant_entry_v1, domid); \
    CHECK_FIELD_(struct, grant_entry_v1, frame)

#define CHECK_grant_entry_header \
    CHECK_SIZE_(struct, grant_entry_header); \
    CHECK_FIELD_(struct, grant_entry_header, flags); \
    CHECK_FIELD_(struct, grant_entry_header, domid)

#define CHECK_grant_entry_v2 \
    CHECK_SIZE_(union, grant_entry_v2); \
    CHECK_FIELD_(union, grant_entry_v2, hdr); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, full_page, hdr); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, full_page, pad0); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, full_page, frame); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, sub_page, hdr); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, sub_page, page_off); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, sub_page, length); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, sub_page, frame); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, transitive, hdr); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, transitive, trans_domid); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, transitive, pad0); \
    CHECK_SUBFIELD_1_(union, grant_entry_v2, transitive, gref); \
    CHECK_FIELD_(union, grant_entry_v2, __spacer)

#define CHECK_gnttab_swap_grant_ref \
    CHECK_SIZE_(struct, gnttab_swap_grant_ref); \
    CHECK_FIELD_(struct, gnttab_swap_grant_ref, ref_a); \
    CHECK_FIELD_(struct, gnttab_swap_grant_ref, ref_b); \
    CHECK_FIELD_(struct, gnttab_swap_grant_ref, status)
