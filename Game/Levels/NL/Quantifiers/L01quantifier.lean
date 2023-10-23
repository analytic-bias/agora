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

-- Someone loves everyone.

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
  fun | (k, y) => k (fun | (x, k) => k (LoveP x y))
def implies (a b : Bool) : Bool := not a || b
infixr:4 "⊃" => implies
noncomputable def everyone : [(!Atom._np // !Atom._n) ⊗ !Atom._n] :=
  ((fun | (g, f) => Existential (fun x => f x ⊃ g x)), PersonP)

-- noncomputable def s := someone ⊗ loves ⊗ everyone

open NLCalculus

-- #check @rst
-- #check arefl
-- #check rst Atom
-- #check ms (mb (rst trefl) arefl) (rst trefl)

-- def g : NLCalculus Atom (((np // n) ⊗ n) ⊗ (((np // s) \\ np) ⊗ ((np // n) ⊗ n)) ⊢ s) :=
--   rbt (rst (ms (mb (rst trefl) arefl) (rst trefl)))

theorem grammatical : NLCalculus Atom (((np // n) ⊗ n) ⊗ (((np \\ s) // np) ⊗ ((np // n) ⊗ n)) ⊢ s) := by
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

#check r Atom atom_interpretation Value grammatical (someone, loves, everyone)

#print grammatical

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

-- DefinitionDoc MyNat as "ℕ"
-- "
-- `ℕ` is the natural numbers, just called \"numbers\" in this game. It's
-- defined via two rules:

-- * `0 : ℕ` (zero is a number)
-- * `succ (n : ℕ) : ℕ` (the successor of a number is a number)

-- ## Game Implementation

-- *The game uses its own copy of the natural numbers, called `MyNat` with notation `ℕ`.
-- It is distinct from the Lean natural numbers `Nat`, which should hopefully
-- never leak into the natural number game.*"
