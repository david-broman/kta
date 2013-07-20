
open Ustring.Op
open Printf
open Scanf

exception CNF_parse_error of int 
exception CNF_vars_not_match of int * int
exception CNF_clauses_not_match of int * int

type literal = Pos of int | Neg of int 
type varstat = VSNotAvailable | VSOnlyNeg | VSOnlyPos | VSPosAndNeg
type cnf = (literal list) array


let varnum lit = match lit with
  | Pos(x) -> x
  | Neg(x) -> x

let variables cnf =  
  let maxval = ref 0 in
  Array.iter (List.iter (fun x -> maxval := max (varnum x) !maxval)) cnf;
  !maxval

let clauses cnf =
  Array.length cnf

type cnf_mode = MMain | MCom1 | MCom2 

let read_cnf filename =  
  let fstr = Utils.read_binfile filename in
  let size = String.length fstr in
  let vars = ref 0 in
  let cls = ref 0 in
  let rec count_int i =
    if i >= size then i else
    match fstr.[i] with 
    |'-'|'0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' -> count_int (i+1) 
    | _ -> i in
  let scan_int i line = 
    let i2 = count_int i in
    (i2,try int_of_string (String.sub fstr i (i2-i)) 
        with _ -> raise (CNF_parse_error line))
  in 
  let rec eat_ws i line newl =
    if i >= size then (i,line) else (
    match fstr.[i] with 
    |' ' -> eat_ws (i+1) line false
    |'\x0D'|'\x0A' -> eat_ws (i+1) (if newl then line else line+1) true
    | _ -> (i,line)) in
  let rec scan_clause i line acc =
    let (i,x) = scan_int i line in
    let (i,line) = eat_ws i line false in
    let l = if x > 0 then Pos(x) else Neg(-1*x) in
    if x = 0 then (i,line,List.rev acc) 
    else scan_clause i line (l::acc)
  in
  let rec scan mode i line lst = (
    if i >= size then List.rev lst else
    match mode,fstr.[i] with
    | MMain,'c' -> scan MCom1 (i+1) line lst
    | MCom1,'\x0D' | MCom1,'\x0A' -> scan MCom2 (i+1) (line+1) lst
    | MCom1,_ -> scan MCom1 (i+1) line lst
    | MCom2,'\x0D' | MCom2,'\x0A' -> scan MCom2 (i+1) line lst
    | MCom2,_ -> scan MMain i line lst
    | MMain,'p' -> 
      if not (try (String.sub fstr (i+1) 4) = " cnf" with _ -> false) then
        raise (CNF_parse_error line);
      let (i,line) = eat_ws (i+5) line false in
      let (i,x) = scan_int i line in
      vars := x;
      let (i,line) = eat_ws i line false in
      let (i,x) = scan_int i line in
      cls := x;
      let (i,line) = eat_ws i line false in      
      scan MMain i line lst
    | MMain,_ -> 
      let (i,line,clause) = scan_clause i line [] in
      scan MMain i line (clause::lst))
  in
  let cnf = Array.of_list (scan MMain 0 1 []) in
  let exp_vars = variables cnf in
  let exp_cl = clauses cnf in
  if exp_vars != !vars then raise (CNF_vars_not_match(exp_vars,!vars)) 
  else if exp_cl != !cls then raise (CNF_clauses_not_match(exp_cl,!cls)) 
  else cnf

                           

let pprint_cnf cnf = 
  let s = us "p cnf " ^. ustring_of_int (variables cnf) ^. us" " ^.
  ustring_of_int (clauses cnf) ^. us"\n" in
  Array.fold_left (fun a ls ->
    let lstr lit = ustring_of_int (match lit with Pos(x) -> x | Neg(x) -> x * -1) in
    a ^. Ustring.concat (us" ") (List.map lstr ls) ^. us" 0\n")
    s cnf
  
  (*
let var_statistics cnf =
  let vstat = Array.make (Array.length cnf) VSNotAvailable in
  Array.iter (List.iter x -> 
              let y = if x < 0 then x * -1 in
              vstat.(y) <- (match  vstat.(y), x > 0 with
              | VSNotAvailable,true  -> VSOnlyPos
              | VSNotAvailable,false -> VSOnlyNeg
              | VSOnlyPos,true -> VSOnlyPos
              | VSOnlyPos,false -> VSPosAndNeg
              | VSOnlyNeg,true -> VSPosAndNeg
              | VSOnlyNeg,false -> VSOnlyNeg
              | VSPosAndNeg,_ -> VSPosAndNeg)) cnf;
  let (na,op,on,pn) = (ref 0,ref 0, ref 0, ref 0) in
  Array.iter (fun
  *)
  







