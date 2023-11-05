import NL.NL
import NL.NLAesop
import Paperproof
namespace NL

section EdRpdS
-- Is E-R-S supposed to be encoded in the type or the term of the sentence?

-- TODO FIXME ad-hoc encoding for demo only, to be re-written in the future
inductive ReiAtom where
| _e : ReiAtom
| _r : ReiAtom
| _s : ReiAtom
inductive Rei where
| na : Rei
| reid : List ReiAtom -> Rei -- reid [_e, _r, _s] = E-R-S
inductive Atom where
| _np : Atom
| _t : Atom -- FIXME one can encode time into type instead of valuation as well: Nat -> TenseAtom
| _s : Rei -> Atom
def Value : Type := Bool × Nat -- truth × time
axiom Entity : Type
axiom PassP : Entity -> Entity -> Bool
def anteriorize : Rei -> Rei
  | Rei.reid [a, b] => Rei.reid [a, ReiAtom._r, b]
  | _ => Rei.na -- FIXME you can give it typecheck errors, but as this is only a demo we wouldn't bother
open Atom
def interpa : Atom -> Type
  -- | _n => (Entity -> Bool)
  | _np => Entity
  | _s _ => Value
  | _t => Nat -- TODO perhaps lift the time index to type?
notation:max (priority := high) "[" a "]" => (interpret Atom interpa Value a)
def np := !Atom._np
def s t := !(Atom._s t)
def t := !Atom._t
-- λ | _ ⇒ not working
noncomputable def passed : [ (np \\ (s (Rei.reid [ReiAtom._e, ReiAtom._s]))) // np ] :=
  λ | (k , y) => k λ | (x , k') => k' ((PassP x y) , 1)
-- assume had is transitive, TODO polymorphic had
noncomputable def had {r : Rei} : [ (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np))) ] :=
  λ | (x , k) => k λ | (k , y) => k λ | (t , k) => (y ((λ z => z (x , (λ | (b , n) => t (b , (n + 1))))) , k))
noncomputable def by_ {r : Rei} : [ ((s r) \\ (s r)) // t ] :=
  λ | (k , t) => k (λ | ((b , n) , s) => s (b , (fun t':Nat => t' - 1 + n) t)) -- bad inference (or is it lazy evaluation on type level?)
axiom they : [np]
axiom exams : [np]
-- def then_ : [t] := 10 -- FIXME failed to synthesize instance OfNat (interpret Atom interpa Value t) 10; why? (interpret Atom interpa Value t) ↝ 10 doesit need coercion?
axiom then_ : [t]

open NLCalculus
-- ⇒ \\ b
-- ⇐ // s
def NL := NLCalculus Atom
-- lexer: example
notation:0 "𝕃 " a => NLCalculus Atom a
set_option pp.explicit false
set_option pp.universes false
set_option pp.notation true

/-- Notice that the non-associativity is exactly the cause of ambiguity of natural languages. -/
example {r : Rei} : 𝕃 ((
    (((np ⊗
    (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np)))) ⊗
    ((np \\ (s r)) // np)) ⊗
    np) ⊗
    ((((s (anteriorize r)) \\ (s (anteriorize r))) // t) ⊗
    t)) ⊢ s (anteriorize r)) := by
  apply rbt
  apply rst
  apply ms
  · apply mb
    · apply rst
      apply rst
      apply rbt
      apply NL.trefl
    · apply NL.trefl
  · apply NL.trefl

/- w/o trefl:
  apply rbt
  apply rst
  apply ms
  · apply mb
    · apply rst
      apply rst
      apply rbt
      apply mb
      · apply arefl
      · apply ms
        · apply ms
          · apply arefl
          · apply arefl
        · apply ms
          · apply mb
            · apply arefl
            · apply arefl
          · apply arefl
    · apply arefl
  · apply arefl
-/

-- set_option trace.aesop true
def sample_proof : 𝕃 ((
    (((np ⊗
    (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np)))) ⊗
    ((np \\ (s r)) // np)) ⊗
    np) ⊗
    ((((s (anteriorize r)) \\ (s (anteriorize r))) // t) ⊗
    t)) ⊢ s (anteriorize r)) := by
  aesop? (options := { maxRuleApplications := 200 }) (rule_sets [rsNL])
noncomputable def human_readable := denote Atom interpa Value sample_proof ((((they , had) , passed) , exams) , (by_ , then_)) id
set_option maxRecDepth 2048
#reduce human_readable

end EdRpdS
