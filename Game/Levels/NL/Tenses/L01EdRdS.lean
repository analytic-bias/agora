import Game.Metadata
import Paperproof
World "NLTenses"
Level 1
Title "Tenses 1A - They had passed all exams by then."
namespace NL
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
  λ | (k , t) => k (λ | ((b , n) , s) => s (b , (fun t':Nat => t' + n) t)) -- bad inference (or is it lazy evaluation on type level?)
axiom they : [np]
axiom exams : [np]
-- def then_ : [t] := 10 -- FIXME failed to synthesize instance OfNat (interpret Atom interpa Value t) 10; why? (interpret Atom interpa Value t) ↝ 10
axiom then_ : [t]

open NLCalculus
-- ⇒ \\ b
-- ⇐ // s
def NL := NLCalculus Atom
def proof {r : Rei} : NL ((
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

Introduction
"
## \"They had passed all exams by then.\"

In this level we are going to use what was formulated previously on System $\\mathbb{NL}$ to study the mechanized parsing of the sentence above.

In case you jumped to this level or forgot them, click on the buttons in the right-side panel to review the inference rules of System $\\mathbb{NL}$.
"
-- lexer: example
notation:0 "𝕃 " a => NLCalculus Atom a
set_option pp.explicit false
set_option pp.universes false
set_option pp.notation true
/-- The goal of this level is to construct a proof of the judgement as shown below, which serves as a potential (and in this particular case, the unique) parsing of the sentence. -/
Statement {r : Rei} : 𝕃 ((
    (((np ⊗
    (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np)))) ⊗
    ((np \\ (s r)) // np)) ⊗
    np) ⊗
    ((((s (anteriorize r)) \\ (s (anteriorize r))) // t) ⊗
    t)) ⊢ s (anteriorize r)) := by
  Hint "Now start with the `apply` tactics; its usage can be found on the right too."
  Hint (hidden := true) "Sample solution can be found [here](https://analytic-bias.github.io/agora/res/PaperproofTreeNLEdRdS.pdf) if you need it."
  apply rbt
  Hint (hidden := true) "extra hint 1"
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

DefinitionDoc NL.Calculus as "𝕃"
"
𝕃
"
LemmaDoc NL.NLCalculus.arefl as "arefl" in "𝕃"
"
$$\\dfrac{\\,\\,}{\\,\\alpha:\\text{Atom}\\quad\\alpha\\vdash\\alpha\\,}(\\text{arefl} - \\text{Reflexivity for Atom})$$
"
LemmaDoc NL.NLCalculus.rbt as "rbt" in "𝕃"
"
$$\\dfrac{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rbt} - \\text{Residuation from}\\backslash\\text{ to }\\otimes)$$
"
LemmaDoc NL.NLCalculus.rtb as "rtb" in "𝕃"
"
$$\\dfrac{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}(\\text{rtb})$$
"
LemmaDoc NL.NLCalculus.rst as "rst" in "𝕃"
"
$$\\dfrac{\\,\\alpha\\vdash\\gamma/\\beta\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rst})$$
"
LemmaDoc NL.NLCalculus.rts as "rts" in "𝕃"
"
$$\\dfrac{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}{\\,\\alpha\\vdash\\gamma/\\beta\\,}(\\text{rts})$$
"
LemmaDoc NL.NLCalculus.mt as "mt" in "𝕃"
"
$$\\dfrac{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rbt})$$
"
LemmaDoc NL.NLCalculus.mb as "mb" in "𝕃"
"
$$\\dfrac{\\,\\alpha\\vdash\\beta\\quad\\gamma\\vdash\\delta\\,}{\\,\\beta\\backslash\\gamma\\vdash\\alpha\\backslash\\delta\\,}(\\text{mb})$$
"
LemmaDoc NL.NLCalculus.ms as "ms" in "𝕃"
"
$$\\dfrac{\\,\\alpha\\vdash\\beta\\quad\\gamma\\vdash\\delta\\,}{\\,\\alpha/\\delta\\vdash\\beta/\\gamma\\,}(\\text{mt})$$
"
NewDefinition NL.NLCalculus
NewLemma
NL.NLCalculus.arefl
NL.NLCalculus.rbt
NL.NLCalculus.rtb
NL.NLCalculus.rst
NL.NLCalculus.rts
NL.NLCalculus.mt
NL.NLCalculus.mb
NL.NLCalculus.ms
LemmaTab "𝕃"
TacticDoc apply
"
For an inference rule of the form
$$\\dfrac{\\,P_1,\\dots,P_n\\,}{Q}(ρ),$$
if the *goal* is $Q$, then `apply ρ` will \"argue backwards\" and replace that goal to a collection of new goals $\\{P_i\\}$.
The idea here is that if you want to prove `Q`, then by $\\rho$
it suffices to prove $\\{P_i\\}$, so you can reduce the goal to proving $\\{P_i\\}$.
"

-- TODO forward argument
-- If `t : P → Q` is a proof that $P\\implies Q$, and `h : P` is a proof of `P`,
-- then `apply t at h` will change `h` to a proof of `Q`. The idea is that if
-- you know `P` is true, then you can deduce from `t` that `Q` is true.

-- If the *goal* is `Q`, then `apply t` will \"argue backwards\" and change the
-- goal to `P`. The idea here is that if you want to prove `Q`, then by `t`
-- it suffices to prove `P`, so you can reduce the goal to proving `P`.

-- ### Example:

-- `succ_inj x y` is a proof that `succ x = succ y → x = y`.

-- So if you have a hypothesis `h : succ (a + 37) = succ (b + 42)`
-- then `apply succ_inj at h` will change `h` to `a + 37 = b + 42`.
-- You could write `apply succ_inj (a + 37) (b + 42) at h`
-- but Lean is smart enough to figure out the inputs to `succ_inj`.

-- ### Example

-- If the goal is `a * b = 7`, then `apply succ_inj` will turn the
-- goal into `succ (a * b) = succ 7`.
--

NewTactic apply
Conclusion
"
**Level passed!**
"

-- TODO put in conclusion:
noncomputable def a := denote Atom interpa Value proof ((((they , had) , passed) , exams) , (by_ , then_)) id
set_option maxRecDepth 2048
#reduce a
-- output: (PassP they exams, Nat.succ (Nat.succ then_))