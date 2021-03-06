

open Ustring.Op
open Utest
open Printf
open Utils
open MipsAst

let main = 

  Utest.init "MIPS";


  (* Test decoding of basic ASM instructions *)
  let tmpname = "__tmp__" in
  MipsSys.pic32_compile ["test/mips_tests/asmtest.c"] false 0 tmpname;
  let insts = MipsUtils.decode (MipsSys.get_section tmpname ".text") in
  Sys.remove tmpname;

  let expected = Ustring.read_file "test/mips_tests/asmtest.expected_asm" in
  let result = MipsUtils.pprint_inst_list insts in
  Utest.test_ustr "Test decoding of basic MIPS ISA instructions."
    result expected;


  (* Test extraction of program information (sections, symbols etc. *)
  let tmpname = "__tmp__" in
  MipsSys.pic32_compile ["test/mips_tests/hello_sections.c"] false 3 tmpname;
  let prog = MipsSys.get_program tmpname in
  let txt = "Read from MIPS binary: " in
  Utest.test_str  (txt ^ "filename.") prog.filename tmpname;
  Utest.test_int  (txt ^ ".text address.") prog.text_sec.addr 0x400018;
  Utest.test_int  (txt ^ ".text size.") prog.text_sec.size 44;
  Utest.test_int  (txt ^ ".data address.") prog.sdata_sec.addr 0x401044;
  Utest.test_int  (txt ^ ".data size.") prog.sdata_sec.size 8;
  Utest.test_int  (txt ^ ".bss address.") prog.sbss_sec.addr 0x40104c;
  Utest.test_int  (txt ^ ".bss size.") prog.sbss_sec.size 4;
  Utest.test_int  (txt ^ "global pointer.") prog.gp 0x409040;
  Sys.remove tmpname;
  


  Utest.result()

