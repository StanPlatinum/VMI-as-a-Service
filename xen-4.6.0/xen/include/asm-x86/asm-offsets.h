/*
 * DO NOT MODIFY.
 *
 * This file was auto-generated from arch/x86/asm-offsets.s
 *
 */

#ifndef __ASM_OFFSETS_H__
#define __ASM_OFFSETS_H__

#define UREGS_r15 0 /* offsetof(struct cpu_user_regs, r15) */
#define UREGS_r14 8 /* offsetof(struct cpu_user_regs, r14) */
#define UREGS_r13 16 /* offsetof(struct cpu_user_regs, r13) */
#define UREGS_r12 24 /* offsetof(struct cpu_user_regs, r12) */
#define UREGS_rbp 32 /* offsetof(struct cpu_user_regs, rbp) */
#define UREGS_rbx 40 /* offsetof(struct cpu_user_regs, rbx) */
#define UREGS_r11 48 /* offsetof(struct cpu_user_regs, r11) */
#define UREGS_r10 56 /* offsetof(struct cpu_user_regs, r10) */
#define UREGS_r9 64 /* offsetof(struct cpu_user_regs, r9) */
#define UREGS_r8 72 /* offsetof(struct cpu_user_regs, r8) */
#define UREGS_rax 80 /* offsetof(struct cpu_user_regs, rax) */
#define UREGS_rcx 88 /* offsetof(struct cpu_user_regs, rcx) */
#define UREGS_rdx 96 /* offsetof(struct cpu_user_regs, rdx) */
#define UREGS_rsi 104 /* offsetof(struct cpu_user_regs, rsi) */
#define UREGS_rdi 112 /* offsetof(struct cpu_user_regs, rdi) */
#define UREGS_error_code 120 /* offsetof(struct cpu_user_regs, error_code) */
#define UREGS_entry_vector 124 /* offsetof(struct cpu_user_regs, entry_vector) */
#define UREGS_saved_upcall_mask 140 /* offsetof(struct cpu_user_regs, saved_upcall_mask) */
#define UREGS_rip 128 /* offsetof(struct cpu_user_regs, rip) */
#define UREGS_cs 136 /* offsetof(struct cpu_user_regs, cs) */
#define UREGS_eflags 144 /* offsetof(struct cpu_user_regs, eflags) */
#define UREGS_rsp 152 /* offsetof(struct cpu_user_regs, rsp) */
#define UREGS_ss 160 /* offsetof(struct cpu_user_regs, ss) */
#define UREGS_ds 176 /* offsetof(struct cpu_user_regs, ds) */
#define UREGS_es 168 /* offsetof(struct cpu_user_regs, es) */
#define UREGS_fs 184 /* offsetof(struct cpu_user_regs, fs) */
#define UREGS_gs 192 /* offsetof(struct cpu_user_regs, gs) */
#define UREGS_kernel_sizeof 168 /* offsetof(struct cpu_user_regs, es) */
#define UREGS_user_sizeof 200 /* sizeof(struct cpu_user_regs) */

#define irq_caps_offset 336 /* offsetof(struct domain, irq_caps) */
#define next_in_list_offset 112 /* offsetof(struct domain, next_in_list) */
#define VCPU_processor 4 /* offsetof(struct vcpu, processor) */
#define VCPU_domain 16 /* offsetof(struct vcpu, domain) */
#define VCPU_vcpu_info 8 /* offsetof(struct vcpu, vcpu_info) */
#define VCPU_trap_bounce 1448 /* offsetof(struct vcpu, arch.pv_vcpu.trap_bounce) */
#define VCPU_int80_bounce 1464 /* offsetof(struct vcpu, arch.pv_vcpu.int80_bounce) */
#define VCPU_thread_flags 920 /* offsetof(struct vcpu, arch.flags) */
#define VCPU_event_addr 1376 /* offsetof(struct vcpu, arch.pv_vcpu.event_callback_eip) */
#define VCPU_event_sel 1392 /* offsetof(struct vcpu, arch.pv_vcpu.event_callback_cs) */
#define VCPU_failsafe_addr 1384 /* offsetof(struct vcpu, arch.pv_vcpu.failsafe_callback_eip) */
#define VCPU_failsafe_sel 1396 /* offsetof(struct vcpu, arch.pv_vcpu.failsafe_callback_cs) */
#define VCPU_syscall_addr 1392 /* offsetof(struct vcpu, arch.pv_vcpu.syscall_callback_eip) */
#define VCPU_syscall32_addr 1400 /* offsetof(struct vcpu, arch.pv_vcpu.syscall32_callback_eip) */
#define VCPU_syscall32_sel 1416 /* offsetof(struct vcpu, arch.pv_vcpu.syscall32_callback_cs) */
#define VCPU_syscall32_disables_events 1420 /* offsetof(struct vcpu, arch.pv_vcpu.syscall32_disables_events) */
#define VCPU_sysenter_addr 1408 /* offsetof(struct vcpu, arch.pv_vcpu.sysenter_callback_eip) */
#define VCPU_sysenter_sel 1418 /* offsetof(struct vcpu, arch.pv_vcpu.sysenter_callback_cs) */
#define VCPU_sysenter_disables_events 1421 /* offsetof(struct vcpu, arch.pv_vcpu.sysenter_disables_events) */
#define VCPU_trap_ctxt 1160 /* offsetof(struct vcpu, arch.pv_vcpu.trap_ctxt) */
#define VCPU_kernel_sp 1304 /* offsetof(struct vcpu, arch.pv_vcpu.kernel_sp) */
#define VCPU_kernel_ss 1296 /* offsetof(struct vcpu, arch.pv_vcpu.kernel_ss) */
#define VCPU_guest_context_flags 648 /* offsetof(struct vcpu, arch.vgc_flags) */
#define VCPU_nmi_pending 269 /* offsetof(struct vcpu, async_exception_state[(1)-1].pending) */
#define VCPU_mce_pending 271 /* offsetof(struct vcpu, async_exception_state[(2)-1].pending) */
#define VCPU_nmi_old_mask 270 /* offsetof(struct vcpu, async_exception_state[(1)-1].old_mask) */
#define VCPU_mce_old_mask 272 /* offsetof(struct vcpu, async_exception_state[(2)-1].old_mask) */
#define VCPU_async_exception_mask 273 /* offsetof(struct vcpu, async_exception_mask) */
#define VCPU_TRAP_NMI 1 /* VCPU_TRAP_NMI */
#define VCPU_TRAP_MCE 2 /* VCPU_TRAP_MCE */
#define _VGCF_failsafe_disables_events 3 /* _VGCF_failsafe_disables_events */
#define _VGCF_syscall_disables_events 4 /* _VGCF_syscall_disables_events */

#define VCPU_svm_vmcb_pa 1480 /* offsetof(struct vcpu, arch.hvm_vcpu.u.svm.vmcb_pa) */
#define VCPU_svm_vmcb 1472 /* offsetof(struct vcpu, arch.hvm_vcpu.u.svm.vmcb) */
#define VCPU_svm_vmcb_in_sync 1500 /* offsetof(struct vcpu, arch.hvm_vcpu.u.svm.vmcb_in_sync) */

#define VCPU_vmx_launched 1516 /* offsetof(struct vcpu, arch.hvm_vcpu.u.vmx.launched) */
#define VCPU_vmx_realmode 1737 /* offsetof(struct vcpu, arch.hvm_vcpu.u.vmx.vmx_realmode) */
#define VCPU_vmx_emulate 1738 /* offsetof(struct vcpu, arch.hvm_vcpu.u.vmx.vmx_emulate) */
#define VCPU_vm86_seg_mask 1740 /* offsetof(struct vcpu, arch.hvm_vcpu.u.vmx.vm86_segment_mask) */
#define VCPU_hvm_guest_cr2 1040 /* offsetof(struct vcpu, arch.hvm_vcpu.guest_cr[2]) */

#define VCPU_nhvm_guestmode 1960 /* offsetof(struct vcpu, arch.hvm_vcpu.nvcpu.nv_guestmode) */
#define VCPU_nhvm_p2m 2192 /* offsetof(struct vcpu, arch.hvm_vcpu.nvcpu.nv_p2m) */
#define VCPU_nsvm_hap_enabled 2148 /* offsetof(struct vcpu, arch.hvm_vcpu.nvcpu.u.nsvm.ns_hap_enabled) */

#define DOMAIN_is_32bit_pv 3488 /* offsetof(struct domain, arch.is_32bit_pv) */

#define VMCB_rax 1528 /* offsetof(struct vmcb_struct, rax) */
#define VMCB_rip 1400 /* offsetof(struct vmcb_struct, rip) */
#define VMCB_rsp 1496 /* offsetof(struct vmcb_struct, rsp) */
#define VMCB_rflags 1392 /* offsetof(struct vmcb_struct, rflags) */

#define VCPUINFO_upcall_pending 0 /* offsetof(struct vcpu_info, evtchn_upcall_pending) */
#define VCPUINFO_upcall_mask 1 /* offsetof(struct vcpu_info, evtchn_upcall_mask) */

#define COMPAT_VCPUINFO_upcall_pending 0 /* offsetof(struct compat_vcpu_info, evtchn_upcall_pending) */
#define COMPAT_VCPUINFO_upcall_mask 1 /* offsetof(struct compat_vcpu_info, evtchn_upcall_mask) */

#define CPUINFO_guest_cpu_user_regs 0 /* offsetof(struct cpu_info, guest_cpu_user_regs) */
#define CPUINFO_processor_id 200 /* offsetof(struct cpu_info, processor_id) */
#define CPUINFO_current_vcpu 208 /* offsetof(struct cpu_info, current_vcpu) */
#define CPUINFO_sizeof 232 /* sizeof(struct cpu_info) */

#define TRAPINFO_eip 8 /* offsetof(struct trap_info, address) */
#define TRAPINFO_cs 2 /* offsetof(struct trap_info, cs) */
#define TRAPINFO_flags 1 /* offsetof(struct trap_info, flags) */
#define TRAPINFO_sizeof 16 /* sizeof(struct trap_info) */

#define TRAPBOUNCE_error_code 0 /* offsetof(struct trap_bounce, error_code) */
#define TRAPBOUNCE_flags 4 /* offsetof(struct trap_bounce, flags) */
#define TRAPBOUNCE_cs 6 /* offsetof(struct trap_bounce, cs) */
#define TRAPBOUNCE_eip 8 /* offsetof(struct trap_bounce, eip) */

#define IRQSTAT_shift 7 /* LOG_2(sizeof(irq_cpustat_t)) */
#define IRQSTAT_softirq_pending 0 /* offsetof(irq_cpustat_t, __softirq_pending) */

#define CPUINFO_features 12 /* offsetof(struct cpuinfo_x86, x86_capability) */

#define MB_flags 0 /* offsetof(multiboot_info_t, flags) */
#define MB_cmdline 16 /* offsetof(multiboot_info_t, cmdline) */
#define MB_mem_lower 4 /* offsetof(multiboot_info_t, mem_lower) */

#endif
