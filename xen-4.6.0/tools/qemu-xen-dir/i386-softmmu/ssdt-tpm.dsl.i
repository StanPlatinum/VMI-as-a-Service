
/* ACPI_EXTRACT_ALL_CODE ssdt_tpm_aml */

DefinitionBlock (
    "ssdt-tpm.aml",
    "SSDT",
    0x01,
    "BXPC",
    "BXSSDT",
    0x1
    )
{
    Scope(\_SB) {
        Device (TPM) {
            Name (_HID, EisaID ("PNP0C31"))
            Name (_CRS, ResourceTemplate ()
            {
                Memory32Fixed (ReadWrite, 0xFED40000, 0x5000)
            })
            Method (_STA, 0, NotSerialized) {
                Return (0x0F)
            }
        }
    }
}
