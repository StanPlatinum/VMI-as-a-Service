#ifndef _COMPAT_TMEM_H
#define _COMPAT_TMEM_H
#include <xen/compat.h>
#include <public/tmem.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_tmem_oid {
    uint64_t oid[3];
};
typedef struct xen_tmem_oid compat_tmem_oid_t;
DEFINE_COMPAT_HANDLE(compat_tmem_oid_t);

typedef COMPAT_HANDLE(char) tmem_cli_va_compat_t;
struct compat_tmem_op {
    uint32_t cmd;
    int32_t pool_id;
    union {
        struct {
            uint64_t uuid[2];
            uint32_t flags;
            uint32_t arg1;
        } creat;
        struct {

            compat_tmem_oid_t oid;

            uint32_t index;
            uint32_t tmem_offset;
            uint32_t pfn_offset;
            uint32_t len;
            compat_pfn_t cmfn;
        } gen;
    } u;
};
typedef struct compat_tmem_op tmem_op_compat_t;
DEFINE_COMPAT_HANDLE(tmem_op_compat_t);
#pragma pack()
#endif /* _COMPAT_TMEM_H */
