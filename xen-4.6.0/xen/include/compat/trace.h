#ifndef _COMPAT_TRACE_H
#define _COMPAT_TRACE_H
#include <xen/compat.h>
#include <public/trace.h>
#pragma pack(4)
struct compat_t_rec {
    uint32_t event:28;
    uint32_t extra_u32:3;
    uint32_t cycles_included:1;
    union {
        struct {
            uint32_t cycles_lo, cycles_hi;
            uint32_t extra_u32[7];
        } cycles;
        struct {
            uint32_t extra_u32[7];
        } nocycles;
    } u;
};

struct compat_t_buf {
    uint32_t cons;
    uint32_t prod;

};

struct compat_t_info {
    uint16_t tbuf_size;
    uint16_t mfn_offset[];

};
#pragma pack()
#endif /* _COMPAT_TRACE_H */
