#ifndef _COMPAT_PLATFORM_H
#define _COMPAT_PLATFORM_H
#include <xen/compat.h>
#include <public/platform.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_pf_settime32 {

    uint32_t secs;
    uint32_t nsecs;
    uint64_t system_time;
};

struct compat_pf_settime64 {

    uint64_t secs;
    uint32_t nsecs;
    uint32_t mbz;
    uint64_t system_time;
};

typedef struct compat_pf_settime64 compat_pf_settime_t;
DEFINE_COMPAT_HANDLE(compat_pf_settime_t);
struct compat_pf_add_memtype {

    compat_pfn_t mfn;
    uint64_t nr_mfns;
    uint32_t type;

    uint32_t handle;
    uint32_t reg;
};
typedef struct compat_pf_add_memtype compat_pf_add_memtype_t;
DEFINE_COMPAT_HANDLE(compat_pf_add_memtype_t);
struct compat_pf_del_memtype {

    uint32_t handle;
    uint32_t reg;
};
typedef struct compat_pf_del_memtype compat_pf_del_memtype_t;
DEFINE_COMPAT_HANDLE(compat_pf_del_memtype_t);

struct compat_pf_read_memtype {

    uint32_t reg;

    compat_pfn_t mfn;
    uint64_t nr_mfns;
    uint32_t type;
};
typedef struct compat_pf_read_memtype compat_pf_read_memtype_t;
DEFINE_COMPAT_HANDLE(compat_pf_read_memtype_t);

struct compat_pf_microcode_update {

    COMPAT_HANDLE(const_void) data;
    uint32_t length;
};
typedef struct compat_pf_microcode_update compat_pf_microcode_update_t;
DEFINE_COMPAT_HANDLE(compat_pf_microcode_update_t);

struct compat_pf_platform_quirk {

    uint32_t quirk_id;
};
typedef struct compat_pf_platform_quirk compat_pf_platform_quirk_t;
DEFINE_COMPAT_HANDLE(compat_pf_platform_quirk_t);
struct compat_pf_efi_time {
    uint16_t year;
    uint8_t month;
    uint8_t day;
    uint8_t hour;
    uint8_t min;
    uint8_t sec;
    uint32_t ns;
    int16_t tz;
    uint8_t daylight;
};

struct compat_pf_efi_guid {
    uint32_t data1;
    uint16_t data2;
    uint16_t data3;
    uint8_t data4[8];
};

struct compat_pf_efi_runtime_call {
    uint32_t function;

    uint32_t misc;
    compat_ulong_t status;
    union {

        struct {
            struct compat_pf_efi_time time;
            uint32_t resolution;
            uint32_t accuracy;
        } get_time;

        struct compat_pf_efi_time set_time;

        struct compat_pf_efi_time get_wakeup_time;

        struct compat_pf_efi_time set_wakeup_time;

        struct {
            COMPAT_HANDLE(void) name;
            compat_ulong_t size;
            COMPAT_HANDLE(void) data;
            struct compat_pf_efi_guid vendor_guid;
        } get_variable, set_variable;

        struct {
            compat_ulong_t size;
            COMPAT_HANDLE(void) name;
            struct compat_pf_efi_guid vendor_guid;
        } get_next_variable_name;

        struct {
            uint32_t attr;
            uint64_t max_store_size;
            uint64_t remain_store_size;
            uint64_t max_size;
        } query_variable_info;

        struct {
            COMPAT_HANDLE(void) capsule_header_array;
            compat_ulong_t capsule_count;
            uint64_t max_capsule_size;
            uint32_t reset_type;
        } query_capsule_capabilities;

        struct {
            COMPAT_HANDLE(void) capsule_header_array;
            compat_ulong_t capsule_count;
            uint64_t sg_list;
        } update_capsule;
    } u;
};
typedef struct compat_pf_efi_runtime_call compat_pf_efi_runtime_call_t;
DEFINE_COMPAT_HANDLE(compat_pf_efi_runtime_call_t);
struct compat_pf_firmware_info {

    uint32_t type;
    uint32_t index;

    union {
        struct {

            uint8_t device;
            uint8_t version;
            uint16_t interface_support;

            uint16_t legacy_max_cylinder;
            uint8_t legacy_max_head;
            uint8_t legacy_sectors_per_track;

            COMPAT_HANDLE(void) edd_params;
        } disk_info;
        struct {
            uint8_t device;
            uint32_t mbr_signature;
        } disk_mbr_signature;
        struct {

            uint8_t capabilities;
            uint8_t edid_transfer_time;

            COMPAT_HANDLE(uint8) edid;
        } vbeddc_info;
        union compat_pf_efi_info {
            uint32_t version;
            struct {
                uint64_t addr;
                uint32_t nent;
            } cfg;
            struct {
                uint32_t revision;
                uint32_t bufsz;
                COMPAT_HANDLE(void) name;
            } vendor;
            struct {
                uint64_t addr;
                uint64_t size;
                uint64_t attr;
                uint32_t type;
            } mem;
            struct {

                uint16_t segment;
                uint8_t bus;
                uint8_t devfn;
                uint16_t vendor;
                uint16_t devid;

                uint64_t address;
                compat_ulong_t size;
            } pci_rom;
        } efi_info;

        uint8_t kbd_shift_flags;
    } u;
};
typedef struct compat_pf_firmware_info compat_pf_firmware_info_t;
DEFINE_COMPAT_HANDLE(compat_pf_firmware_info_t);

struct compat_pf_enter_acpi_sleep {

    uint16_t val_a;
    uint16_t val_b;

    uint32_t sleep_state;

    uint32_t flags;
};
typedef struct xenpf_enter_acpi_sleep compat_pf_enter_acpi_sleep_t;
DEFINE_COMPAT_HANDLE(compat_pf_enter_acpi_sleep_t);

struct compat_pf_change_freq {

    uint32_t flags;
    uint32_t cpu;
    uint64_t freq;
};
typedef struct compat_pf_change_freq compat_pf_change_freq_t;
DEFINE_COMPAT_HANDLE(compat_pf_change_freq_t);
struct compat_pf_getidletime {

    COMPAT_HANDLE(uint8) cpumap_bitmap;

    uint32_t cpumap_nr_cpus;

    COMPAT_HANDLE(uint64) idletime;

    uint64_t now;
};
typedef struct compat_pf_getidletime compat_pf_getidletime_t;
DEFINE_COMPAT_HANDLE(compat_pf_getidletime_t);
struct compat_power_register {
    uint32_t space_id;
    uint32_t bit_width;
    uint32_t bit_offset;
    uint32_t access_size;
    uint64_t address;
};

struct compat_processor_csd {
    uint32_t domain;
    uint32_t coord_type;
    uint32_t num;
};
typedef struct xen_processor_csd compat_processor_csd_t;
DEFINE_COMPAT_HANDLE(compat_processor_csd_t);

struct compat_processor_cx {
    struct compat_power_register reg;
    uint8_t type;
    uint32_t latency;
    uint32_t power;
    uint32_t dpcnt;
    COMPAT_HANDLE(compat_processor_csd_t) dp;
};
typedef struct compat_processor_cx compat_processor_cx_t;
DEFINE_COMPAT_HANDLE(compat_processor_cx_t);

struct compat_processor_flags {
    uint32_t bm_control:1;
    uint32_t bm_check:1;
    uint32_t has_cst:1;
    uint32_t power_setup_done:1;
    uint32_t bm_rld_set:1;
};

struct compat_processor_power {
    uint32_t count;
    struct compat_processor_flags flags;
    COMPAT_HANDLE(compat_processor_cx_t) states;
};

struct compat_pct_register {
    uint8_t descriptor;
    uint16_t length;
    uint8_t space_id;
    uint8_t bit_width;
    uint8_t bit_offset;
    uint8_t reserved;
    uint64_t address;
};

struct compat_processor_px {
    uint64_t core_frequency;
    uint64_t power;
    uint64_t transition_latency;
    uint64_t bus_master_latency;
    uint64_t control;
    uint64_t status;
};
typedef struct xen_processor_px compat_processor_px_t;
DEFINE_COMPAT_HANDLE(compat_processor_px_t);

struct compat_psd_package {
    uint64_t num_entries;
    uint64_t revision;
    uint64_t domain;
    uint64_t coord_type;
    uint64_t num_processors;
};

struct compat_processor_performance {
    uint32_t flags;
    uint32_t platform_limit;
    struct compat_pct_register control_register;
    struct compat_pct_register status_register;
    uint32_t state_count;
    COMPAT_HANDLE(compat_processor_px_t) states;
    struct compat_psd_package domain_info;
    uint32_t shared_type;
};
typedef struct compat_processor_performance compat_processor_performance_t;
DEFINE_COMPAT_HANDLE(compat_processor_performance_t);

struct compat_pf_set_processor_pminfo {

    uint32_t id;
    uint32_t type;
    union {
        struct compat_processor_power power;
        struct compat_processor_performance perf;
        COMPAT_HANDLE(uint32) pdc;
    } u;
};
typedef struct compat_pf_set_processor_pminfo compat_pf_set_processor_pminfo_t;
DEFINE_COMPAT_HANDLE(compat_pf_set_processor_pminfo_t);

struct compat_pf_pcpuinfo {

    uint32_t xen_cpuid;

    uint32_t max_present;

    uint32_t flags;
    uint32_t apic_id;
    uint32_t acpi_id;
};
typedef struct xenpf_pcpuinfo compat_pf_pcpuinfo_t;
DEFINE_COMPAT_HANDLE(compat_pf_pcpuinfo_t);

struct compat_pf_pcpu_version {

    uint32_t xen_cpuid;

    uint32_t max_present;
    char vendor_id[12];
    uint32_t family;
    uint32_t model;
    uint32_t stepping;
};
typedef struct xenpf_pcpu_version compat_pf_pcpu_version_t;
DEFINE_COMPAT_HANDLE(compat_pf_pcpu_version_t);

struct compat_pf_cpu_ol
{
    uint32_t cpuid;
};
typedef struct compat_pf_cpu_ol compat_pf_cpu_ol_t;
DEFINE_COMPAT_HANDLE(compat_pf_cpu_ol_t);

struct compat_pf_cpu_hotadd
{
 uint32_t apic_id;
 uint32_t acpi_id;
 uint32_t pxm;
};

struct compat_pf_mem_hotadd
{
    uint64_t spfn;
    uint64_t epfn;
    uint32_t pxm;
    uint32_t flags;
};

struct compat_pf_core_parking {

    uint32_t type;

    uint32_t idle_nums;
};
typedef struct compat_pf_core_parking compat_pf_core_parking_t;
DEFINE_COMPAT_HANDLE(compat_pf_core_parking_t);
struct compat_pf_resource_entry {
    union {
        uint32_t cmd;
        int32_t ret;
    } u;
    uint32_t rsvd;
    uint64_t idx;
    uint64_t val;
};
typedef struct xenpf_resource_entry compat_pf_resource_entry_t;
DEFINE_COMPAT_HANDLE(compat_pf_resource_entry_t);

struct compat_pf_resource_op {
    uint32_t nr_entries;
    uint32_t cpu;
    COMPAT_HANDLE(compat_pf_resource_entry_t) entries;
};
typedef struct compat_pf_resource_op compat_pf_resource_op_t;
DEFINE_COMPAT_HANDLE(compat_pf_resource_op_t);

struct compat_pf_symdata {

    uint32_t namelen;

    uint32_t symnum;

    COMPAT_HANDLE(char) name;
    uint64_t address;
    char type;
};
typedef struct compat_pf_symdata compat_pf_symdata_t;
DEFINE_COMPAT_HANDLE(compat_pf_symdata_t);

struct compat_platform_op {
    uint32_t cmd;
    uint32_t interface_version;
    union {
        struct compat_pf_settime64 settime;
        struct compat_pf_settime32 settime32;
        struct compat_pf_settime64 settime64;
        struct compat_pf_add_memtype add_memtype;
        struct compat_pf_del_memtype del_memtype;
        struct compat_pf_read_memtype read_memtype;
        struct compat_pf_microcode_update microcode;
        struct compat_pf_platform_quirk platform_quirk;
        struct compat_pf_efi_runtime_call efi_runtime_call;
        struct compat_pf_firmware_info firmware_info;
        struct xenpf_enter_acpi_sleep enter_acpi_sleep;
        struct compat_pf_change_freq change_freq;
        struct compat_pf_getidletime getidletime;
        struct compat_pf_set_processor_pminfo set_pminfo;
        struct xenpf_pcpuinfo pcpu_info;
        struct xenpf_pcpu_version pcpu_version;
        struct compat_pf_cpu_ol cpu_ol;
        struct compat_pf_cpu_hotadd cpu_add;
        struct compat_pf_mem_hotadd mem_add;
        struct compat_pf_core_parking core_parking;
        struct compat_pf_resource_op resource_op;
        struct compat_pf_symdata symdata;
        uint8_t pad[128];
    } u;
};
typedef struct compat_platform_op compat_platform_op_t;
DEFINE_COMPAT_HANDLE(compat_platform_op_t);
#pragma pack()
#endif /* _COMPAT_PLATFORM_H */
