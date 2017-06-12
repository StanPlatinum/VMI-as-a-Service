
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
