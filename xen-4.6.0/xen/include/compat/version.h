#ifndef _COMPAT_VERSION_H
#define _COMPAT_VERSION_H
#include <xen/compat.h>
#include <public/version.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
typedef char compat_extraversion_t[16];

struct compat_compile_info {
    char compiler[64];
    char compile_by[16];
    char compile_domain[32];
    char compile_date[32];
};
typedef struct compat_compile_info compat_compile_info_t;

typedef char compat_capabilities_info_t[1024];

typedef char compat_changeset_info_t[64];

struct compat_platform_parameters {
    compat_ulong_t virt_start;
};
typedef struct compat_platform_parameters compat_platform_parameters_t;

struct compat_feature_info {
    unsigned int submap_idx;
    uint32_t submap;
};
typedef struct compat_feature_info compat_feature_info_t;

#include "features.h"
#pragma pack(4)
typedef char compat_commandline_t[1024];
#pragma pack()
#endif /* _COMPAT_VERSION_H */
