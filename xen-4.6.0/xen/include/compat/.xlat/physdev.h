
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
