#ifndef _COMPAT_XEN_H
#define _COMPAT_XEN_H
#include <xen/compat.h>
#include <public/xen.h>
#pragma pack(4)
#include <public/xen-compat.h>
#pragma pack(4)

#include "arch-x86/xen.h"
#pragma pack(4)
DEFINE_COMPAT_HANDLE(char);
__DEFINE_COMPAT_HANDLE(uchar, unsigned char);
DEFINE_COMPAT_HANDLE(int);
__DEFINE_COMPAT_HANDLE(uint, unsigned int);

DEFINE_COMPAT_HANDLE(void);

DEFINE_COMPAT_HANDLE(uint64_t);
DEFINE_COMPAT_HANDLE(compat_pfn_t);
DEFINE_COMPAT_HANDLE(compat_ulong_t);
struct compat_mmuext_op {
    unsigned int cmd;
    union {

        compat_pfn_t mfn;

        unsigned int linear_addr;
    } arg1;
    union {

        unsigned int nr_ents;

        COMPAT_HANDLE(const_void) vcpumask;

        compat_pfn_t src_mfn;
    } arg2;
};
typedef struct compat_mmuext_op mmuext_op_compat_t;
DEFINE_COMPAT_HANDLE(mmuext_op_compat_t);
typedef uint16_t domid_compat_t;
struct compat_mmu_update {
    uint64_t ptr;
    uint64_t val;
};
typedef struct mmu_update mmu_update_compat_t;
DEFINE_COMPAT_HANDLE(mmu_update_compat_t);
struct compat_multicall_entry {
    compat_ulong_t op, result;
    compat_ulong_t args[6];
};
typedef struct compat_multicall_entry multicall_entry_compat_t;
DEFINE_COMPAT_HANDLE(multicall_entry_compat_t);
struct compat_vcpu_time_info {
    uint32_t version;
    uint32_t pad0;
    uint64_t tsc_timestamp;
    uint64_t system_time;

    uint32_t tsc_to_system_mul;
    int8_t tsc_shift;
    int8_t pad1[3];
};
typedef struct vcpu_time_info vcpu_time_info_compat_t;

struct compat_vcpu_info {
    uint8_t evtchn_upcall_pending;
#ifdef COMPAT_HAVE_PV_UPCALL_MASK
    uint8_t evtchn_upcall_mask;
#else
    uint8_t pad0;
#endif
    compat_ulong_t evtchn_pending_sel;
    struct compat_arch_vcpu_info arch;
    struct vcpu_time_info time;
};
struct compat_shared_info {
    struct compat_vcpu_info vcpu_info[COMPAT_LEGACY_MAX_VCPUS];
    compat_ulong_t evtchn_pending[sizeof(compat_ulong_t) * 8];
    compat_ulong_t evtchn_mask[sizeof(compat_ulong_t) * 8];

    uint32_t wc_version;
    uint32_t wc_sec;
    uint32_t wc_nsec;

    struct compat_arch_shared_info arch;

};
#ifdef COMPAT_HAVE_PV_GUEST_ENTRY
struct compat_start_info {

    char magic[32];
    unsigned int nr_pages;
    unsigned int shared_info;
    uint32_t flags;
    compat_pfn_t store_mfn;
    uint32_t store_evtchn;
    union {
        struct {
            compat_pfn_t mfn;
            uint32_t evtchn;
        } domU;
        struct {
            uint32_t info_off;
            uint32_t info_size;
        } dom0;
    } console;

    unsigned int pt_base;
    unsigned int nr_pt_frames;
    unsigned int mfn_list;
    unsigned int mod_start;

    unsigned int mod_len;

    int8_t cmd_line[1024];

    unsigned int first_p2m_pfn;
    unsigned int nr_p2m_frames;
};
typedef struct compat_start_info start_info_compat_t;

#endif
struct compat_multiboot_mod_list
{

    uint32_t mod_start;

    uint32_t mod_end;

    uint32_t cmdline;

    uint32_t pad;
};
typedef struct compat_dom0_vga_console_info {
    uint8_t video_type;

    union {
        struct {

            uint16_t font_height;

            uint16_t cursor_x, cursor_y;

            uint16_t rows, columns;
        } text_mode_3;

        struct {

            uint16_t width, height;

            uint16_t bytes_per_line;

            uint16_t bits_per_pixel;

            uint32_t lfb_base;
            uint32_t lfb_size;

            uint8_t red_pos, red_size;
            uint8_t green_pos, green_size;
            uint8_t blue_pos, blue_size;
            uint8_t rsvd_pos, rsvd_size;

            uint32_t gbl_caps;

            uint16_t mode_attrs;

        } vesa_lfb;
    } u;
} dom0_vga_console_info_compat_t;

typedef uint8_t compat_domain_handle_t[16];

__DEFINE_COMPAT_HANDLE(uint8, uint8_t);
__DEFINE_COMPAT_HANDLE(uint16, uint16_t);
__DEFINE_COMPAT_HANDLE(uint32, uint32_t);
__DEFINE_COMPAT_HANDLE(uint64, uint64_t);
struct compat_ctl_bitmap {
    COMPAT_HANDLE(uint8) bitmap;
    uint32_t nr_bits;
};
#pragma pack()
#endif /* _COMPAT_XEN_H */
