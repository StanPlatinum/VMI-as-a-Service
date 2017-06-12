#ifndef _COMPAT_CALLBACK_H
#define _COMPAT_CALLBACK_H
#include <xen/compat.h>
#include <public/callback.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_callback_register {
    uint16_t type;
    uint16_t flags;
    compat_callback_t address;
};
typedef struct compat_callback_register callback_register_compat_t;
DEFINE_COMPAT_HANDLE(callback_register_compat_t);
struct compat_callback_unregister {
    uint16_t type;
    uint16_t _unused;
};
typedef struct compat_callback_unregister callback_unregister_compat_t;
DEFINE_COMPAT_HANDLE(callback_unregister_compat_t);
#pragma pack()
#endif /* _COMPAT_CALLBACK_H */
