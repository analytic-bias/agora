import Game.Metadata

World "NLQuantifiers"
Level 1
Title "Quantifiers - 1"

namespace NL

Introduction
"
# \"Someone loves everyone.\"

test
"

inductive Atom where
| _n : Atom
| _np : Atom
| _s : Atom

def Value : Type := Bool

axiom Entity : Type
axiom Universal : (Entity -> Value) -> Value
axiom Existential : (Entity -> Value) -> Value
axiom LoveP : Entity -> Entity -> Value
axiom PersonP : Entity -> Value

def atom_interpretation : Atom -> Type
  | Atom._n => (Entity -> Bool)
  | Atom._np => Entity
  | Atom._s => Bool

def n := !Atom._n
def np := !Atom._np
def s := !Atom._s

notation:max (priority := high) "[" a "]" => (interpret Atom atom_interpretation Value a)

-- set_option checkBinderAnnotations false
-- inductive Lexis where
-- | lex (t : Type) : [t] -> Lexis
-- def Lexicon := List Lexis

-- syntax (priority := high) "{{" term,+ "}}" : term
-- macro_rules
--   | `({{$x}}) => `(List.cons $x List.nil)
--   | `({{$x, $xs:term,*}}) => `(List.cons $x {{$xs,*}})

-- #check {{1, 2, 3}}

noncomputable def someone : [(!Atom._np // !Atom._n) ⊗ !Atom._n] :=
  ((fun | (g, f) => Existential (fun x => f x && g x)), PersonP)
noncomputable def loves : [(!Atom._np \\ !Atom._s) // !Atom._np] :=
  fun | (k, y) => k (fun | (x, k') => k' (LoveP x y))
def implies (a b : Bool) : Bool := not a || b
infixr:4 "⊃" => implies
noncomputable def everyone : [(!Atom._np // !Atom._n) ⊗ !Atom._n] :=
  ((fun | (g, f) => Existential (fun x => f x ⊃ g x)), PersonP)

-- TODO lexicon: noncomputable def s := someone ⊗ loves ⊗ everyone

open NLCalculus

-- def g : NLCalculus Atom (((np // n) ⊗ n) ⊗ (((np // s) \\ np) ⊗ ((np // n) ⊗ n)) ⊢ s) :=
--   rbt (rst (ms (mb (rst trefl) arefl) (rst trefl)))

theorem grammatical1 : NLCalculus Atom (((np // n) ⊗ n) ⊗ (((np \\ s) // np) ⊗ ((np // n) ⊗ n)) ⊢ s) := by
  apply rst
  apply rst
  apply ms
  · apply rts
    apply rbt
    apply rst
    apply ms
    · apply trefl
    · apply rst
      apply trefl
  · apply trefl

#check denote Atom atom_interpretation Value grammatical1 (someone, loves, everyone)
#print grammatical1

Statement : NLCalculus Atom (((np // n) ⊗ n) ⊗ (((np \\ s) // np) ⊗ ((np // n) ⊗ n)) ⊢ s) := by
  Hint "In order to use the tactic `apply rst` you can enter it in the text box
  under the goal and hit \"Execute\"."
  apply rst
  apply rst
  apply ms
  · apply rts
    apply rbt
    apply rst
    apply ms
    · apply trefl
    · apply rst
      apply trefl
  · apply trefl

-- LemmaDoc NL.NLCalculus.rst as "rst" in "NLCalculus"
-- "The axiom schema Residuation Slash to Times, denoted `rst`, is a proof of `a`."

NewLemma NL.NLCalculus.rst NL.NLCalculus.ms NL.NLCalculus.rts NL.NLCalculus.rbt NL.trefl
LemmaTab "NLCalculus" -- "AdmissibleCut" "OperationalDecidability"
NewTactic apply
