#ifndef _COMPAT_KEXEC_H
#define _COMPAT_KEXEC_H
#include <xen/compat.h>
#include <public/kexec.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
typedef struct compat_kexec_image {

    unsigned int page_list[17];

    unsigned int indirection_page;
    unsigned int start_address;
} compat_kexec_image_t;
typedef struct compat_kexec_exec {
    int type;
} compat_kexec_exec_t;
typedef struct compat_kexec_load_v1 {
    int type;
    compat_kexec_image_t image;
} compat_kexec_load_v1_t;
typedef struct compat_kexec_range {
    int range;
    int nr;
    unsigned int size;
    unsigned int start;
} compat_kexec_range_t;

typedef struct compat_kexec_segment {
    union {
        COMPAT_HANDLE(const_void) h;
        uint64_t _pad;
    } buf;
    uint64_t buf_size;
    uint64_t dest_maddr;
    uint64_t dest_size;
} compat_kexec_segment_t;
DEFINE_COMPAT_HANDLE(compat_kexec_segment_t);
typedef struct compat_kexec_load {
    uint8_t type;
    uint8_t _pad;
    uint16_t arch;
    uint32_t nr_segments;
    union {
        COMPAT_HANDLE(compat_kexec_segment_t) h;
        uint64_t _pad;
    } segments;
    uint64_t entry_maddr;
} compat_kexec_load_t;
DEFINE_COMPAT_HANDLE(compat_kexec_load_t);

typedef struct compat_kexec_unload {
    uint8_t type;
} compat_kexec_unload_t;
DEFINE_COMPAT_HANDLE(compat_kexec_unload_t);
#pragma pack()
#endif /* _COMPAT_KEXEC_H */
