
/* ACPI_EXTRACT_ALL_CODE ssdm_mem_aml */

DefinitionBlock ("ssdt-mem.aml", "SSDT", 0x02, "BXPC", "CSSDT", 0x1)
{
    External(\_SB.PCI0.MHPD.MCRS, MethodObj)
    External(\_SB.PCI0.MHPD.MRST, MethodObj)
    External(\_SB.PCI0.MHPD.MOST, MethodObj)
    External(\_SB.PCI0.MHPD.MPXM, MethodObj)
    Scope(\_SB) {
        
/* ACPI_EXTRACT_DEVICE_START ssdt_mem_start */

        
/* ACPI_EXTRACT_DEVICE_END ssdt_mem_end */

        
/* ACPI_EXTRACT_DEVICE_STRING ssdt_mem_name */

        Device(MPAA) {
            
/* ACPI_EXTRACT_NAME_STRING ssdt_mem_id */

            Name(_UID, "0xAA")
            Name(_HID, EISAID("PNP0C80"))
            Method(_CRS, 0) {
                Return(\_SB.PCI0.MHPD.MCRS(_UID))
            }
            Method(_STA, 0) {
                Return(\_SB.PCI0.MHPD.MRST(_UID))
            }
            Method(_PXM, 0) {
                Return(\_SB.PCI0.MHPD.MPXM(_UID))
            }
            Method(_OST, 3) {
                \_SB.PCI0.MHPD.MOST(_UID, Arg0, Arg1, Arg2)
            }
        }
    }
}
