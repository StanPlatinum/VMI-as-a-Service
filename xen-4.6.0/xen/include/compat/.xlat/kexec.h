
#define CHECK_kexec_exec \
    CHECK_SIZE_(struct, kexec_exec); \
    CHECK_FIELD_(struct, kexec_exec, type)

#define XLAT_kexec_image(_d_, _s_) do { \
    { \
        unsigned int i0; \
        for (i0 = 0; i0 <  17; ++i0) { \
            (_d_)->page_list[i0] = (_s_)->page_list[i0]; \
        } \
    } \
    (_d_)->indirection_page = (_s_)->indirection_page; \
    (_d_)->start_address = (_s_)->start_address; \
} while (0)

#define XLAT_kexec_range(_d_, _s_) do { \
    (_d_)->range = (_s_)->range; \
    (_d_)->nr = (_s_)->nr; \
    (_d_)->size = (_s_)->size; \
    (_d_)->start = (_s_)->start; \
} while (0)
