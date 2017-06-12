ENTRY(start)
OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64", "elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
PHDRS
{
  text PT_LOAD ;
}
SECTIONS
{
  . = (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30)));
  __image_base__ = .;
  . = (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) + (1 << 20);
  _start = .;
  .text : {
        _stext = .;
       *(.text)
       *(.text.cold)
       *(.text.unlikely)
       *(.fixup)
       *(.gnu.warning)
       _etext = .;
  } :text = 0x9090
  .rodata : {
       . = ALIGN(4);
       __start_bug_frames = .;
       *(.bug_frames.0)
       __stop_bug_frames_0 = .;
       *(.bug_frames.1)
       __stop_bug_frames_1 = .;
       *(.bug_frames.2)
       __stop_bug_frames_2 = .;
       *(.bug_frames.3)
       __stop_bug_frames_3 = .;
       *(.rodata)
       *(.rodata.*)
  } :text
  . = ALIGN((1 << (7)));
  .data.read_mostly : {
       __start___ex_table = .;
       *(.ex_table)
       __stop___ex_table = .;
       __start___pre_ex_table = .;
       *(.ex_table.pre)
       __stop___pre_ex_table = .;
       *(.data.read_mostly)
       *(.data.rel.ro)
       *(.data.rel.ro.*)
  } :text
  .data : {
       . = ALIGN((1 << 12));
       *(.data.page_aligned)
       *(.data)
       *(.data.rel)
       *(.data.rel.*)
       CONSTRUCTORS
  } :text
  . = ALIGN((1 << 12));
  __init_begin = .;
  .init.text : {
       _sinittext = .;
       *(.init.text)
       *(.altinstr_replacement)
       _einittext = .;
  } :text
  .init.data : {
       *(.init.rodata)
       *(.init.rodata.str*)
       *(.init.data)
       *(.init.data.rel)
       *(.init.data.rel.*)
       . = ALIGN(4);
       __trampoline_rel_start = .;
       *(.trampoline_rel)
       __trampoline_rel_stop = .;
       __trampoline_seg_start = .;
       *(.trampoline_seg)
       __trampoline_seg_stop = .;
       . = ALIGN(8);
        __alt_instructions = .;
        *(.altinstructions)
        __alt_instructions_end = .;
       . = ALIGN(8);
       __ctors_start = .;
       *(.ctors)
       __ctors_end = .;
  } :text
  . = ALIGN(32);
  .init.setup : {
       __setup_start = .;
       *(.init.setup)
       __setup_end = .;
  } :text
  .initcall.init : {
       __initcall_start = .;
       *(.initcallpresmp.init)
       __presmp_initcall_end = .;
       *(.initcall1.init)
       __initcall_end = .;
  } :text
  .xsm_initcall.init : {
       __xsm_initcall_start = .;
       *(.xsm_initcall.init)
       __xsm_initcall_end = .;
  } :text
  . = ALIGN(((1 << 12) << 3));
  __init_end = .;
  .bss : {
       __bss_start = .;
       *(.bss.stack_aligned)
       . = ALIGN((1 << 12));
       *(.bss.page_aligned)
       *(.bss)
       . = ALIGN((1 << (7)));
       __per_cpu_start = .;
       *(.bss.percpu)
       . = ALIGN((1 << (7)));
       *(.bss.percpu.read_mostly)
       . = ALIGN((1 << (7)));
       __per_cpu_data_end = .;
       __bss_end = .;
  } :text
  _end = . ;
  efi = .;
  /DISCARD/ : {
       *(.exit.text)
       *(.exit.data)
       *(.exitcall.exit)
       *(.discard)
       *(.discard.*)
       *(.eh_frame)
  }
  .stab 0 : { *(.stab) }
  .stabstr 0 : { *(.stabstr) }
  .stab.excl 0 : { *(.stab.excl) }
  .stab.exclstr 0 : { *(.stab.exclstr) }
  .stab.index 0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment 0 : { *(.comment) }
}
ASSERT(__image_base__ > (((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) ||
       _end <= ((((((((((261 >> 8) * 0xffff000000000000) | (261 << 39))) + ((1 << 39) / 2)) + (64 << 30)) + (1 << 30)) + (1 << 30))) + (1 << 30)) - 256 * (1 << 12),
       "Xen image overlaps stubs area")
ASSERT(kexec_reloc_size - kexec_reloc <= (1 << 12), "kexec_reloc is too large")
ASSERT((cpu0_stack & (((1 << 12) << 3) - 1)) == 0, "cpu0_stack misaligned")
