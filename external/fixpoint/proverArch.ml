(*
 * Copyright © 2009 The Regents of the University of California. All rights reserved. 
 *
 * Permission is hereby granted, without written agreement and without 
 * license or royalty fees, to use, copy, modify, and distribute this 
 * software and its documentation for any purpose, provided that the 
 * above copyright notice and the following two paragraphs appear in 
 * all copies of this software. 
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY 
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES 
 * ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN 
 * IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY 
 * OF SUCH DAMAGE. 
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES, 
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS 
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION 
 * TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 *
 *)

(* Theories API *)

module type THEORY = sig
  
  type context
  type sort
  type ast
  type appDef 
  type sortDef 

  val sym_sort    : appDef  -> Ast.Sort.t
  val sym_name    : appDef  -> Ast.Symbol.t
  val sort_name   : sortDef -> Ast.Sort.tycon
  val theories    : unit -> sortDef list * appDef list
  val mk_thy_sort : sortDef -> context -> sort list -> sort
  val mk_thy_app  : appDef  -> context -> sort list -> ast list -> ast
  val is_interp   : Ast.Sort.tycon -> bool
end

(* Theorem Prover API *)

(* RJ: This is CLEARLY the wrong API and in need of a major refactoring. *)

module type SMTSOLVER = sig
 
  (* Types *)
  type context
  type symbol 
  type ast
  type sort
  type fun_decl
 
  (* Relations *) 
  val mkEq : context -> ast -> ast -> ast
  val mkNe : context -> ast array -> ast
  val mkGt : context -> ast -> ast -> ast
  val mkGe : context -> ast -> ast -> ast
  val mkLt : context -> ast -> ast -> ast
  val mkLe : context -> ast -> ast -> ast
 
  (* Expression *)
  val mkAll : context -> sort array -> symbol array -> ast -> ast
  val mkApp : context -> fun_decl -> ast array -> ast
  val mkMul : context -> ast array -> ast
  val mkAdd : context -> ast array -> ast
  val mkSub : context -> ast array -> ast
  val mkMod : context -> ast -> ast -> ast
  
  (* Predicates *)
  val mkIte     : context -> ast -> ast -> ast -> ast
  val mkInt     : context -> int -> sort -> ast
  val mkTrue    : context -> ast
  val mkFalse   : context -> ast
  val mkNot     : context -> ast -> ast
  val mkAnd     : context -> ast array -> ast
  val mkOr      : context -> ast array -> ast
  val mkImp     : context -> ast -> ast -> ast
  val mkIff     : context -> ast -> ast -> ast
 
  (* Conversions *)
  val astString : context -> ast -> string

  (* Set Theory Operations *)
  val mkEmptySet    : context -> sort -> ast
  val mkSetAdd      : context -> ast -> ast -> ast
  val mkSetMem      : context -> ast -> ast -> ast
  val mkSetCup      : context -> ast array -> ast
  val mkSetCap      : context -> ast array -> ast
  val mkSetDif      : context -> ast -> ast -> ast
  val mkSetSub      : context -> ast -> ast -> ast

  (* Constructors *)
  val mkContext     : (string * string) array -> context
  val mkIntSort     : context -> sort
  val mkBoolSort    : context -> sort
  val mkSetSort     : context -> sort -> sort
  val var           : context -> symbol -> sort -> ast
  val boundVar      : context -> int -> sort -> ast
  val stringSymbol  : context -> string -> symbol
  val funcDecl      : context -> symbol -> sort array -> sort -> fun_decl
  val isBool        : context -> ast -> bool
  
  (* Queries *)
  val bracket       : context -> (unit -> 'a) -> 'a
  val assertAxiom   : context -> ast -> unit
  val assertPreds   : context -> ast list -> unit
  val unsat         : context -> bool
  val valid         : context -> ast -> bool
  val contra        : context -> ast -> bool
 
  (* Stats *)
  val print_stats   : Format.formatter -> unit -> unit
end

module type PROVER = 
sig
  type t 
 
  val create      : Ast.Sort.t list                         (* sorts        *) 
                    -> Ast.Sort.t Ast.Symbol.SMap.t         (* environment  *)
                    -> Ast.pred list                        (* axioms       *) 
                    -> Ast.Symbol.t list                    (* distinct constants, sorts in env *)
                    -> t
 
  val set_filter  : t 
                    -> Ast.Sort.t Ast.Symbol.SMap.t 
                    -> Ast.Symbol.t 
                    -> Ast.pred list 
                    -> ('a * Ast.pred) list 
                    -> 'a list

  val print_stats : Format.formatter -> t -> unit

  (*
  val unsat_cores : t                                       
                    -> Ast.Sort.t Ast.Symbol.SMap.t 
                    -> Ast.pred                             (* background predicate   *)
                    -> ('a * Ast.pred) list                 (* [(index, killer-fact)] *)
                    -> ('b * Ast.pred) list                 (* [(index, killed-fact)] *)
                    -> ('b * 'a list) list                  (* [(killed, killers)]    *)

  *)
 
  val is_contra   : t  
                    -> Ast.Sort.t Ast.Symbol.SMap.t 
                    -> Ast.pred
                    -> bool

  val unsat_core  : t                                       
                    -> Ast.Sort.t Ast.Symbol.SMap.t 
                    -> Ast.pred                             (* background predicate   *)
                    -> ('a * Ast.pred) list                 (* [(index, killer-fact)] *)
                    -> 'a list                              (* [unsat-core-index]    *)

  val unsat_suffix : t
                   -> Ast.Sort.t Ast.Symbol.SMap.t 
                   -> Ast.pred                              (* background predicate   *)
                   -> Ast.pred list                         (* [p0,...,pn] *)
                   -> int option                            (* max j st. p /\i=j..n pi unsat *)

end
