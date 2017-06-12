#ifndef _COMPAT_NMI_H
#define _COMPAT_NMI_H
#include <xen/compat.h>
#include <public/nmi.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_nmi_callback {
    unsigned int handler_address;
    unsigned int pad;
};
typedef struct compat_nmi_callback compat_nmi_callback_t;
DEFINE_COMPAT_HANDLE(compat_nmi_callback_t);
#pragma pack()
#endif /* _COMPAT_NMI_H */
