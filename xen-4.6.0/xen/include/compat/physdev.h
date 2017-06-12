#ifndef _COMPAT_PHYSDEV_H
#define _COMPAT_PHYSDEV_H
#include <xen/compat.h>
#include <public/physdev.h>
#pragma pack(4)
#include "xen.h"
#pragma pack(4)
struct compat_physdev_eoi {

    uint32_t irq;
};
typedef struct physdev_eoi physdev_eoi_compat_t;
DEFINE_COMPAT_HANDLE(physdev_eoi_compat_t);
struct compat_physdev_pirq_eoi_gmfn {

    compat_pfn_t gmfn;
};
typedef struct compat_physdev_pirq_eoi_gmfn physdev_pirq_eoi_gmfn_compat_t;
DEFINE_COMPAT_HANDLE(physdev_pirq_eoi_gmfn_compat_t);

struct compat_physdev_irq_status_query {

    uint32_t irq;

    uint32_t flags;
};
typedef struct physdev_irq_status_query physdev_irq_status_query_compat_t;
DEFINE_COMPAT_HANDLE(physdev_irq_status_query_compat_t);
struct compat_physdev_set_iopl {

    uint32_t iopl;
};
typedef struct physdev_set_iopl physdev_set_iopl_compat_t;
DEFINE_COMPAT_HANDLE(physdev_set_iopl_compat_t);

struct compat_physdev_set_iobitmap {

    COMPAT_HANDLE(uint8) bitmap;

    uint32_t nr_ports;
};
typedef struct compat_physdev_set_iobitmap physdev_set_iobitmap_compat_t;
DEFINE_COMPAT_HANDLE(physdev_set_iobitmap_compat_t);

struct compat_physdev_apic {

    unsigned int apic_physbase;
    uint32_t reg;

    uint32_t value;
};
typedef struct compat_physdev_apic physdev_apic_compat_t;
DEFINE_COMPAT_HANDLE(physdev_apic_compat_t);

struct compat_physdev_irq {

    uint32_t irq;

    uint32_t vector;
};
typedef struct physdev_irq physdev_irq_compat_t;
DEFINE_COMPAT_HANDLE(physdev_irq_compat_t);
struct compat_physdev_map_pirq {
    domid_compat_t domid;

    int type;

    int index;

    int pirq;

    int bus;

    int devfn;

    int entry_nr;

    uint64_t table_base;
};
typedef struct compat_physdev_map_pirq physdev_map_pirq_compat_t;
DEFINE_COMPAT_HANDLE(physdev_map_pirq_compat_t);

struct compat_physdev_unmap_pirq {
    domid_compat_t domid;

    int pirq;
};

typedef struct physdev_unmap_pirq physdev_unmap_pirq_compat_t;
DEFINE_COMPAT_HANDLE(physdev_unmap_pirq_compat_t);

struct compat_physdev_manage_pci {

    uint8_t bus;
    uint8_t devfn;
};

typedef struct physdev_manage_pci physdev_manage_pci_compat_t;
DEFINE_COMPAT_HANDLE(physdev_manage_pci_compat_t);

struct compat_physdev_restore_msi {

    uint8_t bus;
    uint8_t devfn;
};
typedef struct physdev_restore_msi physdev_restore_msi_compat_t;
DEFINE_COMPAT_HANDLE(physdev_restore_msi_compat_t);

struct compat_physdev_manage_pci_ext {

    uint8_t bus;
    uint8_t devfn;
    unsigned is_extfn;
    unsigned is_virtfn;
    struct {
        uint8_t bus;
        uint8_t devfn;
    } physfn;
};

typedef struct physdev_manage_pci_ext physdev_manage_pci_ext_compat_t;
DEFINE_COMPAT_HANDLE(physdev_manage_pci_ext_compat_t);

struct compat_physdev_op {
    uint32_t cmd;
    union {
        struct physdev_irq_status_query irq_status_query;
        struct physdev_set_iopl set_iopl;
        struct compat_physdev_set_iobitmap set_iobitmap;
        struct compat_physdev_apic apic_op;
        struct physdev_irq irq_op;
    } u;
};
typedef struct compat_physdev_op physdev_op_compat_t;
DEFINE_COMPAT_HANDLE(physdev_op_compat_t);

struct compat_physdev_setup_gsi {
    int gsi;

    uint8_t triggering;

    uint8_t polarity;

};

typedef struct physdev_setup_gsi physdev_setup_gsi_compat_t;
DEFINE_COMPAT_HANDLE(physdev_setup_gsi_compat_t);

struct compat_physdev_get_free_pirq {

    int type;

    uint32_t pirq;
};

typedef struct physdev_get_free_pirq physdev_get_free_pirq_compat_t;
DEFINE_COMPAT_HANDLE(physdev_get_free_pirq_compat_t);

struct compat_physdev_pci_mmcfg_reserved {
    uint64_t address;
    uint16_t segment;
    uint8_t start_bus;
    uint8_t end_bus;
    uint32_t flags;
};
typedef struct physdev_pci_mmcfg_reserved physdev_pci_mmcfg_reserved_compat_t;
DEFINE_COMPAT_HANDLE(physdev_pci_mmcfg_reserved_compat_t);

struct compat_physdev_pci_device_add {

    uint16_t seg;
    uint8_t bus;
    uint8_t devfn;
    uint32_t flags;
    struct {
        uint8_t bus;
        uint8_t devfn;
    } physfn;

    uint32_t optarr[];

};
typedef struct physdev_pci_device_add physdev_pci_device_add_compat_t;
DEFINE_COMPAT_HANDLE(physdev_pci_device_add_compat_t);
struct compat_physdev_pci_device {

    uint16_t seg;
    uint8_t bus;
    uint8_t devfn;
};
typedef struct physdev_pci_device physdev_pci_device_compat_t;
DEFINE_COMPAT_HANDLE(physdev_pci_device_compat_t);
struct compat_physdev_dbgp_op {

    uint8_t op;
    uint8_t bus;
    union {
        struct physdev_pci_device pci;
    } u;
};
typedef struct compat_physdev_dbgp_op physdev_dbgp_op_compat_t;
DEFINE_COMPAT_HANDLE(physdev_dbgp_op_compat_t);
#pragma pack()
#endif /* _COMPAT_PHYSDEV_H */
