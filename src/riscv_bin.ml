

open Riscv_isa
open Printf

(*************** Exported types and exceptions ********************)

exception Incomplete_parcel
exception Not_enough_parcels

type big_endian = bool
type parcel = int

(*************** Local types and exceptions ***********************)

type offset12 = int
type offset25 = int

(* Internal wrapper type used for storing addresses. Before
   the instruction is returned, these bit addresses are replaced
   by symbolic points *)
type wrapped_inst =
| Inst of inst 
| BitAddrAbsJmp of info * offset25 * opAbsJmp
| BitAddrCondJmp of info * rs1 * rs2 * offset12 * opCondJmp



(*************** Local functions **********************************)

(* Decoding of opcode for R, R4, I, B, L, and J Types *)
let d_op low = low land 0b1111111

(* Decoding of rd for R, R4, I, and L Types *)
let d_rd high = high lsr 11 

(* Decoding of rs1 for R, R4, I, and B Types *)
let d_rs1 high = (high lsr 6) land 0b11111 

(* Decoding of rs2 for R, R4, and B Types  *)
let d_rs2 high = (high lsr 1) land 0b11111 

(* Decoding of rs3 for the R4 type *)
let d_rs3 high low = ((high land 1) lsl 4) land (low lsr 12) 

(* Decoding of 12 bit immediate for I-Type *)
let d_imI high low = ((high land 0b111111) lsl 6) land (low lsr 10) 

(* Decoding of 12 bit immediate for B-Type *)
let d_imB high low = ((high lsr 11) lsl 7) land ((high land 1) lsl 6) 
                     land (low lsr 10)

(* Decoding of 20 bit immediate for L-Type *)
let d_imL high low = ((high land 0b11111111111) lsl 9) land (low lsr 7)

(* Decoding of 25 bit jump offset for J-Type *)
let d_offJ high low = (high lsl 9) land (low lsr 7)

(* Decoding of 10 bit funct opcode field for R-Type *)
let d_funR high low = ((high land 1) lsl 9) land (low lsr 7)

(* Decoding of 5 bit funct opcode field for R4-Type *)
let d_funR4 low = (low lsr 7) land 0b11111

(* Decoding of 3 bit funct opcode field for I and B Types *)
let d_funIB low = (low lsr 7) land 0b111

(* Error reporting if we have an unknown instruction *)
let failinst h l = 
  failwith (sprintf "ERROR: Unknown instruction %x,%x,%x,%x\n" 
            (h lsr 8) (h land 0xff) (l lsr 8) (l land 0xff))

(* Decodes one 32 bit instruction *)
let decode_32inst h l =
  match d_op l with
    (* Absolute Jump Instructions *)
  | 0b1100111 -> BitAddrAbsJmp(NoI, d_offJ h l, OpJ)
  | 0b1101111 -> BitAddrAbsJmp(NoI, d_offJ h l, OpJAL)
    (* Conditional Jump Instructions *)
  | 0b1100011 -> 
      let op = match d_funIB l with 0b000 -> OpBEQ | 0b001 -> OpBNE  | 0b100 -> OpBLT |
                                    0b101 -> OpBGE | 0b110 -> OpBLTU | 0b111 -> OpBGEU | 
                                    _ -> failinst h l in
    BitAddrCondJmp(NoI, d_rs1 h, d_rs2 h, d_imB h l, op) 
    (* Indirect Jump Instructions *)
  | 0b1101011 -> 
      let op = match d_funIB l with 0b000 -> OpJALR_C | 0b001 -> OpJALR_R | 
                                    0b010 -> OpJALR_J | 0b100 -> OpRDNPC | 
                                    _ -> failinst h l in
      Inst(IIndJmp(NoI, d_rd h, d_rs1 h, d_imI h l, op))
    (* Load Memory Instructions *)
  | 0b0000011 -> 
      let op = match d_funIB l with 0b000 -> OpLB  | 0b001 -> OpLH  | 0b010 -> OpLW |
                                    0b011 -> OpLD  | 0b100 -> OpLBU | 0b101 -> OpLHU |
                                    0b110 -> OpLWU | _ -> failinst h l in
      Inst(ILoad(NoI, d_rd h, d_rs1 h, d_imI h l, op))
    (* Store Memory Instructions *)
  | 0b0100011 ->
      let op = match d_funIB l with 0b000 -> OpSB | 0b001 -> OpSH | 
                                    0b010 -> OpSW | 0b011 -> OpSD | _ -> failinst h l in
      Inst(IStore(NoI, d_rs1 h, d_rs2 h, d_imB h l, op))
    (* Atomic Memory Instructions *)
  | 0b0101011 ->
      let op = match d_funR h l with 0b000010 -> OpAMOADD_W  | 0b001010 -> OpAMOSWAP_W |
                                     0b010010 -> OpAMOAND_W  | 0b011010 -> OpAMOOR_W |
                                     0b100010 -> OpAMOMIN_W  | 0b101010 -> OpAMOMAX_W |
                                     0b110010 -> OpAMOMINU_W | 0b111010 -> OpAMOMAXU_W |
                                     0b000011 -> OpAMOADD_D  | 0b001011 -> OpAMOSWAP_D |
                                     0b010011 -> OpAMOAND_D  | 0b011011 -> OpAMOOR_D |
                                     0b100011 -> OpAMOMIN_D  | 0b101011 -> OpAMOMAX_D |
                                     0b110011 -> OpAMOMINU_D | 0b111011 -> OpAMOMAXU_D |
                                     _ -> failinst h l in
      Inst(IAtomic(NoI, d_rd h, d_rs1 h, d_rs2 h, op))
     (* Integer Register-Immediate Instructions *)
  | 0b0010011 ->
      let im12 = d_imI h l in
      let imop = im12 lsr 6 in
      let op = match d_funIB l with 0b000 -> OpADDI  | 0b001 -> OpSLLI | 0b010 -> OpSLTI |
                                    0b011 -> OpSLTIU | 0b100 -> OpXORI | 
                                    0b101 when imop = 0 -> OpSRLI |
                                    0b101 when imop = 1 -> OpSRAI |
                                    0b110 -> OpORI   | 0b111 -> OpANDI |
                                    _ -> failinst h l in
      let im = match op with OpSLLI | OpSRLI | OpSRAI -> im12 land 0b111111 | _ -> im12 in
      Inst(IIntImReg(NoI, d_rd h, d_rs1 h, im, op))
  | 0b0110111 -> Inst(IIntImReg(NoI, d_rd h, 0, d_imL h l, OpLUI))
     (* Integer Register-Register Instructions *)
  | 0b0110011 ->
      let op = match d_funR h l with 0b0000000000 -> OpADD    | 0b1000000000 -> OpSUB   |
                                     0b0000000001 -> OpSLL    | 0b0000000010 -> OpSLT   |
                                     0b0000000011 -> OpSLTU   | 0b0000000100 -> OpXOR   | 
                                     0b0000000101 -> OpSRL    | 0b1000000101 -> OpSRA   | 
                                     0b0000000110 -> OpOR     | 0b0000000111 -> OpAND   |
                                     0b0000001000 -> OpMUL    | 0b0000001001 -> OpMULH  |
                                     0b0000001010 -> OpMULHSU | 0b0000001011 -> OpMULHU |
                                     0b0000001100 -> OpDIV    | 0b0000001101 -> OpDIVU  |
                                     0b0000001110 -> OpREM    | 0b0000001111 -> OpREMU  |
                                     _ -> failinst h l in
      Inst(IIntRegReg(NoI, d_rd h, d_rs1 h, d_rs2 h, op))
  | _ -> failinst h l




(* Local function for decoding one instruction. Returns a triple 
   consisting of the new parcel list, number of parcels consumed, and
   the format type value *)
let decode_inst parcels =
  match parcels with
  | p1::ps when (p1 land 0b11111) = 0b11111 -> 
       failwith "ERROR: Instructions larger than 32-bit are not yet supported."
  | p1::ps when (p1 land 0b11) <> 0b11 ->
       failwith "ERROR: 16-bit instructions are not yet supported."
  | low::high::ps -> "TODO"
  | _ -> raise Not_enough_parcels


(**************** Exported functions *******************************)

let parcels_of_bytes bigendian lst =
  let rec loop lst acc =  
    match bigendian,lst with
    | true, (high::low::rest) -> loop rest (((high lsl 8) lor low)::acc)
    | false, (low::high::rest) -> loop rest (((high lsl 8) lor low)::acc)
    | _,[] -> List.rev acc
    | _,_ -> raise Incomplete_parcel 
  in loop lst []    


let bytes_of_parcels bige lst = 
  List.rev (List.fold_left 
               (fun acc p -> if bige then (p land 0xff)::(p lsr 8)::acc
                             else (p lsr 8)::(p land 0xff)::acc) [] lst)


  
  


let decode bin = []



let encode inst = []
  

