
#define CHECK_t_buf \
    CHECK_SIZE_(struct, t_buf); \
    CHECK_FIELD_(struct, t_buf, cons); \
    CHECK_FIELD_(struct, t_buf, prod)
