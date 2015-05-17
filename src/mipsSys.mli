


val get_section : string -> string -> bytes
(** [get_section filename section] returns the sequence of bytes from
    [section] in the file with name [filename]. For instance, to get
    the code, write [get_section "file.elf" ".text"] or to get the
    data, write [get_section "file.elf" ".sdata"]. Raises exception
    [Sys_error] if there an error. *)

val pic32_compile : string list -> bool -> bool -> string -> unit
(** [pic32_compile filenames only_compile optimization_ outputname]
    compiles a C file for the target of a PIC32 MIPS processor.
    [filenames] is a list of files (C or obj-files). If [only_compile]
    is true, the output is an object file and if it is false, the
    output is executable (.elf) file. Parameter [optimization] is true
    if full optimization should be enabled. If it is false, no
    optimization is performed. Raises exception [Sys_error] if there
    is a compilation error.
*)


val section_info: string -> (string * (int * int)) list
(** [section_info filename] returns an association list with the keys
    are text strings representing sections and the values are tuples,
    where the first element is the size of the section and the second
    element is the virtual memory address to the section. For
    instance, a returned list of element [(".text",(100,0xffff))]
    means that there is a .text section, starting at address [0xffff]
    that is of size 100 bytes.
*)
