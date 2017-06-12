
#define CHECK_dom0_vga_console_info \
    CHECK_SIZE_(struct, dom0_vga_console_info); \
    CHECK_FIELD_(struct, dom0_vga_console_info, video_type); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, text_mode_3, font_height); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, text_mode_3, cursor_x); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, text_mode_3, cursor_y); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, text_mode_3, rows); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, text_mode_3, columns); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, width); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, height); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, bytes_per_line); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, bits_per_pixel); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, lfb_base); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, lfb_size); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, red_pos); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, red_size); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, green_pos); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, green_size); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, blue_pos); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, blue_size); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, rsvd_pos); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, rsvd_size); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, gbl_caps); \
    CHECK_SUBFIELD_2_(struct, dom0_vga_console_info, u, vesa_lfb, mode_attrs)

#define CHECK_ctl_bitmap \
    CHECK_SIZE_(struct, ctl_bitmap); \
    CHECK_FIELD_(struct, ctl_bitmap, bitmap); \
    CHECK_FIELD_(struct, ctl_bitmap, nr_bits)

#define CHECK_mmu_update \
    CHECK_SIZE_(struct, mmu_update); \
    CHECK_FIELD_(struct, mmu_update, ptr); \
    CHECK_FIELD_(struct, mmu_update, val)

enum XLAT_mmuext_op_arg1 {
    XLAT_mmuext_op_arg1_mfn,
    XLAT_mmuext_op_arg1_linear_addr,
};

enum XLAT_mmuext_op_arg2 {
    XLAT_mmuext_op_arg2_nr_ents,
    XLAT_mmuext_op_arg2_vcpumask,
    XLAT_mmuext_op_arg2_src_mfn,
};

#define XLAT_mmuext_op(_d_, _s_) do { \
    (_d_)->cmd = (_s_)->cmd; \
    switch (arg1) { \
    case XLAT_mmuext_op_arg1_mfn: \
        (_d_)->arg1.mfn = (_s_)->arg1.mfn; \
        break; \
    case XLAT_mmuext_op_arg1_linear_addr: \
        (_d_)->arg1.linear_addr = (_s_)->arg1.linear_addr; \
        break; \
    } \
    switch (arg2) { \
    case XLAT_mmuext_op_arg2_nr_ents: \
        (_d_)->arg2.nr_ents = (_s_)->arg2.nr_ents; \
        break; \
    case XLAT_mmuext_op_arg2_vcpumask: \
        XLAT_mmuext_op_HNDL_arg2_vcpumask(_d_, _s_); \
        break; \
    case XLAT_mmuext_op_arg2_src_mfn: \
        (_d_)->arg2.src_mfn = (_s_)->arg2.src_mfn; \
        break; \
    } \
} while (0)

enum XLAT_start_info_console {
    XLAT_start_info_console_domU,
    XLAT_start_info_console_dom0,
};

#define XLAT_start_info(_d_, _s_) do { \
    { \
        unsigned int i0; \
        for (i0 = 0; i0 <  32; ++i0) { \
            (_d_)->magic[i0] = (_s_)->magic[i0]; \
        } \
    } \
    (_d_)->nr_pages = (_s_)->nr_pages; \
    (_d_)->shared_info = (_s_)->shared_info; \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->store_mfn = (_s_)->store_mfn; \
    (_d_)->store_evtchn = (_s_)->store_evtchn; \
    switch (console) { \
    case XLAT_start_info_console_domU: \
        (_d_)->console.domU.mfn = (_s_)->console.domU.mfn; \
        (_d_)->console.domU.evtchn = (_s_)->console.domU.evtchn; \
        break; \
    case XLAT_start_info_console_dom0: \
        (_d_)->console.dom0.info_off = (_s_)->console.dom0.info_off; \
        (_d_)->console.dom0.info_size = (_s_)->console.dom0.info_size; \
        break; \
    } \
    (_d_)->pt_base = (_s_)->pt_base; \
    (_d_)->nr_pt_frames = (_s_)->nr_pt_frames; \
    (_d_)->mfn_list = (_s_)->mfn_list; \
    (_d_)->mod_start = (_s_)->mod_start; \
    (_d_)->mod_len = (_s_)->mod_len; \
    { \
        unsigned int i0; \
        for (i0 = 0; i0 <  1024; ++i0) { \
            (_d_)->cmd_line[i0] = (_s_)->cmd_line[i0]; \
        } \
    } \
    (_d_)->first_p2m_pfn = (_s_)->first_p2m_pfn; \
    (_d_)->nr_p2m_frames = (_s_)->nr_p2m_frames; \
} while (0)

#define CHECK_vcpu_time_info \
    CHECK_SIZE_(struct, vcpu_time_info); \
    CHECK_FIELD_(struct, vcpu_time_info, version); \
    CHECK_FIELD_(struct, vcpu_time_info, pad0); \
    CHECK_FIELD_(struct, vcpu_time_info, tsc_timestamp); \
    CHECK_FIELD_(struct, vcpu_time_info, system_time); \
    CHECK_FIELD_(struct, vcpu_time_info, tsc_to_system_mul); \
    CHECK_FIELD_(struct, vcpu_time_info, tsc_shift); \
    CHECK_FIELD_(struct, vcpu_time_info, pad1)
