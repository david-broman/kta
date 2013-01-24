
(* Parameters: 
  - little/big endian
  - 32 or 64 bit
*)

open Ustring.Op

(** Info type *)
type lineno = int
type info = 
 | NoI 
 | Info of lineno

(** Types for making the inst data type more descriptive *)
type rd  = int
type rs1 = int
type rs2 = int
type imm12 = int  (* 12 bit immediate *)
type immv = int   (* variable number of bits depending on instruction 
                     SLLI, SRAI, SRLI have 5 bit, 
                     SLLIW, SRAIW, and SRLIW have 4 bit,
                     LUI has 20 bits. Note that rs1 is unused for LUI
                     other instructions have 12 bits *)

(** Opcodes *)
type opAbsJmp   = OpJ  | OpJAL
type opCondJmp  = OpBEQ | OpBNE | OpBLT | OpBGE | OpBLTU | OpBGEU
type opIndJmp   = OpJALR_C | OpJALR_R | OpJALR_J | OpRDNPC
type opLoad     = OpLB | OpLH | OpLW | OpLD | OpLBU | OpLHU | OpLWU
type opStore    = OpSB | OpSH | OpSW | OpSD
type opAtomic   = OpAMOADD_W  | OpAMOSWAP_W | OpAMOAND_W   | OpAMOOR_W | 
                  OpAMOMIN_W  | OpAMOMAX_W  | OpAMOMINU_W  | OpAMOMAXU_W | 
                  OpAMOADD_D  | OpAMOSWAP_D | OpAMOAND_D   | OpAMOOR_D | 
                  OpAMOMIN_D  | OpAMOMAX_D  | OpAMOMINU_D  | OpAMOMAXU_D 
type opCompImm  = OpADDI  | OpSLLI  | OpSLTI   | OpSLTIU | OpXORI | 
                  OpSRLI  | OpSRAI  | OpORI    | OpANDI  | OpLUI  |
                  OpADDIW | OpSLLIW | OpSRLIW  | OpSRAIW
type opCompReg  = OpADD   | OpSUB   | OpSLL    | OpSLT   | OpSLTU |
                  OpXOR   | OpSRL   | OpSRA    | OpOR    | OpAND  |
                  OpMUL   | OpMULH  | OpMULHSU | OpMULHU | OpDIV  |
                  OpDIVU  | OpREM   | OpREMU   | OpADDW  | OpSUBW |
                  OpSLLW  | OpSRLW  | OpSRAW   | OpMULW  | OpDIVW |
                  OpDIVUW | OpREMW  | OpREMUW
type opFPLoad   = OpFLW   | OpFLD
type opFPStore  = OpFSW   | OpFSD                     

(** Instructions *)
type inst = 
| IAbsJmp    of info * sid * opAbsJmp                   (* Absolute Jump *)
| ICondJmp   of info * rs1 * rs2 * sid   * opCondJmp    (* Conditional Jump  *)
| IIndJmp    of info * rd  * rs1 * imm12 * opIndJmp     (* Indirect Jump *)
| ILoad      of info * rd  * rs1 * imm12 * opLoad       (* Load Memory *)
| IStore     of info * rs1 * rs2 * imm12 * opStore      (* Store Memory *)
| IAtomic    of info * rd  * rs1 * rs2   * opAtomic     (* Atomic Memory *) 
| ICompImm   of info * rd  * rs1 * immv  * opCompImm    (* Integer Register-Immediate Computation *)
| ICompReg   of info * rd  * rs1 * rs2   * opCompReg    (* Integer Register-Register Computation *)
| IFPLoad    of info * rd  * rs1 * imm12 * opFPLoad     (* Floating-Point Load Memory *) 
| IFPStore   of info * rs1 * rs2 * imm12 * opFPStore    (* Floating-Point Store Memory *) 




(** Is the integer register-immediate opcode a 32 bit instruction used only in RV64? *)
let isIntImReg32 op = match op with
   OpADDIW | OpSLLIW | OpSRLIW | OpSRAIW -> true | _ -> false

(** Is the integer register-register opcode a 32 bit instruction used only in RV64? *)
let isIntRegReg32 op = match op with
   OpADDW | OpSUBW | OpSLLW | OpSRLW | OpSRAW | OpMULW | OpDIVW | OpDIVUW |
   OpREMW | OpREMUW -> true | _ -> false






