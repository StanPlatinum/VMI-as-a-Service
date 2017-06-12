/******************************************************************************
 * DSDT for Xen with Qemu device model
 *
 * Copyright (c) 2004, Intel Corporation.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 2, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; If not, see <http://www.gnu.org/licenses/>.
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "Xen", "HVM", 0)
{
    Name (\PMBS, 0x0C00)
    Name (\PMLN, 0x08)
    Name (\IOB1, 0x00)
    Name (\IOL1, 0x00)
    Name (\APCB, 0xFEC00000)
    Name (\APCL, 0x00010000)
    Name (\PUID, 0x00)

    /* _S3 and _S4 are in separate SSDTs */
    Name (\_S5, Package (0x04)
    {
        0x00,  /* PM1a_CNT.SLP_TYP */
        0x00,  /* PM1b_CNT.SLP_TYP */
        0x00,  /* reserved */
        0x00   /* reserved */
    })

    Name(PICD, 0)
    Method(_PIC, 1)
    {
        Store(Arg0, PICD) 
    }

    Scope (\_SB)
    {
       /* ACPI_INFO_PHYSICAL_ADDRESS == 0xFC000000 */
       OperationRegion(BIOS, SystemMemory, 0xFC000000, 40)
       Field(BIOS, ByteAcc, NoLock, Preserve) {
           UAR1, 1,
           UAR2, 1,
           LTP1, 1,
           HPET, 1,
           Offset(4),
           PMIN, 32,
           PLEN, 32,
           MSUA, 32, /* MADT checksum address */
           MAPA, 32, /* MADT LAPIC0 address */
           VGIA, 32, /* VM generation id address */
           LMIN, 32,
           HMIN, 32,
           LLEN, 32,
           HLEN, 32
       }

        /* Fix HCT test for 0x400 pci memory:
         * - need to report low 640 MB mem as motherboard resource
         */
       Device(MEM0)
       {
           Name(_HID, EISAID("PNP0C02"))
           Name(_CRS, ResourceTemplate() {
               QWordMemory(
                    ResourceConsumer, PosDecode, MinFixed,
                    MaxFixed, Cacheable, ReadWrite,
                    0x00000000,
                    0x00000000,
                    0x0009ffff,
                    0x00000000,
                    0x000a0000)
           })
       }

       Device (PCI0)
       {
           Name (_HID, EisaId ("PNP0A03"))
           Name (_UID, 0x00)
           Name (_ADR, 0x00)
           Name (_BBN, 0x00)

           /* Make cirrues VGA S3 suspend/resume work in Windows XP/2003 */
           Device (VGA)
           {
               Name (_ADR, 0x00020000)

               Method (_S1D, 0, NotSerialized)
               {
                   Return (0x00)
               }
               Method (_S2D, 0, NotSerialized)
               {
                   Return (0x00)
               }
               Method (_S3D, 0, NotSerialized)
               {
                   Return (0x00)
               }
           }

           Method (_CRS, 0, NotSerialized)
           {
               Store (ResourceTemplate ()
               {
                   /* bus number is from 0 - 255*/
                   WordBusNumber(
                        ResourceProducer, MinFixed, MaxFixed, SubDecode,
                        0x0000,
                        0x0000,
                        0x00FF,
                        0x0000,
                        0x0100)
                    IO (Decode16, 0x0CF8, 0x0CF8, 0x01, 0x08)
                    WordIO(
                        ResourceProducer, MinFixed, MaxFixed, PosDecode,
                        EntireRange,
                        0x0000,
                        0x0000,
                        0x0CF7,
                        0x0000,
                        0x0CF8)
                    WordIO(
                        ResourceProducer, MinFixed, MaxFixed, PosDecode,
                        EntireRange,
                        0x0000,
                        0x0D00,
                        0xFFFF,
                        0x0000,
                        0xF300)

                    /* reserve memory for pci devices */
                    DWordMemory(
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        WriteCombining, ReadWrite,
                        0x00000000,
                        0x000A0000,
                        0x000BFFFF,
                        0x00000000,
                        0x00020000)

                    DWordMemory(
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x00000000,
                        0xF0000000,
                        0xF4FFFFFF,
                        0x00000000,
                        0x05000000,
                        ,, _Y01)

                    QWordMemory (
                        ResourceProducer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x0000000000000000,
                        0x0000000FFFFFFFF0,
                        0x0000000FFFFFFFFF,
                        0x0000000000000000,
                        0x0000000000000010,
                        ,, _Y02)

                }, Local1)

                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._MIN, MMIN)
                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._MAX, MMAX)
                CreateDWordField(Local1, \_SB.PCI0._CRS._Y01._LEN, MLEN)

                Store(\_SB.PMIN, MMIN)
                Store(\_SB.PLEN, MLEN)
                Add(MMIN, MLEN, MMAX)
                Subtract(MMAX, One, MMAX)

                /*
                 * WinXP / Win2K3 blue-screen for operations on 64-bit values.
                 * Therefore we need to split the 64-bit calculations needed
                 * here, but different iasl versions evaluate name references
                 * to integers differently:
                 * Year (approximate)          2006    2008    2012
                 * \_SB.PCI0._CRS._Y02         zero   valid   valid
                 * \_SB.PCI0._CRS._Y02._MIN   valid   valid    huge
                 */
                If(LEqual(Zero, \_SB.PCI0._CRS._Y02)) {
                    Subtract(\_SB.PCI0._CRS._Y02._MIN, 14, Local0)
                } Else {
                    Store(\_SB.PCI0._CRS._Y02, Local0)
                }
                CreateDWordField(Local1, Add(Local0, 14), MINL)
                CreateDWordField(Local1, Add(Local0, 18), MINH)
                CreateDWordField(Local1, Add(Local0, 22), MAXL)
                CreateDWordField(Local1, Add(Local0, 26), MAXH)
                CreateDWordField(Local1, Add(Local0, 38), LENL)
                CreateDWordField(Local1, Add(Local0, 42), LENH)

                Store(\_SB.LMIN, MINL)
                Store(\_SB.HMIN, MINH)
                Store(\_SB.LLEN, LENL)
                Store(\_SB.HLEN, LENH)
                Add(MINL, LENL, MAXL)
                Add(MINH, LENH, MAXH)
                If(LLess(MAXL, MINL)) {
                    Add(MAXH, One, MAXH)
                }
                If(LOr(MINH, LENL)) {
                    If(LEqual(MAXL, 0)) {
                        Subtract(MAXH, One, MAXH)
                    }
                    Subtract(MAXL, One, MAXL)
                }

                Return (Local1)
            }

            Device(HPET) {
                Name(_HID,  EISAID("PNP0103"))
                Name(_UID, 0)
                Method (_STA, 0, NotSerialized) {
                    If(LEqual(\_SB.HPET, 0)) {
                        Return(0x00)
                    } Else {
                        Return(0x0F)
                    }
                }
                Name(_CRS, ResourceTemplate() {
                    DWordMemory(
                        ResourceConsumer, PosDecode, MinFixed, MaxFixed,
                        NonCacheable, ReadWrite,
                        0x00000000,
                        0xFED00000,
                        0xFED003FF,
                        0x00000000,
                        0x00000400 /* 1K memory: FED00000 - FED003FF */
                    )
                })
            }

            Device (ISA)
            {
                Name (_ADR, 0x00010000) /* device 1, fn 0 */

                OperationRegion(PIRQ, PCI_Config, 0x60, 0x4)
                Scope(\) {
                    Field (\_SB.PCI0.ISA.PIRQ, ByteAcc, NoLock, Preserve) {
                        PIRA, 8,
                        PIRB, 8,
                        PIRC, 8,
                        PIRD, 8
                    }
                }
                Device (SYSR)
                {
                    Name (_HID, EisaId ("PNP0C02"))
                    Name (_UID, 0x01)
                    Name (CRS, ResourceTemplate ()
                    {
                        /* TODO: list hidden resources */
                        IO (Decode16, 0x0010, 0x0010, 0x00, 0x10)
                        IO (Decode16, 0x0022, 0x0022, 0x00, 0x0C)
                        IO (Decode16, 0x0030, 0x0030, 0x00, 0x10)
                        IO (Decode16, 0x0044, 0x0044, 0x00, 0x1C)
                        IO (Decode16, 0x0062, 0x0062, 0x00, 0x02)
                        IO (Decode16, 0x0065, 0x0065, 0x00, 0x0B)
                        IO (Decode16, 0x0072, 0x0072, 0x00, 0x0E)
                        IO (Decode16, 0x0080, 0x0080, 0x00, 0x01)
                        IO (Decode16, 0x0084, 0x0084, 0x00, 0x03)
                        IO (Decode16, 0x0088, 0x0088, 0x00, 0x01)
                        IO (Decode16, 0x008C, 0x008C, 0x00, 0x03)
                        IO (Decode16, 0x0090, 0x0090, 0x00, 0x10)
                        IO (Decode16, 0x00A2, 0x00A2, 0x00, 0x1C)
                        IO (Decode16, 0x00E0, 0x00E0, 0x00, 0x10)
                        IO (Decode16, 0x08A0, 0x08A0, 0x00, 0x04)
                        IO (Decode16, 0x0CC0, 0x0CC0, 0x00, 0x10)
                        IO (Decode16, 0x04D0, 0x04D0, 0x00, 0x02)
                    })
                    Method (_CRS, 0, NotSerialized)
                    {
                        Return (CRS)
                    }
                }

                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0020, 0x0020, 0x01, 0x02)
                        IO (Decode16, 0x00A0, 0x00A0, 0x01, 0x02)
                        IRQNoFlags () {2}
                    })
                }

                Device (DMA0)
                {
                    Name (_HID, EisaId ("PNP0200"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        DMA (Compatibility, BusMaster, Transfer8) {4}
                        IO (Decode16, 0x0000, 0x0000, 0x00, 0x10)
                        IO (Decode16, 0x0081, 0x0081, 0x00, 0x03)
                        IO (Decode16, 0x0087, 0x0087, 0x00, 0x01)
                        IO (Decode16, 0x0089, 0x0089, 0x00, 0x03)
                        IO (Decode16, 0x008F, 0x008F, 0x00, 0x01)
                        IO (Decode16, 0x00C0, 0x00C0, 0x00, 0x20)
                        IO (Decode16, 0x0480, 0x0480, 0x00, 0x10)
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0040, 0x0040, 0x00, 0x04)
                        IRQNoFlags () {0}
                    })
                }

                Device (RTC)
                {
                    Name (_HID, EisaId ("PNP0B00"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0070, 0x0070, 0x00, 0x02)
                        IRQNoFlags () {8}
                    })
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800"))
                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0061, 0x0061, 0x00, 0x01)
                    })
                }

                Device (PS2M)
                {
                    Name (_HID, EisaId ("PNP0F13"))
                    Name (_CID, 0x130FD041)
                    Method (_STA, 0, NotSerialized)
                    {
                        Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IRQNoFlags () {12}
                    })
                }

                Device (PS2K)
                {
                    Name (_HID, EisaId ("PNP0303"))
                    Name (_CID, 0x0B03D041)
                    Method (_STA, 0, NotSerialized)
                    {
                        Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x0060, 0x0060, 0x00, 0x01)
                        IO (Decode16, 0x0064, 0x0064, 0x00, 0x01)
                        IRQNoFlags () {1}
                    })
                }

                Device (FDC0)
                {
                    Name (_HID, EisaId ("PNP0700"))
                    Method (_STA, 0, NotSerialized)
                    {
                          Return (0x0F)
                    }

                    Name (_CRS, ResourceTemplate ()
                    {
                        IO (Decode16, 0x03F0, 0x03F0, 0x01, 0x06)
                        IO (Decode16, 0x03F7, 0x03F7, 0x01, 0x01)
                        IRQNoFlags () {6}
                        DMA (Compatibility, NotBusMaster, Transfer8) {2}
                    })
                }

                Device (UAR1)
                {
                    Name (_HID, EisaId ("PNP0501"))
                    Name (_UID, 0x01)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.UAR1, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x03F8, 0x03F8, 8, 8)
                        IRQNoFlags () {4}
                    })
                }

                Device (UAR2)
                {
                    Name (_HID, EisaId ("PNP0501"))
                    Name (_UID, 0x02)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.UAR2, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x02F8, 0x02F8, 8, 8)
                        IRQNoFlags () {3}
                    })
                }

                Device (LTP1)
                {
                    Name (_HID, EisaId ("PNP0400"))
                    Name (_UID, 0x02)
                    Method (_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.LTP1, 0)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }

                    Name (_CRS, ResourceTemplate()
                    {
                        IO (Decode16, 0x0378, 0x0378, 0x08, 0x08)
                        IRQNoFlags () {7}
                    })
                }

                Device(VGID) {
                    Name(_HID, EisaId ("XEN0000"))
                    Name(_UID, 0x00)
                    Name(_CID, "VM_Gen_Counter")
                    Name(_DDN, "VM_Gen_Counter")
                    Method(_STA, 0, NotSerialized)
                    {
                        If(LEqual(\_SB.VGIA, 0x00000000)) {
                            Return(0x00)
                        } Else {
                            Return(0x0F)
                        }
                    }
                    Name(PKG, Package ()
                    {
                        0x00000000,
                        0x00000000
                    })
                    Method(ADDR, 0, NotSerialized)
                    {
                        Store(\_SB.VGIA, Index(PKG, 0))
                        Return(PKG)
                    }
                }
            }
        }
    }
    Scope ( \_SB ) {
        OperationRegion ( MSUM, SystemMemory, \_SB.MSUA, 1 )
        Field ( MSUM, ByteAcc, NoLock, Preserve ) {
            MSU, 8
        }
        Processor ( PR00, 0, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 0), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR01, 1, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 8), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR02, 2, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 16), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR03, 3, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 24), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR04, 4, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 32), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR05, 5, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 40), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR06, 6, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 48), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR07, 7, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 56), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR08, 8, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 64), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR09, 9, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 72), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0A, 10, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 80), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0B, 11, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 88), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0C, 12, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 96), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0D, 13, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 104), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0E, 14, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 112), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR0F, 15, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 120), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR10, 16, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 128), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR11, 17, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 136), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR12, 18, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 144), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR13, 19, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 152), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR14, 20, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 160), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR15, 21, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 168), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR16, 22, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 176), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR17, 23, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 184), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR18, 24, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 192), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR19, 25, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 200), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1A, 26, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 208), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1B, 27, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 216), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1C, 28, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 224), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1D, 29, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 232), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1E, 30, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 240), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR1F, 31, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 248), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR20, 32, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 256), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR21, 33, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 264), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR22, 34, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 272), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR23, 35, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 280), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR24, 36, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 288), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR25, 37, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 296), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR26, 38, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 304), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR27, 39, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 312), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR28, 40, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 320), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR29, 41, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 328), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2A, 42, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 336), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2B, 43, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 344), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2C, 44, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 352), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2D, 45, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 360), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2E, 46, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 368), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR2F, 47, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 376), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR30, 48, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 384), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR31, 49, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 392), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR32, 50, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 400), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR33, 51, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 408), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR34, 52, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 416), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR35, 53, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 424), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR36, 54, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 432), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR37, 55, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 440), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR38, 56, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 448), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR39, 57, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 456), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3A, 58, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 464), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3B, 59, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 472), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3C, 60, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 480), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3D, 61, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 488), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3E, 62, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 496), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR3F, 63, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 504), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR40, 64, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 512), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR41, 65, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 520), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR42, 66, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 528), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR43, 67, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 536), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR44, 68, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 544), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR45, 69, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 552), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR46, 70, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 560), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR47, 71, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 568), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR48, 72, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 576), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR49, 73, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 584), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4A, 74, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 592), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4B, 75, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 600), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4C, 76, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 608), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4D, 77, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 616), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4E, 78, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 624), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR4F, 79, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 632), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR50, 80, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 640), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR51, 81, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 648), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR52, 82, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 656), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR53, 83, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 664), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR54, 84, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 672), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR55, 85, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 680), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR56, 86, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 688), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR57, 87, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 696), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR58, 88, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 704), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR59, 89, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 712), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5A, 90, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 720), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5B, 91, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 728), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5C, 92, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 736), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5D, 93, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 744), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5E, 94, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 752), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR5F, 95, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 760), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR60, 96, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 768), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR61, 97, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 776), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR62, 98, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 784), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR63, 99, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 792), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR64, 100, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 800), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR65, 101, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 808), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR66, 102, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 816), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR67, 103, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 824), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR68, 104, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 832), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR69, 105, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 840), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6A, 106, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 848), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6B, 107, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 856), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6C, 108, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 864), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6D, 109, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 872), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6E, 110, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 880), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR6F, 111, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 888), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR70, 112, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 896), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR71, 113, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 904), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR72, 114, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 912), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR73, 115, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 920), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR74, 116, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 928), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR75, 117, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 936), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR76, 118, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 944), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR77, 119, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 952), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR78, 120, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 960), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR79, 121, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 968), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7A, 122, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 976), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7B, 123, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 984), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7C, 124, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 992), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7D, 125, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1000), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7E, 126, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1008), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        Processor ( PR7F, 127, 0x0000b010, 0x06 ) {
            Name ( _HID, "ACPI0007" )
            OperationRegion ( MATR, SystemMemory, Add(\_SB.MAPA, 1016), 8 )
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                MAT, 64
            }
            Field ( MATR, ByteAcc, NoLock, Preserve ) {
                Offset(4),
                FLG, 1
            }
            Method ( _MAT, 0 ) {
                Return ( ToBuffer(MAT) )
            }
            Method ( _STA ) {
                If ( FLG ) {
                    Return ( 0xF )
                }
                Else {
                    Return ( 0x0 )
                }
            }
            Method ( _EJ0, 1, NotSerialized ) {
                Sleep ( 0xC8 )
            }
        }
        OperationRegion ( PRST, SystemIO, 0xaf00, 32 )
        Field ( PRST, ByteAcc, NoLock, Preserve ) {
            PRS, 128
        }
        Method ( PRSC, 0 ) {
            Store ( ToBuffer(PRS), Local0 )
            Store ( DerefOf(Index(Local0, 0)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR00.FLG) ) {
                Store ( Local2, \_SB.PR00.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR00, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR00, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR01.FLG) ) {
                Store ( Local2, \_SB.PR01.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR01, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR01, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR02.FLG) ) {
                Store ( Local2, \_SB.PR02.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR02, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR02, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR03.FLG) ) {
                Store ( Local2, \_SB.PR03.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR03, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR03, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR04.FLG) ) {
                Store ( Local2, \_SB.PR04.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR04, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR04, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR05.FLG) ) {
                Store ( Local2, \_SB.PR05.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR05, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR05, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR06.FLG) ) {
                Store ( Local2, \_SB.PR06.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR06, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR06, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR07.FLG) ) {
                Store ( Local2, \_SB.PR07.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR07, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR07, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 1)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR08.FLG) ) {
                Store ( Local2, \_SB.PR08.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR08, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR08, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR09.FLG) ) {
                Store ( Local2, \_SB.PR09.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR09, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR09, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0A.FLG) ) {
                Store ( Local2, \_SB.PR0A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0B.FLG) ) {
                Store ( Local2, \_SB.PR0B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0C.FLG) ) {
                Store ( Local2, \_SB.PR0C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0D.FLG) ) {
                Store ( Local2, \_SB.PR0D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0E.FLG) ) {
                Store ( Local2, \_SB.PR0E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR0F.FLG) ) {
                Store ( Local2, \_SB.PR0F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR0F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR0F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 2)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR10.FLG) ) {
                Store ( Local2, \_SB.PR10.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR10, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR10, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR11.FLG) ) {
                Store ( Local2, \_SB.PR11.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR11, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR11, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR12.FLG) ) {
                Store ( Local2, \_SB.PR12.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR12, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR12, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR13.FLG) ) {
                Store ( Local2, \_SB.PR13.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR13, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR13, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR14.FLG) ) {
                Store ( Local2, \_SB.PR14.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR14, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR14, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR15.FLG) ) {
                Store ( Local2, \_SB.PR15.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR15, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR15, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR16.FLG) ) {
                Store ( Local2, \_SB.PR16.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR16, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR16, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR17.FLG) ) {
                Store ( Local2, \_SB.PR17.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR17, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR17, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 3)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR18.FLG) ) {
                Store ( Local2, \_SB.PR18.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR18, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR18, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR19.FLG) ) {
                Store ( Local2, \_SB.PR19.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR19, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR19, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1A.FLG) ) {
                Store ( Local2, \_SB.PR1A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1B.FLG) ) {
                Store ( Local2, \_SB.PR1B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1C.FLG) ) {
                Store ( Local2, \_SB.PR1C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1D.FLG) ) {
                Store ( Local2, \_SB.PR1D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1E.FLG) ) {
                Store ( Local2, \_SB.PR1E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR1F.FLG) ) {
                Store ( Local2, \_SB.PR1F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR1F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR1F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 4)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR20.FLG) ) {
                Store ( Local2, \_SB.PR20.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR20, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR20, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR21.FLG) ) {
                Store ( Local2, \_SB.PR21.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR21, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR21, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR22.FLG) ) {
                Store ( Local2, \_SB.PR22.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR22, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR22, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR23.FLG) ) {
                Store ( Local2, \_SB.PR23.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR23, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR23, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR24.FLG) ) {
                Store ( Local2, \_SB.PR24.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR24, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR24, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR25.FLG) ) {
                Store ( Local2, \_SB.PR25.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR25, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR25, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR26.FLG) ) {
                Store ( Local2, \_SB.PR26.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR26, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR26, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR27.FLG) ) {
                Store ( Local2, \_SB.PR27.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR27, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR27, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 5)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR28.FLG) ) {
                Store ( Local2, \_SB.PR28.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR28, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR28, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR29.FLG) ) {
                Store ( Local2, \_SB.PR29.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR29, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR29, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2A.FLG) ) {
                Store ( Local2, \_SB.PR2A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2B.FLG) ) {
                Store ( Local2, \_SB.PR2B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2C.FLG) ) {
                Store ( Local2, \_SB.PR2C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2D.FLG) ) {
                Store ( Local2, \_SB.PR2D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2E.FLG) ) {
                Store ( Local2, \_SB.PR2E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR2F.FLG) ) {
                Store ( Local2, \_SB.PR2F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR2F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR2F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 6)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR30.FLG) ) {
                Store ( Local2, \_SB.PR30.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR30, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR30, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR31.FLG) ) {
                Store ( Local2, \_SB.PR31.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR31, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR31, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR32.FLG) ) {
                Store ( Local2, \_SB.PR32.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR32, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR32, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR33.FLG) ) {
                Store ( Local2, \_SB.PR33.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR33, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR33, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR34.FLG) ) {
                Store ( Local2, \_SB.PR34.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR34, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR34, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR35.FLG) ) {
                Store ( Local2, \_SB.PR35.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR35, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR35, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR36.FLG) ) {
                Store ( Local2, \_SB.PR36.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR36, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR36, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR37.FLG) ) {
                Store ( Local2, \_SB.PR37.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR37, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR37, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 7)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR38.FLG) ) {
                Store ( Local2, \_SB.PR38.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR38, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR38, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR39.FLG) ) {
                Store ( Local2, \_SB.PR39.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR39, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR39, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3A.FLG) ) {
                Store ( Local2, \_SB.PR3A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3B.FLG) ) {
                Store ( Local2, \_SB.PR3B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3C.FLG) ) {
                Store ( Local2, \_SB.PR3C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3D.FLG) ) {
                Store ( Local2, \_SB.PR3D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3E.FLG) ) {
                Store ( Local2, \_SB.PR3E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR3F.FLG) ) {
                Store ( Local2, \_SB.PR3F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR3F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR3F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 8)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR40.FLG) ) {
                Store ( Local2, \_SB.PR40.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR40, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR40, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR41.FLG) ) {
                Store ( Local2, \_SB.PR41.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR41, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR41, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR42.FLG) ) {
                Store ( Local2, \_SB.PR42.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR42, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR42, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR43.FLG) ) {
                Store ( Local2, \_SB.PR43.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR43, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR43, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR44.FLG) ) {
                Store ( Local2, \_SB.PR44.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR44, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR44, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR45.FLG) ) {
                Store ( Local2, \_SB.PR45.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR45, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR45, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR46.FLG) ) {
                Store ( Local2, \_SB.PR46.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR46, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR46, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR47.FLG) ) {
                Store ( Local2, \_SB.PR47.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR47, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR47, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 9)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR48.FLG) ) {
                Store ( Local2, \_SB.PR48.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR48, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR48, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR49.FLG) ) {
                Store ( Local2, \_SB.PR49.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR49, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR49, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4A.FLG) ) {
                Store ( Local2, \_SB.PR4A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4B.FLG) ) {
                Store ( Local2, \_SB.PR4B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4C.FLG) ) {
                Store ( Local2, \_SB.PR4C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4D.FLG) ) {
                Store ( Local2, \_SB.PR4D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4E.FLG) ) {
                Store ( Local2, \_SB.PR4E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR4F.FLG) ) {
                Store ( Local2, \_SB.PR4F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR4F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR4F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 10)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR50.FLG) ) {
                Store ( Local2, \_SB.PR50.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR50, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR50, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR51.FLG) ) {
                Store ( Local2, \_SB.PR51.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR51, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR51, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR52.FLG) ) {
                Store ( Local2, \_SB.PR52.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR52, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR52, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR53.FLG) ) {
                Store ( Local2, \_SB.PR53.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR53, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR53, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR54.FLG) ) {
                Store ( Local2, \_SB.PR54.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR54, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR54, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR55.FLG) ) {
                Store ( Local2, \_SB.PR55.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR55, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR55, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR56.FLG) ) {
                Store ( Local2, \_SB.PR56.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR56, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR56, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR57.FLG) ) {
                Store ( Local2, \_SB.PR57.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR57, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR57, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 11)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR58.FLG) ) {
                Store ( Local2, \_SB.PR58.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR58, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR58, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR59.FLG) ) {
                Store ( Local2, \_SB.PR59.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR59, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR59, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5A.FLG) ) {
                Store ( Local2, \_SB.PR5A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5B.FLG) ) {
                Store ( Local2, \_SB.PR5B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5C.FLG) ) {
                Store ( Local2, \_SB.PR5C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5D.FLG) ) {
                Store ( Local2, \_SB.PR5D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5E.FLG) ) {
                Store ( Local2, \_SB.PR5E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR5F.FLG) ) {
                Store ( Local2, \_SB.PR5F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR5F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR5F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 12)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR60.FLG) ) {
                Store ( Local2, \_SB.PR60.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR60, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR60, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR61.FLG) ) {
                Store ( Local2, \_SB.PR61.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR61, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR61, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR62.FLG) ) {
                Store ( Local2, \_SB.PR62.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR62, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR62, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR63.FLG) ) {
                Store ( Local2, \_SB.PR63.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR63, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR63, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR64.FLG) ) {
                Store ( Local2, \_SB.PR64.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR64, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR64, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR65.FLG) ) {
                Store ( Local2, \_SB.PR65.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR65, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR65, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR66.FLG) ) {
                Store ( Local2, \_SB.PR66.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR66, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR66, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR67.FLG) ) {
                Store ( Local2, \_SB.PR67.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR67, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR67, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 13)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR68.FLG) ) {
                Store ( Local2, \_SB.PR68.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR68, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR68, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR69.FLG) ) {
                Store ( Local2, \_SB.PR69.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR69, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR69, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6A.FLG) ) {
                Store ( Local2, \_SB.PR6A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6B.FLG) ) {
                Store ( Local2, \_SB.PR6B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6C.FLG) ) {
                Store ( Local2, \_SB.PR6C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6D.FLG) ) {
                Store ( Local2, \_SB.PR6D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6E.FLG) ) {
                Store ( Local2, \_SB.PR6E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR6F.FLG) ) {
                Store ( Local2, \_SB.PR6F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR6F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR6F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 14)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR70.FLG) ) {
                Store ( Local2, \_SB.PR70.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR70, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR70, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR71.FLG) ) {
                Store ( Local2, \_SB.PR71.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR71, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR71, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR72.FLG) ) {
                Store ( Local2, \_SB.PR72.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR72, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR72, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR73.FLG) ) {
                Store ( Local2, \_SB.PR73.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR73, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR73, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR74.FLG) ) {
                Store ( Local2, \_SB.PR74.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR74, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR74, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR75.FLG) ) {
                Store ( Local2, \_SB.PR75.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR75, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR75, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR76.FLG) ) {
                Store ( Local2, \_SB.PR76.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR76, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR76, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR77.FLG) ) {
                Store ( Local2, \_SB.PR77.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR77, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR77, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Store ( DerefOf(Index(Local0, 15)), Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR78.FLG) ) {
                Store ( Local2, \_SB.PR78.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR78, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR78, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR79.FLG) ) {
                Store ( Local2, \_SB.PR79.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR79, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR79, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7A.FLG) ) {
                Store ( Local2, \_SB.PR7A.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7A, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7A, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7B.FLG) ) {
                Store ( Local2, \_SB.PR7B.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7B, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7B, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7C.FLG) ) {
                Store ( Local2, \_SB.PR7C.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7C, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7C, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7D.FLG) ) {
                Store ( Local2, \_SB.PR7D.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7D, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7D, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7E.FLG) ) {
                Store ( Local2, \_SB.PR7E.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7E, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7E, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            ShiftRight ( Local1, 1, Local1 )
            And ( Local1, 1, Local2 )
            If ( LNotEqual(Local2, \_SB.PR7F.FLG) ) {
                Store ( Local2, \_SB.PR7F.FLG )
                If ( LEqual(Local2, 1) ) {
                    Notify ( PR7F, 1 )
                    Subtract ( \_SB.MSU, 1, \_SB.MSU )
                }
                Else {
                    Notify ( PR7F, 3 )
                    Add ( \_SB.MSU, 1, \_SB.MSU )
                }
            }
            Return ( One )
        }
    }
    Scope ( \_GPE ) {
        Method ( _L02 ) {
            \_SB.PRSC ()
        }
    }
    Scope ( \_SB.PCI0 ) {
        Device ( HP0 ) {
            Name ( _HID, EISAID("PNP0C02") )
            Name ( _CRS, ResourceTemplate() {  IO (Decode16, 0x10c0, 0x10c0, 0x00, 0x82)  IO (Decode16, 0xb044, 0xb044, 0x00, 0x04)} )
        }
        Name ( BUFA, ResourceTemplate() { IRQ(Level, ActiveLow, Shared) { 5, 10, 11 } } )
        Name ( BUFB, Buffer() { 0x23, 0x00, 0x00, 0x18, 0x79, 0 } )
        CreateWordField ( BUFB, 0x01, IRQV )
        Device ( LNKA ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 1 )
            Method ( _STA, 0 ) {
                If ( And(PIRA, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRA, 0x80, PIRA )
            }
            Method ( _CRS ) {
                And ( PIRA, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRA )
            }
        }
        Device ( LNKB ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 2 )
            Method ( _STA, 0 ) {
                If ( And(PIRB, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRB, 0x80, PIRB )
            }
            Method ( _CRS ) {
                And ( PIRB, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRB )
            }
        }
        Device ( LNKC ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 3 )
            Method ( _STA, 0 ) {
                If ( And(PIRC, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRC, 0x80, PIRC )
            }
            Method ( _CRS ) {
                And ( PIRC, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRC )
            }
        }
        Device ( LNKD ) {
            Name ( _HID,  EISAID("PNP0C0F") )
            Name ( _UID, 4 )
            Method ( _STA, 0 ) {
                If ( And(PIRD, 0x80) ) {
                    Return ( 0x09 )
                }
                Else {
                    Return ( 0x0B )
                }
            }
            Method ( _PRS ) {
                Return ( BUFA )
            }
            Method ( _DIS ) {
                Or ( PIRD, 0x80, PIRD )
            }
            Method ( _CRS ) {
                And ( PIRD, 0x0f, Local0 )
                ShiftLeft ( 0x1, Local0, IRQV )
                Return ( BUFB )
            }
            Method ( _SRS, 1 ) {
                CreateWordField ( ARG0, 0x01, IRQ1 )
                FindSetRightBit ( IRQ1, Local0 )
                Decrement ( Local0 )
                Store ( Local0, PIRD )
            }
        }
        Method ( _PRT, 0 ) {
            If ( PICD ) {
                Return ( PRTA )
            }
            Return ( PRTP )
        }
Name(PRTP, Package() {
Package(){0x0001ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0001ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0001ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0001ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0002ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0002ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0002ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0002ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0003ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0003ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0003ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0003ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0004ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0004ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0004ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0004ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0005ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0005ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0005ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0005ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0006ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0006ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0006ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0006ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0007ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0007ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0007ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0007ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0008ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0008ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0008ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0008ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0009ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0009ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0009ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0009ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x000affff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x000affff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x000affff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x000affff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x000bffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x000bffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x000bffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x000bffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x000cffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x000cffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x000cffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x000cffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x000dffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x000dffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x000dffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x000dffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x000effff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x000effff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x000effff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x000effff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x000fffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x000fffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x000fffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x000fffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0010ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0010ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0010ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0010ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0011ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0011ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0011ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0011ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0012ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0012ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0012ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0012ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0013ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0013ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0013ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0013ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0014ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0014ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0014ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0014ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0015ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0015ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0015ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0015ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x0016ffff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x0016ffff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x0016ffff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x0016ffff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x0017ffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x0017ffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x0017ffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x0017ffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x0018ffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x0018ffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x0018ffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x0018ffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x0019ffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x0019ffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x0019ffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x0019ffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x001affff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x001affff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x001affff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x001affff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x001bffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x001bffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x001bffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x001bffff, 3, \_SB.PCI0.LNKC, 0},
Package(){0x001cffff, 0, \_SB.PCI0.LNKA, 0},
Package(){0x001cffff, 1, \_SB.PCI0.LNKB, 0},
Package(){0x001cffff, 2, \_SB.PCI0.LNKC, 0},
Package(){0x001cffff, 3, \_SB.PCI0.LNKD, 0},
Package(){0x001dffff, 0, \_SB.PCI0.LNKB, 0},
Package(){0x001dffff, 1, \_SB.PCI0.LNKC, 0},
Package(){0x001dffff, 2, \_SB.PCI0.LNKD, 0},
Package(){0x001dffff, 3, \_SB.PCI0.LNKA, 0},
Package(){0x001effff, 0, \_SB.PCI0.LNKC, 0},
Package(){0x001effff, 1, \_SB.PCI0.LNKD, 0},
Package(){0x001effff, 2, \_SB.PCI0.LNKA, 0},
Package(){0x001effff, 3, \_SB.PCI0.LNKB, 0},
Package(){0x001fffff, 0, \_SB.PCI0.LNKD, 0},
Package(){0x001fffff, 1, \_SB.PCI0.LNKA, 0},
Package(){0x001fffff, 2, \_SB.PCI0.LNKB, 0},
Package(){0x001fffff, 3, \_SB.PCI0.LNKC, 0},
})
Name(PRTA, Package() {
Package(){0x0001ffff, 0, 0, 20},
Package(){0x0001ffff, 1, 0, 21},
Package(){0x0001ffff, 2, 0, 22},
Package(){0x0001ffff, 3, 0, 23},
Package(){0x0002ffff, 0, 0, 24},
Package(){0x0002ffff, 1, 0, 25},
Package(){0x0002ffff, 2, 0, 26},
Package(){0x0002ffff, 3, 0, 27},
Package(){0x0003ffff, 0, 0, 28},
Package(){0x0003ffff, 1, 0, 29},
Package(){0x0003ffff, 2, 0, 30},
Package(){0x0003ffff, 3, 0, 31},
Package(){0x0004ffff, 0, 0, 32},
Package(){0x0004ffff, 1, 0, 33},
Package(){0x0004ffff, 2, 0, 34},
Package(){0x0004ffff, 3, 0, 35},
Package(){0x0005ffff, 0, 0, 36},
Package(){0x0005ffff, 1, 0, 37},
Package(){0x0005ffff, 2, 0, 38},
Package(){0x0005ffff, 3, 0, 39},
Package(){0x0006ffff, 0, 0, 40},
Package(){0x0006ffff, 1, 0, 41},
Package(){0x0006ffff, 2, 0, 42},
Package(){0x0006ffff, 3, 0, 43},
Package(){0x0007ffff, 0, 0, 44},
Package(){0x0007ffff, 1, 0, 45},
Package(){0x0007ffff, 2, 0, 46},
Package(){0x0007ffff, 3, 0, 47},
Package(){0x0008ffff, 0, 0, 17},
Package(){0x0008ffff, 1, 0, 18},
Package(){0x0008ffff, 2, 0, 19},
Package(){0x0008ffff, 3, 0, 20},
Package(){0x0009ffff, 0, 0, 21},
Package(){0x0009ffff, 1, 0, 22},
Package(){0x0009ffff, 2, 0, 23},
Package(){0x0009ffff, 3, 0, 24},
Package(){0x000affff, 0, 0, 25},
Package(){0x000affff, 1, 0, 26},
Package(){0x000affff, 2, 0, 27},
Package(){0x000affff, 3, 0, 28},
Package(){0x000bffff, 0, 0, 29},
Package(){0x000bffff, 1, 0, 30},
Package(){0x000bffff, 2, 0, 31},
Package(){0x000bffff, 3, 0, 32},
Package(){0x000cffff, 0, 0, 33},
Package(){0x000cffff, 1, 0, 34},
Package(){0x000cffff, 2, 0, 35},
Package(){0x000cffff, 3, 0, 36},
Package(){0x000dffff, 0, 0, 37},
Package(){0x000dffff, 1, 0, 38},
Package(){0x000dffff, 2, 0, 39},
Package(){0x000dffff, 3, 0, 40},
Package(){0x000effff, 0, 0, 41},
Package(){0x000effff, 1, 0, 42},
Package(){0x000effff, 2, 0, 43},
Package(){0x000effff, 3, 0, 44},
Package(){0x000fffff, 0, 0, 45},
Package(){0x000fffff, 1, 0, 46},
Package(){0x000fffff, 2, 0, 47},
Package(){0x000fffff, 3, 0, 16},
Package(){0x0010ffff, 0, 0, 18},
Package(){0x0010ffff, 1, 0, 19},
Package(){0x0010ffff, 2, 0, 20},
Package(){0x0010ffff, 3, 0, 21},
Package(){0x0011ffff, 0, 0, 22},
Package(){0x0011ffff, 1, 0, 23},
Package(){0x0011ffff, 2, 0, 24},
Package(){0x0011ffff, 3, 0, 25},
Package(){0x0012ffff, 0, 0, 26},
Package(){0x0012ffff, 1, 0, 27},
Package(){0x0012ffff, 2, 0, 28},
Package(){0x0012ffff, 3, 0, 29},
Package(){0x0013ffff, 0, 0, 30},
Package(){0x0013ffff, 1, 0, 31},
Package(){0x0013ffff, 2, 0, 32},
Package(){0x0013ffff, 3, 0, 33},
Package(){0x0014ffff, 0, 0, 34},
Package(){0x0014ffff, 1, 0, 35},
Package(){0x0014ffff, 2, 0, 36},
Package(){0x0014ffff, 3, 0, 37},
Package(){0x0015ffff, 0, 0, 38},
Package(){0x0015ffff, 1, 0, 39},
Package(){0x0015ffff, 2, 0, 40},
Package(){0x0015ffff, 3, 0, 41},
Package(){0x0016ffff, 0, 0, 42},
Package(){0x0016ffff, 1, 0, 43},
Package(){0x0016ffff, 2, 0, 44},
Package(){0x0016ffff, 3, 0, 45},
Package(){0x0017ffff, 0, 0, 46},
Package(){0x0017ffff, 1, 0, 47},
Package(){0x0017ffff, 2, 0, 16},
Package(){0x0017ffff, 3, 0, 17},
Package(){0x0018ffff, 0, 0, 19},
Package(){0x0018ffff, 1, 0, 20},
Package(){0x0018ffff, 2, 0, 21},
Package(){0x0018ffff, 3, 0, 22},
Package(){0x0019ffff, 0, 0, 23},
Package(){0x0019ffff, 1, 0, 24},
Package(){0x0019ffff, 2, 0, 25},
Package(){0x0019ffff, 3, 0, 26},
Package(){0x001affff, 0, 0, 27},
Package(){0x001affff, 1, 0, 28},
Package(){0x001affff, 2, 0, 29},
Package(){0x001affff, 3, 0, 30},
Package(){0x001bffff, 0, 0, 31},
Package(){0x001bffff, 1, 0, 32},
Package(){0x001bffff, 2, 0, 33},
Package(){0x001bffff, 3, 0, 34},
Package(){0x001cffff, 0, 0, 35},
Package(){0x001cffff, 1, 0, 36},
Package(){0x001cffff, 2, 0, 37},
Package(){0x001cffff, 3, 0, 38},
Package(){0x001dffff, 0, 0, 39},
Package(){0x001dffff, 1, 0, 40},
Package(){0x001dffff, 2, 0, 41},
Package(){0x001dffff, 3, 0, 42},
Package(){0x001effff, 0, 0, 43},
Package(){0x001effff, 1, 0, 44},
Package(){0x001effff, 2, 0, 45},
Package(){0x001effff, 3, 0, 46},
Package(){0x001fffff, 0, 0, 47},
Package(){0x001fffff, 1, 0, 16},
Package(){0x001fffff, 2, 0, 17},
Package(){0x001fffff, 3, 0, 18},
})
        Device ( S00 ) {
            Name ( _ADR, 0x00000000 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH00 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH00, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S01 ) {
            Name ( _ADR, 0x00000001 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH00 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH00, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S02 ) {
            Name ( _ADR, 0x00000002 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH02 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH02, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S03 ) {
            Name ( _ADR, 0x00000003 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH02 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH02, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S04 ) {
            Name ( _ADR, 0x00000004 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH04 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH04, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S05 ) {
            Name ( _ADR, 0x00000005 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH04 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH04, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S06 ) {
            Name ( _ADR, 0x00000006 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH06 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH06, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S07 ) {
            Name ( _ADR, 0x00000007 )
            Name ( _SUN, 0x00000000 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH06 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH06, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S08 ) {
            Name ( _ADR, 0x00010000 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH08 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH08, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S09 ) {
            Name ( _ADR, 0x00010001 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH08 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH08, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0A ) {
            Name ( _ADR, 0x00010002 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH0A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH0A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0B ) {
            Name ( _ADR, 0x00010003 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH0A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH0A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0C ) {
            Name ( _ADR, 0x00010004 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH0C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH0C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0D ) {
            Name ( _ADR, 0x00010005 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH0C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH0C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0E ) {
            Name ( _ADR, 0x00010006 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH0E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH0E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S0F ) {
            Name ( _ADR, 0x00010007 )
            Name ( _SUN, 0x00000001 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH0E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH0E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S10 ) {
            Name ( _ADR, 0x00020000 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH10 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH10, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S11 ) {
            Name ( _ADR, 0x00020001 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH10 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH10, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S12 ) {
            Name ( _ADR, 0x00020002 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH12 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH12, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S13 ) {
            Name ( _ADR, 0x00020003 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH12 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH12, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S14 ) {
            Name ( _ADR, 0x00020004 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH14 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH14, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S15 ) {
            Name ( _ADR, 0x00020005 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH14 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH14, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S16 ) {
            Name ( _ADR, 0x00020006 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH16 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH16, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S17 ) {
            Name ( _ADR, 0x00020007 )
            Name ( _SUN, 0x00000002 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH16 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH16, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S18 ) {
            Name ( _ADR, 0x00030000 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH18 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH18, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S19 ) {
            Name ( _ADR, 0x00030001 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH18 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH18, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1A ) {
            Name ( _ADR, 0x00030002 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH1A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH1A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1B ) {
            Name ( _ADR, 0x00030003 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH1A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH1A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1C ) {
            Name ( _ADR, 0x00030004 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH1C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH1C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1D ) {
            Name ( _ADR, 0x00030005 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH1C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH1C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1E ) {
            Name ( _ADR, 0x00030006 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH1E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH1E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S1F ) {
            Name ( _ADR, 0x00030007 )
            Name ( _SUN, 0x00000003 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH1E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH1E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S20 ) {
            Name ( _ADR, 0x00040000 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH20 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH20, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S21 ) {
            Name ( _ADR, 0x00040001 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH20 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH20, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S22 ) {
            Name ( _ADR, 0x00040002 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH22 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH22, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S23 ) {
            Name ( _ADR, 0x00040003 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH22 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH22, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S24 ) {
            Name ( _ADR, 0x00040004 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH24 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH24, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S25 ) {
            Name ( _ADR, 0x00040005 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH24 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH24, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S26 ) {
            Name ( _ADR, 0x00040006 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH26 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH26, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S27 ) {
            Name ( _ADR, 0x00040007 )
            Name ( _SUN, 0x00000004 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH26 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH26, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S28 ) {
            Name ( _ADR, 0x00050000 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH28 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH28, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S29 ) {
            Name ( _ADR, 0x00050001 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH28 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH28, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2A ) {
            Name ( _ADR, 0x00050002 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH2A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH2A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2B ) {
            Name ( _ADR, 0x00050003 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH2A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH2A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2C ) {
            Name ( _ADR, 0x00050004 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH2C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH2C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2D ) {
            Name ( _ADR, 0x00050005 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH2C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH2C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2E ) {
            Name ( _ADR, 0x00050006 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH2E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH2E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S2F ) {
            Name ( _ADR, 0x00050007 )
            Name ( _SUN, 0x00000005 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH2E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH2E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S30 ) {
            Name ( _ADR, 0x00060000 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH30 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH30, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S31 ) {
            Name ( _ADR, 0x00060001 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH30 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH30, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S32 ) {
            Name ( _ADR, 0x00060002 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH32 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH32, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S33 ) {
            Name ( _ADR, 0x00060003 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH32 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH32, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S34 ) {
            Name ( _ADR, 0x00060004 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH34 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH34, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S35 ) {
            Name ( _ADR, 0x00060005 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH34 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH34, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S36 ) {
            Name ( _ADR, 0x00060006 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH36 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH36, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S37 ) {
            Name ( _ADR, 0x00060007 )
            Name ( _SUN, 0x00000006 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH36 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH36, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S38 ) {
            Name ( _ADR, 0x00070000 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH38 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH38, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S39 ) {
            Name ( _ADR, 0x00070001 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH38 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH38, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3A ) {
            Name ( _ADR, 0x00070002 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH3A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH3A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3B ) {
            Name ( _ADR, 0x00070003 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH3A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH3A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3C ) {
            Name ( _ADR, 0x00070004 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH3C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH3C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3D ) {
            Name ( _ADR, 0x00070005 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH3C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH3C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3E ) {
            Name ( _ADR, 0x00070006 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH3E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH3E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S3F ) {
            Name ( _ADR, 0x00070007 )
            Name ( _SUN, 0x00000007 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH3E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH3E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S40 ) {
            Name ( _ADR, 0x00080000 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH40 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH40, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S41 ) {
            Name ( _ADR, 0x00080001 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH40 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH40, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S42 ) {
            Name ( _ADR, 0x00080002 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH42 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH42, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S43 ) {
            Name ( _ADR, 0x00080003 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH42 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH42, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S44 ) {
            Name ( _ADR, 0x00080004 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH44 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH44, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S45 ) {
            Name ( _ADR, 0x00080005 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH44 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH44, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S46 ) {
            Name ( _ADR, 0x00080006 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH46 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH46, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S47 ) {
            Name ( _ADR, 0x00080007 )
            Name ( _SUN, 0x00000008 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH46 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH46, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S48 ) {
            Name ( _ADR, 0x00090000 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH48 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH48, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S49 ) {
            Name ( _ADR, 0x00090001 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH48 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH48, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4A ) {
            Name ( _ADR, 0x00090002 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH4A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH4A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4B ) {
            Name ( _ADR, 0x00090003 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH4A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH4A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4C ) {
            Name ( _ADR, 0x00090004 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH4C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH4C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4D ) {
            Name ( _ADR, 0x00090005 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH4C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH4C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4E ) {
            Name ( _ADR, 0x00090006 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH4E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH4E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S4F ) {
            Name ( _ADR, 0x00090007 )
            Name ( _SUN, 0x00000009 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH4E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH4E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S50 ) {
            Name ( _ADR, 0x000a0000 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH50 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH50, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S51 ) {
            Name ( _ADR, 0x000a0001 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH50 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH50, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S52 ) {
            Name ( _ADR, 0x000a0002 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH52 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH52, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S53 ) {
            Name ( _ADR, 0x000a0003 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH52 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH52, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S54 ) {
            Name ( _ADR, 0x000a0004 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH54 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH54, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S55 ) {
            Name ( _ADR, 0x000a0005 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH54 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH54, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S56 ) {
            Name ( _ADR, 0x000a0006 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH56 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH56, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S57 ) {
            Name ( _ADR, 0x000a0007 )
            Name ( _SUN, 0x0000000a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH56 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH56, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S58 ) {
            Name ( _ADR, 0x000b0000 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH58 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH58, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S59 ) {
            Name ( _ADR, 0x000b0001 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH58 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH58, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5A ) {
            Name ( _ADR, 0x000b0002 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH5A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH5A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5B ) {
            Name ( _ADR, 0x000b0003 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH5A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH5A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5C ) {
            Name ( _ADR, 0x000b0004 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH5C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH5C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5D ) {
            Name ( _ADR, 0x000b0005 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH5C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH5C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5E ) {
            Name ( _ADR, 0x000b0006 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH5E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH5E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S5F ) {
            Name ( _ADR, 0x000b0007 )
            Name ( _SUN, 0x0000000b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH5E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH5E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S60 ) {
            Name ( _ADR, 0x000c0000 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH60 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH60, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S61 ) {
            Name ( _ADR, 0x000c0001 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH60 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH60, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S62 ) {
            Name ( _ADR, 0x000c0002 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH62 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH62, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S63 ) {
            Name ( _ADR, 0x000c0003 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH62 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH62, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S64 ) {
            Name ( _ADR, 0x000c0004 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH64 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH64, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S65 ) {
            Name ( _ADR, 0x000c0005 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH64 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH64, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S66 ) {
            Name ( _ADR, 0x000c0006 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH66 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH66, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S67 ) {
            Name ( _ADR, 0x000c0007 )
            Name ( _SUN, 0x0000000c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH66 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH66, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S68 ) {
            Name ( _ADR, 0x000d0000 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH68 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH68, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S69 ) {
            Name ( _ADR, 0x000d0001 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH68 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH68, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6A ) {
            Name ( _ADR, 0x000d0002 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH6A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH6A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6B ) {
            Name ( _ADR, 0x000d0003 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH6A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH6A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6C ) {
            Name ( _ADR, 0x000d0004 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH6C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH6C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6D ) {
            Name ( _ADR, 0x000d0005 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH6C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH6C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6E ) {
            Name ( _ADR, 0x000d0006 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH6E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH6E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S6F ) {
            Name ( _ADR, 0x000d0007 )
            Name ( _SUN, 0x0000000d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH6E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH6E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S70 ) {
            Name ( _ADR, 0x000e0000 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH70 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH70, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S71 ) {
            Name ( _ADR, 0x000e0001 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH70 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH70, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S72 ) {
            Name ( _ADR, 0x000e0002 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH72 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH72, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S73 ) {
            Name ( _ADR, 0x000e0003 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH72 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH72, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S74 ) {
            Name ( _ADR, 0x000e0004 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH74 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH74, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S75 ) {
            Name ( _ADR, 0x000e0005 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH74 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH74, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S76 ) {
            Name ( _ADR, 0x000e0006 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH76 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH76, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S77 ) {
            Name ( _ADR, 0x000e0007 )
            Name ( _SUN, 0x0000000e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH76 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH76, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S78 ) {
            Name ( _ADR, 0x000f0000 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH78 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH78, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S79 ) {
            Name ( _ADR, 0x000f0001 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH78 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH78, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7A ) {
            Name ( _ADR, 0x000f0002 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH7A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH7A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7B ) {
            Name ( _ADR, 0x000f0003 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH7A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH7A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7C ) {
            Name ( _ADR, 0x000f0004 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH7C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH7C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7D ) {
            Name ( _ADR, 0x000f0005 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH7C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH7C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7E ) {
            Name ( _ADR, 0x000f0006 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH7E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH7E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S7F ) {
            Name ( _ADR, 0x000f0007 )
            Name ( _SUN, 0x0000000f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH7E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH7E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S80 ) {
            Name ( _ADR, 0x00100000 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH80 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH80, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S81 ) {
            Name ( _ADR, 0x00100001 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH80 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH80, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S82 ) {
            Name ( _ADR, 0x00100002 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH82 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH82, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S83 ) {
            Name ( _ADR, 0x00100003 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH82 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH82, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S84 ) {
            Name ( _ADR, 0x00100004 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH84 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH84, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S85 ) {
            Name ( _ADR, 0x00100005 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH84 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH84, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S86 ) {
            Name ( _ADR, 0x00100006 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH86 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH86, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S87 ) {
            Name ( _ADR, 0x00100007 )
            Name ( _SUN, 0x00000010 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH86 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH86, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S88 ) {
            Name ( _ADR, 0x00110000 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH88 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH88, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S89 ) {
            Name ( _ADR, 0x00110001 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH88 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH88, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8A ) {
            Name ( _ADR, 0x00110002 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH8A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH8A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8B ) {
            Name ( _ADR, 0x00110003 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH8A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH8A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8C ) {
            Name ( _ADR, 0x00110004 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH8C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH8C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8D ) {
            Name ( _ADR, 0x00110005 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH8C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH8C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8E ) {
            Name ( _ADR, 0x00110006 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH8E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH8E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S8F ) {
            Name ( _ADR, 0x00110007 )
            Name ( _SUN, 0x00000011 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH8E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH8E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S90 ) {
            Name ( _ADR, 0x00120000 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH90 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH90, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S91 ) {
            Name ( _ADR, 0x00120001 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH90 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH90, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S92 ) {
            Name ( _ADR, 0x00120002 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH92 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH92, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S93 ) {
            Name ( _ADR, 0x00120003 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH92 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH92, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S94 ) {
            Name ( _ADR, 0x00120004 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH94 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH94, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S95 ) {
            Name ( _ADR, 0x00120005 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH94 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH94, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S96 ) {
            Name ( _ADR, 0x00120006 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH96 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH96, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S97 ) {
            Name ( _ADR, 0x00120007 )
            Name ( _SUN, 0x00000012 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH96 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH96, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S98 ) {
            Name ( _ADR, 0x00130000 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH98 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH98, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S99 ) {
            Name ( _ADR, 0x00130001 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH98 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH98, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9A ) {
            Name ( _ADR, 0x00130002 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH9A )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH9A, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9B ) {
            Name ( _ADR, 0x00130003 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH9A )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH9A, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9C ) {
            Name ( _ADR, 0x00130004 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH9C )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH9C, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9D ) {
            Name ( _ADR, 0x00130005 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH9C )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH9C, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9E ) {
            Name ( _ADR, 0x00130006 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PH9E )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PH9E, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( S9F ) {
            Name ( _ADR, 0x00130007 )
            Name ( _SUN, 0x00000013 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PH9E )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PH9E, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA0 ) {
            Name ( _ADR, 0x00140000 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHA0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHA0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA1 ) {
            Name ( _ADR, 0x00140001 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHA0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHA0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA2 ) {
            Name ( _ADR, 0x00140002 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHA2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHA2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA3 ) {
            Name ( _ADR, 0x00140003 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHA2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHA2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA4 ) {
            Name ( _ADR, 0x00140004 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHA4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHA4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA5 ) {
            Name ( _ADR, 0x00140005 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHA4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHA4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA6 ) {
            Name ( _ADR, 0x00140006 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHA6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHA6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA7 ) {
            Name ( _ADR, 0x00140007 )
            Name ( _SUN, 0x00000014 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHA6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHA6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA8 ) {
            Name ( _ADR, 0x00150000 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHA8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHA8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SA9 ) {
            Name ( _ADR, 0x00150001 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHA8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHA8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAA ) {
            Name ( _ADR, 0x00150002 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHAA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHAA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAB ) {
            Name ( _ADR, 0x00150003 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHAA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHAA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAC ) {
            Name ( _ADR, 0x00150004 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHAC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHAC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAD ) {
            Name ( _ADR, 0x00150005 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHAC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHAC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAE ) {
            Name ( _ADR, 0x00150006 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHAE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHAE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SAF ) {
            Name ( _ADR, 0x00150007 )
            Name ( _SUN, 0x00000015 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHAE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHAE, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB0 ) {
            Name ( _ADR, 0x00160000 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHB0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHB0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB1 ) {
            Name ( _ADR, 0x00160001 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHB0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHB0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB2 ) {
            Name ( _ADR, 0x00160002 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHB2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHB2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB3 ) {
            Name ( _ADR, 0x00160003 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHB2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHB2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB4 ) {
            Name ( _ADR, 0x00160004 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHB4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHB4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB5 ) {
            Name ( _ADR, 0x00160005 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHB4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHB4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB6 ) {
            Name ( _ADR, 0x00160006 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHB6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHB6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB7 ) {
            Name ( _ADR, 0x00160007 )
            Name ( _SUN, 0x00000016 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHB6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHB6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB8 ) {
            Name ( _ADR, 0x00170000 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHB8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHB8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SB9 ) {
            Name ( _ADR, 0x00170001 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHB8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHB8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBA ) {
            Name ( _ADR, 0x00170002 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHBA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHBA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBB ) {
            Name ( _ADR, 0x00170003 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHBA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHBA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBC ) {
            Name ( _ADR, 0x00170004 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHBC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHBC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBD ) {
            Name ( _ADR, 0x00170005 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHBC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHBC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBE ) {
            Name ( _ADR, 0x00170006 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHBE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHBE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SBF ) {
            Name ( _ADR, 0x00170007 )
            Name ( _SUN, 0x00000017 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHBE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHBE, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC0 ) {
            Name ( _ADR, 0x00180000 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHC0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHC0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC1 ) {
            Name ( _ADR, 0x00180001 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHC0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHC0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC2 ) {
            Name ( _ADR, 0x00180002 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHC2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHC2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC3 ) {
            Name ( _ADR, 0x00180003 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHC2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHC2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC4 ) {
            Name ( _ADR, 0x00180004 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHC4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHC4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC5 ) {
            Name ( _ADR, 0x00180005 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHC4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHC4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC6 ) {
            Name ( _ADR, 0x00180006 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHC6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHC6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC7 ) {
            Name ( _ADR, 0x00180007 )
            Name ( _SUN, 0x00000018 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHC6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHC6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC8 ) {
            Name ( _ADR, 0x00190000 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHC8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHC8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SC9 ) {
            Name ( _ADR, 0x00190001 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHC8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHC8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCA ) {
            Name ( _ADR, 0x00190002 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHCA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHCA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCB ) {
            Name ( _ADR, 0x00190003 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHCA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHCA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCC ) {
            Name ( _ADR, 0x00190004 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHCC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHCC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCD ) {
            Name ( _ADR, 0x00190005 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHCC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHCC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCE ) {
            Name ( _ADR, 0x00190006 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHCE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHCE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SCF ) {
            Name ( _ADR, 0x00190007 )
            Name ( _SUN, 0x00000019 )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHCE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHCE, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD0 ) {
            Name ( _ADR, 0x001a0000 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHD0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHD0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD1 ) {
            Name ( _ADR, 0x001a0001 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHD0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHD0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD2 ) {
            Name ( _ADR, 0x001a0002 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHD2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHD2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD3 ) {
            Name ( _ADR, 0x001a0003 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHD2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHD2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD4 ) {
            Name ( _ADR, 0x001a0004 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHD4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHD4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD5 ) {
            Name ( _ADR, 0x001a0005 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHD4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHD4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD6 ) {
            Name ( _ADR, 0x001a0006 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHD6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHD6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD7 ) {
            Name ( _ADR, 0x001a0007 )
            Name ( _SUN, 0x0000001a )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHD6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHD6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD8 ) {
            Name ( _ADR, 0x001b0000 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHD8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHD8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SD9 ) {
            Name ( _ADR, 0x001b0001 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHD8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHD8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDA ) {
            Name ( _ADR, 0x001b0002 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHDA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHDA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDB ) {
            Name ( _ADR, 0x001b0003 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHDA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHDA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDC ) {
            Name ( _ADR, 0x001b0004 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHDC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHDC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDD ) {
            Name ( _ADR, 0x001b0005 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHDC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHDC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDE ) {
            Name ( _ADR, 0x001b0006 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHDE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHDE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SDF ) {
            Name ( _ADR, 0x001b0007 )
            Name ( _SUN, 0x0000001b )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHDE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHDE, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE0 ) {
            Name ( _ADR, 0x001c0000 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHE0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHE0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE1 ) {
            Name ( _ADR, 0x001c0001 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHE0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHE0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE2 ) {
            Name ( _ADR, 0x001c0002 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHE2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHE2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE3 ) {
            Name ( _ADR, 0x001c0003 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHE2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHE2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE4 ) {
            Name ( _ADR, 0x001c0004 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHE4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHE4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE5 ) {
            Name ( _ADR, 0x001c0005 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHE4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHE4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE6 ) {
            Name ( _ADR, 0x001c0006 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHE6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHE6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE7 ) {
            Name ( _ADR, 0x001c0007 )
            Name ( _SUN, 0x0000001c )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHE6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHE6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE8 ) {
            Name ( _ADR, 0x001d0000 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHE8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHE8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SE9 ) {
            Name ( _ADR, 0x001d0001 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHE8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHE8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SEA ) {
            Name ( _ADR, 0x001d0002 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHEA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHEA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SEB ) {
            Name ( _ADR, 0x001d0003 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHEA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHEA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SEC ) {
            Name ( _ADR, 0x001d0004 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHEC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHEC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SED ) {
            Name ( _ADR, 0x001d0005 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHEC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHEC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SEE ) {
            Name ( _ADR, 0x001d0006 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHEE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHEE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SEF ) {
            Name ( _ADR, 0x001d0007 )
            Name ( _SUN, 0x0000001d )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHEE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHEE, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF0 ) {
            Name ( _ADR, 0x001e0000 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHF0 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHF0, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF1 ) {
            Name ( _ADR, 0x001e0001 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHF0 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHF0, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF2 ) {
            Name ( _ADR, 0x001e0002 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHF2 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHF2, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF3 ) {
            Name ( _ADR, 0x001e0003 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHF2 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHF2, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF4 ) {
            Name ( _ADR, 0x001e0004 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHF4 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHF4, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF5 ) {
            Name ( _ADR, 0x001e0005 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHF4 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHF4, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF6 ) {
            Name ( _ADR, 0x001e0006 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHF6 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHF6, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF7 ) {
            Name ( _ADR, 0x001e0007 )
            Name ( _SUN, 0x0000001e )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHF6 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHF6, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF8 ) {
            Name ( _ADR, 0x001f0000 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHF8 )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHF8, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SF9 ) {
            Name ( _ADR, 0x001f0001 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHF8 )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHF8, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFA ) {
            Name ( _ADR, 0x001f0002 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHFA )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHFA, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFB ) {
            Name ( _ADR, 0x001f0003 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHFA )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHFA, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFC ) {
            Name ( _ADR, 0x001f0004 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHFC )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHFC, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFD ) {
            Name ( _ADR, 0x001f0005 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHFC )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHFC, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFE ) {
            Name ( _ADR, 0x001f0006 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x01, \_GPE.PHFE )
            }
            Method ( _STA, 0 ) {
                And ( \_GPE.PHFE, 0x0f, Local1 )
                Return ( Local1 )
            }
        }
        Device ( SFF ) {
            Name ( _ADR, 0x001f0007 )
            Name ( _SUN, 0x0000001f )
            Method ( _EJ0, 1 ) {
                Store ( 0x10, \_GPE.PHFE )
            }
            Method ( _STA, 0 ) {
                ShiftRight ( 0x4, \_GPE.PHFE, Local1 )
                Return ( Local1 )
            }
        }
    }
    Scope ( \_GPE ) {
        OperationRegion ( PHP, SystemIO, 0x10c0, 0x82 )
        Field ( PHP, ByteAcc, NoLock, Preserve ) {
            PSTA, 8,
            PSTB, 8,
            PH00, 8,
            PH02, 8,
            PH04, 8,
            PH06, 8,
            PH08, 8,
            PH0A, 8,
            PH0C, 8,
            PH0E, 8,
            PH10, 8,
            PH12, 8,
            PH14, 8,
            PH16, 8,
            PH18, 8,
            PH1A, 8,
            PH1C, 8,
            PH1E, 8,
            PH20, 8,
            PH22, 8,
            PH24, 8,
            PH26, 8,
            PH28, 8,
            PH2A, 8,
            PH2C, 8,
            PH2E, 8,
            PH30, 8,
            PH32, 8,
            PH34, 8,
            PH36, 8,
            PH38, 8,
            PH3A, 8,
            PH3C, 8,
            PH3E, 8,
            PH40, 8,
            PH42, 8,
            PH44, 8,
            PH46, 8,
            PH48, 8,
            PH4A, 8,
            PH4C, 8,
            PH4E, 8,
            PH50, 8,
            PH52, 8,
            PH54, 8,
            PH56, 8,
            PH58, 8,
            PH5A, 8,
            PH5C, 8,
            PH5E, 8,
            PH60, 8,
            PH62, 8,
            PH64, 8,
            PH66, 8,
            PH68, 8,
            PH6A, 8,
            PH6C, 8,
            PH6E, 8,
            PH70, 8,
            PH72, 8,
            PH74, 8,
            PH76, 8,
            PH78, 8,
            PH7A, 8,
            PH7C, 8,
            PH7E, 8,
            PH80, 8,
            PH82, 8,
            PH84, 8,
            PH86, 8,
            PH88, 8,
            PH8A, 8,
            PH8C, 8,
            PH8E, 8,
            PH90, 8,
            PH92, 8,
            PH94, 8,
            PH96, 8,
            PH98, 8,
            PH9A, 8,
            PH9C, 8,
            PH9E, 8,
            PHA0, 8,
            PHA2, 8,
            PHA4, 8,
            PHA6, 8,
            PHA8, 8,
            PHAA, 8,
            PHAC, 8,
            PHAE, 8,
            PHB0, 8,
            PHB2, 8,
            PHB4, 8,
            PHB6, 8,
            PHB8, 8,
            PHBA, 8,
            PHBC, 8,
            PHBE, 8,
            PHC0, 8,
            PHC2, 8,
            PHC4, 8,
            PHC6, 8,
            PHC8, 8,
            PHCA, 8,
            PHCC, 8,
            PHCE, 8,
            PHD0, 8,
            PHD2, 8,
            PHD4, 8,
            PHD6, 8,
            PHD8, 8,
            PHDA, 8,
            PHDC, 8,
            PHDE, 8,
            PHE0, 8,
            PHE2, 8,
            PHE4, 8,
            PHE6, 8,
            PHE8, 8,
            PHEA, 8,
            PHEC, 8,
            PHEE, 8,
            PHF0, 8,
            PHF2, 8,
            PHF4, 8,
            PHF6, 8,
            PHF8, 8,
            PHFA, 8,
            PHFC, 8,
            PHFE, 8,
        }
        OperationRegion ( DG1, SystemIO, 0xb044, 0x04 )
        Field ( DG1, ByteAcc, NoLock, Preserve ) {
            DPT1, 8, DPT2, 8
        }
        Method ( _L03, 0, Serialized ) {
            Name ( SLT, 0x0 )
            Name ( EVT, 0x0 )
            Store ( PSTA, Local1 )
            And ( Local1, 0xf, EVT )
            Store ( PSTB, Local1 )
            And ( Local1, 0xff, SLT )
            If ( And(SLT, 0x80) ) {
                If ( And(SLT, 0x40) ) {
                    If ( And(SLT, 0x20) ) {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SFF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SFE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SFD, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SFC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SFB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SFA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SF9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SF8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SF7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SF6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SF5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SF4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SF3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SF2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SF1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SF0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SEF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SEE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SED, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SEC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SEB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SEA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SE9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SE8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SE7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SE6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SE5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SE4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SE3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SE2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SE1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SE0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Else {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SDF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SDE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SDD, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SDC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SDB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SDA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SD9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SD8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SD7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SD6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SD5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SD4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SD3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SD2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SD1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SD0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SCF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SCE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SCD, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SCC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SCB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SCA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SC9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SC8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SC7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SC6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SC5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SC4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SC3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SC2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SC1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SC0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Else {
                    If ( And(SLT, 0x20) ) {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SBF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SBE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SBD, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SBC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SBB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SBA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SB9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SB8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SB7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SB6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SB5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SB4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SB3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SB2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SB1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SB0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SAF, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SAE, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SAD, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SAC, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SAB, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SAA, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SA9, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SA8, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SA7, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SA6, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SA5, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SA4, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SA3, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SA2, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.SA1, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.SA0, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Else {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S9F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S9E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S9D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S9C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S9B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S9A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S99, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S98, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S97, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S96, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S95, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S94, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S93, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S92, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S91, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S90, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S8F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S8E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S8D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S8C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S8B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S8A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S89, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S88, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S87, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S86, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S85, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S84, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S83, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S82, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S81, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S80, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Else {
                If ( And(SLT, 0x40) ) {
                    If ( And(SLT, 0x20) ) {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S7F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S7E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S7D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S7C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S7B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S7A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S79, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S78, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S77, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S76, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S75, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S74, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S73, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S72, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S71, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S70, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S6F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S6E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S6D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S6C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S6B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S6A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S69, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S68, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S67, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S66, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S65, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S64, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S63, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S62, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S61, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S60, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Else {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S5F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S5E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S5D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S5C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S5B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S5A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S59, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S58, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S57, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S56, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S55, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S54, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S53, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S52, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S51, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S50, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S4F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S4E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S4D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S4C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S4B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S4A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S49, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S48, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S47, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S46, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S45, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S44, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S43, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S42, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S41, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S40, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Else {
                    If ( And(SLT, 0x20) ) {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S3F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S3E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S3D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S3C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S3B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S3A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S39, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S38, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S37, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S36, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S35, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S34, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S33, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S32, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S31, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S30, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S2F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S2E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S2D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S2C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S2B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S2A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S29, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S28, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S27, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S26, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S25, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S24, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S23, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S22, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S21, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S20, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Else {
                        If ( And(SLT, 0x10) ) {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S1F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S1E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S1D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S1C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S1B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S1A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S19, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S18, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S17, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S16, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S15, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S14, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S13, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S12, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S11, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S10, EVT )
                                        }
                                    }
                                }
                            }
                        }
                        Else {
                            If ( And(SLT, 0x08) ) {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S0F, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S0E, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S0D, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S0C, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S0B, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S0A, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S09, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S08, EVT )
                                        }
                                    }
                                }
                            }
                            Else {
                                If ( And(SLT, 0x04) ) {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S07, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S06, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S05, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S04, EVT )
                                        }
                                    }
                                }
                                Else {
                                    If ( And(SLT, 0x02) ) {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S03, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S02, EVT )
                                        }
                                    }
                                    Else {
                                        If ( And(SLT, 0x01) ) {
                                            Notify ( \_SB.PCI0.S01, EVT )
                                        }
                                        Else {
                                            Notify ( \_SB.PCI0.S00, EVT )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
