
#define XLAT_pct_register(_d_, _s_) do { \
    (_d_)->descriptor = (_s_)->descriptor; \
    (_d_)->length = (_s_)->length; \
    (_d_)->space_id = (_s_)->space_id; \
    (_d_)->bit_width = (_s_)->bit_width; \
    (_d_)->bit_offset = (_s_)->bit_offset; \
    (_d_)->reserved = (_s_)->reserved; \
    (_d_)->address = (_s_)->address; \
} while (0)

#define XLAT_power_register(_d_, _s_) do { \
    (_d_)->space_id = (_s_)->space_id; \
    (_d_)->bit_width = (_s_)->bit_width; \
    (_d_)->bit_offset = (_s_)->bit_offset; \
    (_d_)->access_size = (_s_)->access_size; \
    (_d_)->address = (_s_)->address; \
} while (0)

#define CHECK_processor_csd \
    CHECK_SIZE_(struct, processor_csd); \
    CHECK_FIELD_(struct, processor_csd, domain); \
    CHECK_FIELD_(struct, processor_csd, coord_type); \
    CHECK_FIELD_(struct, processor_csd, num)

#define XLAT_processor_cx(_d_, _s_) do { \
    XLAT_power_register(&(_d_)->reg, &(_s_)->reg); \
    (_d_)->type = (_s_)->type; \
    (_d_)->latency = (_s_)->latency; \
    (_d_)->power = (_s_)->power; \
    (_d_)->dpcnt = (_s_)->dpcnt; \
    XLAT_processor_cx_HNDL_dp(_d_, _s_); \
} while (0)

#define XLAT_processor_flags(_d_, _s_) do { \
    (_d_)->bm_control = (_s_)->bm_control; \
    (_d_)->bm_check = (_s_)->bm_check; \
    (_d_)->has_cst = (_s_)->has_cst; \
    (_d_)->power_setup_done = (_s_)->power_setup_done; \
    (_d_)->bm_rld_set = (_s_)->bm_rld_set; \
} while (0)

#define XLAT_processor_performance(_d_, _s_) do { \
    (_d_)->flags = (_s_)->flags; \
    (_d_)->platform_limit = (_s_)->platform_limit; \
    XLAT_pct_register(&(_d_)->control_register, &(_s_)->control_register); \
    XLAT_pct_register(&(_d_)->status_register, &(_s_)->status_register); \
    (_d_)->state_count = (_s_)->state_count; \
    XLAT_processor_performance_HNDL_states(_d_, _s_); \
    XLAT_psd_package(&(_d_)->domain_info, &(_s_)->domain_info); \
    (_d_)->shared_type = (_s_)->shared_type; \
} while (0)

#define XLAT_processor_power(_d_, _s_) do { \
    (_d_)->count = (_s_)->count; \
    XLAT_processor_flags(&(_d_)->flags, &(_s_)->flags); \
    XLAT_processor_power_HNDL_states(_d_, _s_); \
} while (0)

#define CHECK_processor_px \
    CHECK_SIZE_(struct, processor_px); \
    CHECK_FIELD_(struct, processor_px, core_frequency); \
    CHECK_FIELD_(struct, processor_px, power); \
    CHECK_FIELD_(struct, processor_px, transition_latency); \
    CHECK_FIELD_(struct, processor_px, bus_master_latency); \
    CHECK_FIELD_(struct, processor_px, control); \
    CHECK_FIELD_(struct, processor_px, status)

#define XLAT_psd_package(_d_, _s_) do { \
    (_d_)->num_entries = (_s_)->num_entries; \
    (_d_)->revision = (_s_)->revision; \
    (_d_)->domain = (_s_)->domain; \
    (_d_)->coord_type = (_s_)->coord_type; \
    (_d_)->num_processors = (_s_)->num_processors; \
} while (0)

#define CHECK_pf_enter_acpi_sleep \
    CHECK_SIZE_(struct, pf_enter_acpi_sleep); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, val_a); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, val_b); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, sleep_state); \
    CHECK_FIELD_(struct, pf_enter_acpi_sleep, flags)

#define XLAT_pf_symdata(_d_, _s_) do { \
    (_d_)->namelen = (_s_)->namelen; \
    (_d_)->symnum = (_s_)->symnum; \
    XLAT_pf_symdata_HNDL_name(_d_, _s_); \
    (_d_)->address = (_s_)->address; \
    (_d_)->type = (_s_)->type; \
} while (0)

#define CHECK_pf_pcpuinfo \
    CHECK_SIZE_(struct, pf_pcpuinfo); \
    CHECK_FIELD_(struct, pf_pcpuinfo, xen_cpuid); \
    CHECK_FIELD_(struct, pf_pcpuinfo, max_present); \
    CHECK_FIELD_(struct, pf_pcpuinfo, flags); \
    CHECK_FIELD_(struct, pf_pcpuinfo, apic_id); \
    CHECK_FIELD_(struct, pf_pcpuinfo, acpi_id)

#define CHECK_pf_pcpu_version \
    CHECK_SIZE_(struct, pf_pcpu_version); \
    CHECK_FIELD_(struct, pf_pcpu_version, xen_cpuid); \
    CHECK_FIELD_(struct, pf_pcpu_version, max_present); \
    CHECK_FIELD_(struct, pf_pcpu_version, vendor_id); \
    CHECK_FIELD_(struct, pf_pcpu_version, family); \
    CHECK_FIELD_(struct, pf_pcpu_version, model); \
    CHECK_FIELD_(struct, pf_pcpu_version, stepping)

#define CHECK_pf_resource_entry \
    CHECK_SIZE_(struct, pf_resource_entry); \
    CHECK_SUBFIELD_1_(struct, pf_resource_entry, u, cmd); \
    CHECK_SUBFIELD_1_(struct, pf_resource_entry, u, ret); \
    CHECK_FIELD_(struct, pf_resource_entry, rsvd); \
    CHECK_FIELD_(struct, pf_resource_entry, idx); \
    CHECK_FIELD_(struct, pf_resource_entry, val)
