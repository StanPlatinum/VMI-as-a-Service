
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

#define CHECK_pmu_amd_ctxt \
    CHECK_SIZE_(struct, pmu_amd_ctxt); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, counters); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, ctrls); \
    CHECK_FIELD_(struct, pmu_amd_ctxt, regs)

#define CHECK_pmu_arch \
    CHECK_SIZE_(struct, pmu_arch); \
    CHECK_pmu_regs; \
    CHECK_SUBFIELD_1_(struct, pmu_arch, r, pad); \
    CHECK_FIELD_(struct, pmu_arch, pmu_flags); \
    CHECK_SUBFIELD_1_(struct, pmu_arch, l, lapic_lvtpc); \
    CHECK_SUBFIELD_1_(struct, pmu_arch, l, pad); \
    CHECK_pmu_amd_ctxt; \
    CHECK_pmu_intel_ctxt; \
    CHECK_SUBFIELD_1_(struct, pmu_arch, c, pad)

#define CHECK_pmu_cntr_pair \
    CHECK_SIZE_(struct, pmu_cntr_pair); \
    CHECK_FIELD_(struct, pmu_cntr_pair, counter); \
    CHECK_FIELD_(struct, pmu_cntr_pair, control)

#define CHECK_pmu_intel_ctxt \
    CHECK_SIZE_(struct, pmu_intel_ctxt); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, fixed_counters); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, arch_counters); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_ovf_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, global_status); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, fixed_ctrl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, ds_area); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, pebs_enable); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, debugctl); \
    CHECK_FIELD_(struct, pmu_intel_ctxt, regs)

#define CHECK_pmu_regs \
    CHECK_SIZE_(struct, pmu_regs); \
    CHECK_FIELD_(struct, pmu_regs, ip); \
    CHECK_FIELD_(struct, pmu_regs, sp); \
    CHECK_FIELD_(struct, pmu_regs, flags); \
    CHECK_FIELD_(struct, pmu_regs, cs); \
    CHECK_FIELD_(struct, pmu_regs, ss); \
    CHECK_FIELD_(struct, pmu_regs, cpl); \
    CHECK_FIELD_(struct, pmu_regs, pad)

#define XLAT_cpu_user_regs(_d_, _s_) do { \
    (_d_)->ebx = (_s_)->ebx; \
    (_d_)->ecx = (_s_)->ecx; \
    (_d_)->edx = (_s_)->edx; \
    (_d_)->esi = (_s_)->esi; \
    (_d_)->edi = (_s_)->edi; \
    (_d_)->ebp = (_s_)->ebp; \
    (_d_)->eax = (_s_)->eax; \
    (_d_)->error_code = (_s_)->error_code; \
    (_d_)->entry_vector = (_s_)->entry_vector; \
    (_d_)->eip = (_s_)->eip; \
    (_d_)->cs = (_s_)->cs; \
    (_d_)->saved_upcall_mask = (_s_)->saved_upcall_mask; \
    (_d_)->eflags = (_s_)->eflags; \
    (_d_)->esp = (_s_)->esp; \
    (_d_)->ss = (_s_)->ss; \
    (_d_)->es = (_s_)->es; \
    (_d_)->ds = (_s_)->ds; \
    (_d_)->fs = (_s_)->fs; \
    (_d_)->gs = (_s_)->gs; \
} while (0)

#define XLAT_trap_info(_d_, _s_) do { \
    (_d_)->vector = (_s_)->vector; \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->cs = (_s_)->cs; \
    (_d_)->address = (_s_)->address; \
} while (0)

#define CHECK_cpu_offline_action \
    CHECK_SIZE_(struct, cpu_offline_action); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_socketid); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_coreid); \
    CHECK_FIELD_(struct, cpu_offline_action, mc_core_threadid)

#define CHECK_mc \
    CHECK_SIZE_(struct, mc); \
    CHECK_FIELD_(struct, mc, cmd); \
    CHECK_FIELD_(struct, mc, interface_version); \
    CHECK_compat_mc_fetch; \
    CHECK_mc_notifydomain; \
    CHECK_compat_mc_physcpuinfo; \
    CHECK_mc_msrinject; \
    CHECK_mc_mceinject; \
    CHECK_compat_mc_inject_v2

#define CHECK_mcinfo_bank \
    CHECK_SIZE_(struct, mcinfo_bank); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_bank, mc_bank); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_domid); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_status); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_addr); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_misc); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_ctrl2); \
    CHECK_FIELD_(struct, mcinfo_bank, mc_tsc)

#define CHECK_mcinfo_common \
    CHECK_SIZE_(struct, mcinfo_common); \
    CHECK_FIELD_(struct, mcinfo_common, type); \
    CHECK_FIELD_(struct, mcinfo_common, size)

#define CHECK_mcinfo_extended \
    CHECK_SIZE_(struct, mcinfo_extended); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_extended, mc_msrs); \
    CHECK_mcinfo_msr

#define CHECK_mcinfo_global \
    CHECK_SIZE_(struct, mcinfo_global); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_global, mc_domid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_vcpuid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_socketid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_coreid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_core_threadid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_apicid); \
    CHECK_FIELD_(struct, mcinfo_global, mc_flags); \
    CHECK_FIELD_(struct, mcinfo_global, mc_gstatus)

#define CHECK_mcinfo_logical_cpu \
    CHECK_SIZE_(struct, mcinfo_logical_cpu); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpunr); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_chipid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_coreid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_threadid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_apicid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_clusterid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_ncores); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_ncores_active); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_nthreads); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpuid_level); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_family); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_vendor); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_model); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_step); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_vendorid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_brandid); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cpu_caps); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cache_size); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_cache_alignment); \
    CHECK_FIELD_(struct, mcinfo_logical_cpu, mc_nmsrvals); \
    CHECK_mcinfo_msr

#define CHECK_mcinfo_msr \
    CHECK_SIZE_(struct, mcinfo_msr); \
    CHECK_FIELD_(struct, mcinfo_msr, reg); \
    CHECK_FIELD_(struct, mcinfo_msr, value)

#define CHECK_mcinfo_recovery \
    CHECK_SIZE_(struct, mcinfo_recovery); \
    CHECK_mcinfo_common; \
    CHECK_FIELD_(struct, mcinfo_recovery, mc_bank); \
    CHECK_FIELD_(struct, mcinfo_recovery, action_flags); \
    CHECK_FIELD_(struct, mcinfo_recovery, action_types); \
    CHECK_page_offline_action; \
    CHECK_cpu_offline_action; \
    CHECK_SUBFIELD_1_(struct, mcinfo_recovery, action_info, pad)

#define XLAT_mc_fetch(_d_, _s_) do { \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->fetch_id = (_s_)->fetch_id; \
    XLAT_mc_fetch_HNDL_data(_d_, _s_); \
} while (0)

#define CHECK_mc_info \
    CHECK_SIZE_(struct, mc_info); \
    CHECK_FIELD_(struct, mc_info, mi_nentries); \
    CHECK_FIELD_(struct, mc_info, flags); \
    CHECK_FIELD_(struct, mc_info, mi_data)

#define CHECK_mc_mceinject \
    CHECK_SIZE_(struct, mc_mceinject); \
    CHECK_FIELD_(struct, mc_mceinject, mceinj_cpunr)

#define CHECK_mc_msrinject \
    CHECK_SIZE_(struct, mc_msrinject); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_cpunr); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_flags); \
    CHECK_FIELD_(struct, mc_msrinject, mcinj_count); \
    CHECK_mcinfo_msr

#define CHECK_mc_notifydomain \
    CHECK_SIZE_(struct, mc_notifydomain); \
    CHECK_FIELD_(struct, mc_notifydomain, mc_domid); \
    CHECK_FIELD_(struct, mc_notifydomain, mc_vcpuid); \
    CHECK_FIELD_(struct, mc_notifydomain, flags)

#define XLAT_mc_physcpuinfo(_d_, _s_) do { \
    (_d_)->ncpus = (_s_)->ncpus; \
    (_d_)->info = (_s_)->info; \
} while (0)

#define CHECK_page_offline_action \
    CHECK_SIZE_(struct, page_offline_action); \
    CHECK_FIELD_(struct, page_offline_action, mfn); \
    CHECK_FIELD_(struct, page_offline_action, status)

#define CHECK_evtchn_alloc_unbound \
    CHECK_SIZE_(struct, evtchn_alloc_unbound); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, dom); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, remote_dom); \
    CHECK_FIELD_(struct, evtchn_alloc_unbound, port)

#define CHECK_evtchn_bind_interdomain \
    CHECK_SIZE_(struct, evtchn_bind_interdomain); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, remote_dom); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, remote_port); \
    CHECK_FIELD_(struct, evtchn_bind_interdomain, local_port)

#define CHECK_evtchn_bind_ipi \
    CHECK_SIZE_(struct, evtchn_bind_ipi); \
    CHECK_FIELD_(struct, evtchn_bind_ipi, vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_ipi, port)

#define CHECK_evtchn_bind_pirq \
    CHECK_SIZE_(struct, evtchn_bind_pirq); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, pirq); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, flags); \
    CHECK_FIELD_(struct, evtchn_bind_pirq, port)

#define CHECK_evtchn_bind_vcpu \
    CHECK_SIZE_(struct, evtchn_bind_vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_vcpu, port); \
    CHECK_FIELD_(struct, evtchn_bind_vcpu, vcpu)

#define CHECK_evtchn_bind_virq \
    CHECK_SIZE_(struct, evtchn_bind_virq); \
    CHECK_FIELD_(struct, evtchn_bind_virq, virq); \
    CHECK_FIELD_(struct, evtchn_bind_virq, vcpu); \
    CHECK_FIELD_(struct, evtchn_bind_virq, port)

#define CHECK_evtchn_close \
    CHECK_SIZE_(struct, evtchn_close); \
    CHECK_FIELD_(struct, evtchn_close, port)

#define CHECK_evtchn_op \
    CHECK_SIZE_(struct, evtchn_op); \
    CHECK_FIELD_(struct, evtchn_op, cmd); \
    CHECK_evtchn_alloc_unbound; \
    CHECK_evtchn_bind_interdomain; \
    CHECK_evtchn_bind_virq; \
    CHECK_evtchn_bind_pirq; \
    CHECK_evtchn_bind_ipi; \
    CHECK_evtchn_close; \
    CHECK_evtchn_send; \
    CHECK_evtchn_status; \
    CHECK_evtchn_bind_vcpu; \
    CHECK_evtchn_unmask

#define CHECK_evtchn_send \
    CHECK_SIZE_(struct, evtchn_send); \
    CHECK_FIELD_(struct, evtchn_send, port)

#define CHECK_evtchn_status \
    CHECK_SIZE_(struct, evtchn_status); \
    CHECK_FIELD_(struct, evtchn_status, dom); \
    CHECK_FIELD_(struct, evtchn_status, port); \
    CHECK_FIELD_(struct, evtchn_status, status); \
    CHECK_FIELD_(struct, evtchn_status, vcpu); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, unbound, dom); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, interdomain, dom); \
    CHECK_SUBFIELD_2_(struct, evtchn_status, u, interdomain, port); \
    CHECK_SUBFIELD_1_(struct, evtchn_status, u, pirq); \
    CHECK_SUBFIELD_1_(struct, evtchn_status, u, virq)

#define CHECK_evtchn_unmask \
    CHECK_SIZE_(struct, evtchn_unmask); \
    CHECK_FIELD_(struct, evtchn_unmask, port)

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

#define CHECK_physdev_eoi \
    CHECK_SIZE_(struct, physdev_eoi); \
    CHECK_FIELD_(struct, physdev_eoi, irq)

#define CHECK_physdev_get_free_pirq \
    CHECK_SIZE_(struct, physdev_get_free_pirq); \
    CHECK_FIELD_(struct, physdev_get_free_pirq, type); \
    CHECK_FIELD_(struct, physdev_get_free_pirq, pirq)

#define CHECK_physdev_irq \
    CHECK_SIZE_(struct, physdev_irq); \
    CHECK_FIELD_(struct, physdev_irq, irq); \
    CHECK_FIELD_(struct, physdev_irq, vector)

#define CHECK_physdev_irq_status_query \
    CHECK_SIZE_(struct, physdev_irq_status_query); \
    CHECK_FIELD_(struct, physdev_irq_status_query, irq); \
    CHECK_FIELD_(struct, physdev_irq_status_query, flags)

#define CHECK_physdev_manage_pci \
    CHECK_SIZE_(struct, physdev_manage_pci); \
    CHECK_FIELD_(struct, physdev_manage_pci, bus); \
    CHECK_FIELD_(struct, physdev_manage_pci, devfn)

#define CHECK_physdev_manage_pci_ext \
    CHECK_SIZE_(struct, physdev_manage_pci_ext); \
    CHECK_FIELD_(struct, physdev_manage_pci_ext, bus); \
    CHECK_FIELD_(struct, physdev_manage_pci_ext, devfn); \
    CHECK_FIELD_(struct, physdev_manage_pci_ext, is_extfn); \
    CHECK_FIELD_(struct, physdev_manage_pci_ext, is_virtfn); \
    CHECK_SUBFIELD_1_(struct, physdev_manage_pci_ext, physfn, bus); \
    CHECK_SUBFIELD_1_(struct, physdev_manage_pci_ext, physfn, devfn)

#define CHECK_physdev_pci_device \
    CHECK_SIZE_(struct, physdev_pci_device); \
    CHECK_FIELD_(struct, physdev_pci_device, seg); \
    CHECK_FIELD_(struct, physdev_pci_device, bus); \
    CHECK_FIELD_(struct, physdev_pci_device, devfn)

#define CHECK_physdev_pci_device_add \
    CHECK_SIZE_(struct, physdev_pci_device_add); \
    CHECK_FIELD_(struct, physdev_pci_device_add, seg); \
    CHECK_FIELD_(struct, physdev_pci_device_add, bus); \
    CHECK_FIELD_(struct, physdev_pci_device_add, devfn); \
    CHECK_FIELD_(struct, physdev_pci_device_add, flags); \
    CHECK_SUBFIELD_1_(struct, physdev_pci_device_add, physfn, bus); \
    CHECK_SUBFIELD_1_(struct, physdev_pci_device_add, physfn, devfn); \
    CHECK_FIELD_(struct, physdev_pci_device_add, optarr)

#define CHECK_physdev_pci_mmcfg_reserved \
    CHECK_SIZE_(struct, physdev_pci_mmcfg_reserved); \
    CHECK_FIELD_(struct, physdev_pci_mmcfg_reserved, address); \
    CHECK_FIELD_(struct, physdev_pci_mmcfg_reserved, segment); \
    CHECK_FIELD_(struct, physdev_pci_mmcfg_reserved, start_bus); \
    CHECK_FIELD_(struct, physdev_pci_mmcfg_reserved, end_bus); \
    CHECK_FIELD_(struct, physdev_pci_mmcfg_reserved, flags)

#define CHECK_physdev_unmap_pirq \
    CHECK_SIZE_(struct, physdev_unmap_pirq); \
    CHECK_FIELD_(struct, physdev_unmap_pirq, domid); \
    CHECK_FIELD_(struct, physdev_unmap_pirq, pirq)

#define CHECK_physdev_restore_msi \
    CHECK_SIZE_(struct, physdev_restore_msi); \
    CHECK_FIELD_(struct, physdev_restore_msi, bus); \
    CHECK_FIELD_(struct, physdev_restore_msi, devfn)

#define CHECK_physdev_set_iopl \
    CHECK_SIZE_(struct, physdev_set_iopl); \
    CHECK_FIELD_(struct, physdev_set_iopl, iopl)

#define CHECK_physdev_setup_gsi \
    CHECK_SIZE_(struct, physdev_setup_gsi); \
    CHECK_FIELD_(struct, physdev_setup_gsi, gsi); \
    CHECK_FIELD_(struct, physdev_setup_gsi, triggering); \
    CHECK_FIELD_(struct, physdev_setup_gsi, polarity)

#define XLAT_pct_register(_d_, _s_) do { \
    (_d_)->descriptor = (_s_)->descriptor; \
    (_d_)->length = (_s_)->length; \
    (_d_)->space_id = (_s_)->space_id; \
    (_d_)->bit_width = (_s_)->bit_width; \
    (_d_)->bit_offset = (_s_)->bit_offset; \
    (_d_)->reserved = (_s_)->reserved; \
    (_d_)->address = (_s_)->address; \
} while (0)

#define XLAT_power_register(_d_, _s_) do { \
    (_d_)->space_id = (_s_)->space_id; \
    (_d_)->bit_width = (_s_)->bit_width; \
    (_d_)->bit_offset = (_s_)->bit_offset; \
    (_d_)->access_size = (_s_)->access_size; \
    (_d_)->address = (_s_)->address; \
} while (0)

#define CHECK_processor_csd \
    CHECK_SIZE_(struct, processor_csd); \
    CHECK_FIELD_(struct, processor_csd, domain); \
    CHECK_FIELD_(struct, processor_csd, coord_type); \
    CHECK_FIELD_(struct, processor_csd, num)

#define XLAT_processor_cx(_d_, _s_) do { \
    XLAT_power_register(&(_d_)->reg, &(_s_)->reg); \
    (_d_)->type = (_s_)->type; \
    (_d_)->latency = (_s_)->latency; \
    (_d_)->power = (_s_)->power; \
    (_d_)->dpcnt = (_s_)->dpcnt; \
    XLAT_processor_cx_HNDL_dp(_d_, _s_); \
} while (0)

#define XLAT_processor_flags(_d_, _s_) do { \
    (_d_)->bm_control = (_s_)->bm_control; \
    (_d_)->bm_check = (_s_)->bm_check; \
    (_d_)->has_cst = (_s_)->has_cst; \
    (_d_)->power_setup_done = (_s_)->power_setup_done; \
    (_d_)->bm_rld_set = (_s_)->bm_rld_set; \
} while (0)

#define XLAT_processor_performance(_d_, _s_) do { \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->platform_limit = (_s_)->platform_limit; \
    XLAT_pct_register(&(_d_)->control_register, &(_s_)->control_register); \
    XLAT_pct_register(&(_d_)->status_register, &(_s_)->status_register); \
    (_d_)->state_count = (_s_)->state_count; \
    XLAT_processor_performance_HNDL_states(_d_, _s_); \
    XLAT_psd_package(&(_d_)->domain_info, &(_s_)->domain_info); \
    (_d_)->shared_type = (_s_)->shared_type; \
} while (0)

#define XLAT_processor_power(_d_, _s_) do { \
    (_d_)->count = (_s_)->count; \
    XLAT_processor_flags(&(_d_)->flags, &(_s_)->flags); \
    XLAT_processor_power_HNDL_states(_d_, _s_); \
} while (0)

#define CHECK_processor_px \
    CHECK_SIZE_(struct, processor_px); \
    CHECK_FIELD_(struct, processor_px, core_frequency); \
    CHECK_FIELD_(struct, processor_px, power); \
    CHECK_FIELD_(struct, processor_px, transition_latency); \
    CHECK_FIELD_(struct, processor_px, bus_master_latency); \
    CHECK_FIELD_(struct, processor_px, control); \
    CHECK_FIELD_(struct, processor_px, status)

#define XLAT_psd_package(_d_, _s_) do { \
    (_d_)->num_entries = (_s_)->num_entries; \
    (_d_)->revision = (_s_)->revision; \
    (_d_)->domain = (_s_)->domain; \
    (_d_)->coord_type = (_s_)->coord_type; \
    (_d_)->num_processors = (_s_)->num_processors; \
} while (0)

#define CHECK_pf_enter_acpi_sleep \
    CHECK_SIZE_(struct, pf_enter_acpi_sleep); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, val_a); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, val_b); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, sleep_state); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, flags)

#define XLAT_pf_symdata(_d_, _s_) do { \
    (_d_)->namelen = (_s_)->namelen; \
    (_d_)->symnum = (_s_)->symnum; \
    XLAT_pf_symdata_HNDL_name(_d_, _s_); \
    (_d_)->address = (_s_)->address; \
    (_d_)->type = (_s_)->type; \
} while (0)

#define CHECK_pf_pcpuinfo \
    CHECK_SIZE_(struct, pf_pcpuinfo); \
    CHECK_FIELD_(struct, pf_pcpuinfo, xen_cpuid); \
    CHECK_FIELD_(struct, pf_pcpuinfo, max_present); \
    CHECK_FIELD_(struct, pf_pcpuinfo, flags); \
    CHECK_FIELD_(struct, pf_pcpuinfo, apic_id); \
    CHECK_FIELD_(struct, pf_pcpuinfo, acpi_id)

#define CHECK_pf_pcpu_version \
    CHECK_SIZE_(struct, pf_pcpu_version); \
    CHECK_FIELD_(struct, pf_pcpu_version, xen_cpuid); \
    CHECK_FIELD_(struct, pf_pcpu_version, max_present); \
    CHECK_FIELD_(struct, pf_pcpu_version, vendor_id); \
    CHECK_FIELD_(struct, pf_pcpu_version, family); \
    CHECK_FIELD_(struct, pf_pcpu_version, model); \
    CHECK_FIELD_(struct, pf_pcpu_version, stepping)

#define CHECK_pf_resource_entry \
    CHECK_SIZE_(struct, pf_resource_entry); \
    CHECK_SUBFIELD_1_(struct, pf_resource_entry, u, cmd); \
    CHECK_SUBFIELD_1_(struct, pf_resource_entry, u, ret); \
    CHECK_FIELD_(struct, pf_resource_entry, rsvd); \
    CHECK_FIELD_(struct, pf_resource_entry, idx); \
    CHECK_FIELD_(struct, pf_resource_entry, val)

#define CHECK_pmu_data \
    CHECK_SIZE_(struct, pmu_data); \
    CHECK_FIELD_(struct, pmu_data, vcpu_id); \
    CHECK_FIELD_(struct, pmu_data, pcpu_id); \
    CHECK_FIELD_(struct, pmu_data, domain_id); \
    CHECK_FIELD_(struct, pmu_data, pad); \
    CHECK_pmu_arch

#define CHECK_pmu_params \
    CHECK_SIZE_(struct, pmu_params); \
    CHECK_SUBFIELD_1_(struct, pmu_params, version, maj); \
    CHECK_SUBFIELD_1_(struct, pmu_params, version, min); \
    CHECK_FIELD_(struct, pmu_params, val); \
    CHECK_FIELD_(struct, pmu_params, vcpu); \
    CHECK_FIELD_(struct, pmu_params, pad)

#define XLAT_sched_poll(_d_, _s_) do { \
    XLAT_sched_poll_HNDL_ports(_d_, _s_); \
    (_d_)->nr_ports = (_s_)->nr_ports; \
    (_d_)->timeout = (_s_)->timeout; \
} while (0)

#define CHECK_sched_remote_shutdown \
    CHECK_SIZE_(struct, sched_remote_shutdown); \
    CHECK_FIELD_(struct, sched_remote_shutdown, domain_id); \
    CHECK_FIELD_(struct, sched_remote_shutdown, reason)

#define CHECK_sched_shutdown \
    CHECK_SIZE_(struct, sched_shutdown); \
    CHECK_FIELD_(struct, sched_shutdown, reason)

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

#define CHECK_t_buf \
    CHECK_SIZE_(struct, t_buf); \
    CHECK_FIELD_(struct, t_buf, cons); \
    CHECK_FIELD_(struct, t_buf, prod)

#define CHECK_vcpu_get_physid \
    CHECK_SIZE_(struct, vcpu_get_physid); \
    CHECK_FIELD_(struct, vcpu_get_physid, phys_id)

#define CHECK_vcpu_register_vcpu_info \
    CHECK_SIZE_(struct, vcpu_register_vcpu_info); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, mfn); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, offset); \
    CHECK_FIELD_(struct, vcpu_register_vcpu_info, rsvd)

#define XLAT_vcpu_runstate_info(_d_, _s_) do { \
    (_d_)->state = (_s_)->state; \
    (_d_)->state_entry_time = (_s_)->state_entry_time; \
    { \
        unsigned int i0; \
        for (i0 = 0; i0 <  4; ++i0) { \
            (_d_)->time[i0] = (_s_)->time[i0]; \
        } \
    } \
} while (0)

#define CHECK_vcpu_set_periodic_timer \
    CHECK_SIZE_(struct, vcpu_set_periodic_timer); \
    CHECK_FIELD_(struct, vcpu_set_periodic_timer, period_ns)

#define XLAT_vcpu_set_singleshot_timer(_d_, _s_) do { \
    (_d_)->timeout_abs_ns = (_s_)->timeout_abs_ns; \
    (_d_)->flags = (_s_)->flags; \
} while (0)

#define CHECK_oprof_init \
    CHECK_SIZE_(struct, oprof_init); \
    CHECK_FIELD_(struct, oprof_init, num_events); \
    CHECK_FIELD_(struct, oprof_init, is_primary); \
    CHECK_FIELD_(struct, oprof_init, cpu_type)

#define CHECK_oprof_passive \
    CHECK_SIZE_(struct, oprof_passive); \
    CHECK_FIELD_(struct, oprof_passive, domain_id); \
    CHECK_FIELD_(struct, oprof_passive, max_samples); \
    CHECK_FIELD_(struct, oprof_passive, nbuf); \
    CHECK_FIELD_(struct, oprof_passive, bufsize); \
    CHECK_FIELD_(struct, oprof_passive, buf_gmaddr)
