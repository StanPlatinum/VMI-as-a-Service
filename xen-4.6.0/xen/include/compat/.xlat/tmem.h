
#define CHECK_tmem_oid \
    CHECK_SIZE_(struct, tmem_oid); \
    CHECK_FIELD_(struct, tmem_oid, oid)

enum XLAT_tmem_op_u {
    XLAT_tmem_op_u_creat,
    XLAT_tmem_op_u_gen,
};

#define XLAT_tmem_op(_d_, _s_) do { \
    (_d_)->cmd = (_s_)->cmd; \
    (_d_)->pool_id = (_s_)->pool_id; \
    switch (u) { \
    case XLAT_tmem_op_u_creat: \
        { \
            unsigned int i0; \
            for (i0 = 0; i0 <  2; ++i0) { \
                (_d_)->u.creat.uuid[i0] = (_s_)->u.creat.uuid[i0]; \
            } \
        } \
        (_d_)->u.creat.flags = (_s_)->u.creat.flags; \
        (_d_)->u.creat.arg1 = (_s_)->u.creat.arg1; \
        break; \
    case XLAT_tmem_op_u_gen: \
        (_d_)->u.gen.oid = (_s_)->u.gen.oid; \
        (_d_)->u.gen.index = (_s_)->u.gen.index; \
        (_d_)->u.gen.tmem_offset = (_s_)->u.gen.tmem_offset; \
        (_d_)->u.gen.pfn_offset = (_s_)->u.gen.pfn_offset; \
        (_d_)->u.gen.len = (_s_)->u.gen.len; \
        (_d_)->u.gen.cmfn = (_s_)->u.gen.cmfn; \
        break; \
    } \
} while (0)
