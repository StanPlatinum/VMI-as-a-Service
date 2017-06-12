
#define XLAT_trap_info(_d_, _s_) do { \
    (_d_)->vector = (_s_)->vector; \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->cs = (_s_)->cs; \
    (_d_)->address = (_s_)->address; \
} while (0)
