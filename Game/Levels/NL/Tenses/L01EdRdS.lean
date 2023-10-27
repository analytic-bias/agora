import Game.Metadata
import Paperproof
import LeanInfer
World "NLTenses"
Level 1
Title "Tenses 1A - E-R-S"
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
-- def proof {r : Rei} : NL ((
--     (((np ⊗
--     (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np)))) ⊗
--     ((np \\ (s r)) // np)) ⊗
--     np) ⊗
--     ((((s (anteriorize r)) \\ (s (anteriorize r))) // t) ⊗
--     t)) ⊢ s (anteriorize r)) := by

Introduction
"
## \"They had passed exams by then.\"

In this level we are going to use what was formulated previously on **System** $\\mathbb{NL}$ to study the mechanized parsing of the sentence above. Please click on the `apply` button on the right-side of this page and read the introduction to theorem proving in **Lean 4**.

In the documentation you will encounter in this level, a **Remark** section usually will be technical details of the Lean language that is not directly required to complete the exercise. If you have any question about it, please ask on Zulip.
"
-- lexer: example
notation:0 "𝕃 " a => NLCalculus Atom a
set_option pp.explicit false
set_option pp.universes false
set_option pp.notation true
/-- **Exercise.** The goal of this level is to construct a proof of the judgement as shown below, which serves as a potential (and in this particular case, the unique) parsing of the sentence. -/
Statement {r : Rei} : 𝕃 ((
    (((np ⊗
    (np \\ (((s (anteriorize r)) // np) // ((np \\ (s r)) // np)))) ⊗
    ((np \\ (s r)) // np)) ⊗
    np) ⊗
    ((((s (anteriorize r)) \\ (s (anteriorize r))) // t) ⊗
    t)) ⊢ s (anteriorize r)) := by
  Hint "
Sample solution can be found by clicking the **Show more help!** button below, should you need it, as well as its Gentzen-style proof tree [on GitHub](https://analytic-bias.github.io/agora/res/PaperproofTreeNLEdRdS.pdf).
[LeanDojo](https://leandojo.org/), an GPT agent for Lean, is also available by tactic `suggest_tactics`.
"
  Hint (hidden := true) "
## Remark
In the normal interactive mode, you do not need indentation, but in **Editor Mode**, as well as any Lean program, correct indentation is mandatory.
## Sample Solution
```
apply rbt
apply rst
apply ms
· apply mb
\x20\x20· apply rst
\x20\x20\x20\x20apply rst
\x20\x20\x20\x20apply rbt
\x20\x20\x20\x20apply mb
\x20\x20\x20\x20· apply arefl
\x20\x20\x20\x20· apply ms
\x20\x20\x20\x20\x20\x20· apply ms
\x20\x20\x20\x20\x20\x20\x20\x20· apply arefl
\x20\x20\x20\x20\x20\x20\x20\x20· apply arefl
\x20\x20\x20\x20\x20\x20· apply ms
\x20\x20\x20\x20\x20\x20\x20\x20· apply mb
\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20· apply arefl
\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20· apply arefl
\x20\x20\x20\x20\x20\x20\x20\x20· apply arefl
\x20\x20· apply arefl
· apply arefl
```
"
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

DefinitionDoc NL.NLCalculus as "𝕃"
"
# 𝕃
## Remark
This symbol is an abbreviated notation for a particular technical definition in Lean; it constructs a proposition from a metavariable right after it, denoting the type of categorial grammar of the sentence to be parsed, for which a proof denotes a route of parsing, for which a proof may be supplied in Lean and checked mechanically.
"
LemmaDoc NL.NLCalculus.arefl as "arefl" in "𝕃"
"
# Reflexivity (Atoms)
$$\\dfrac{\\,\\alpha:\\text{Atom}\\,}{\\,\\alpha\\vdash\\alpha\\,}(\\text{arefl})$$
"
LemmaDoc NL.NLCalculus.rbt as "rbt" in "𝕃"
"
# Residuation from \\ to ⊗
$$\\dfrac{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rbt})$$
"
LemmaDoc NL.NLCalculus.rtb as "rtb" in "𝕃"
"
# Residuation from ⊗ to \\
$$\\dfrac{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}(\\text{rtb})$$
"
LemmaDoc NL.NLCalculus.rst as "rst" in "𝕃"
"
# Residuation from / to ⊗
$$\\dfrac{\\,\\alpha\\vdash\\gamma/\\beta\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rst})$$
"
LemmaDoc NL.NLCalculus.rts as "rts" in "𝕃"
"
# Residuation from ⊗ to /
$$\\dfrac{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}{\\,\\alpha\\vdash\\gamma/\\beta\\,}(\\text{rts})$$
"
LemmaDoc NL.NLCalculus.mt as "mt" in "𝕃"
"
# Monotonicity of ⊗
$$\\dfrac{\\,\\beta\\vdash\\alpha\\backslash\\gamma\\,}{\\,\\alpha\\otimes\\beta\\vdash\\gamma\\,}(\\text{rbt})$$
"
LemmaDoc NL.NLCalculus.mb as "mb" in "𝕃"
"
# Monotonicity of \\
$$\\dfrac{\\,\\alpha\\vdash\\beta\\quad\\gamma\\vdash\\delta\\,}{\\,\\beta\\backslash\\gamma\\vdash\\alpha\\backslash\\delta\\,}(\\text{mb})$$
"
LemmaDoc NL.NLCalculus.ms as "ms" in "𝕃"
"
# Monotonicity of /
$$\\dfrac{\\,\\alpha\\vdash\\beta\\quad\\gamma\\vdash\\delta\\,}{\\,\\alpha/\\delta\\vdash\\beta/\\gamma\\,}(\\text{mt})$$
"
LemmaDoc NL.trefl as "trefl" in "𝕃⁺"
"
# Reflexivity (General Case)
$$\\dfrac{\\,\\,}{\\,\\alpha\\vdash\\alpha\\,}(\\text{trefl} - \\text{Reflexivity})$$
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
NL.trefl
LemmaTab "𝕃"
LemmaTab "𝕃⁺"
LemmaTab "𝕃"

TacticDoc apply
"
# Tactic `apply`
Once you finished reading this documentation, please click the cross on the top-right corner of this panel, and proceed to solve the exercise in the **Exercise** panel. You may also find the helpful documentations for other ingredients to the level, such as the inference rules of **System** $\\mathbb{NL}$ under the tab **𝕃** in the **Theorems** section as well as derived rules under the tab **𝕃⁺**.

## Summary
For an inference rule of the form
$$\\dfrac{\\,P_1,\\dots,P_n\\,}{Q}(ρ),$$
if the **Goal** is $Q$, then `apply ρ` will \"argue backwards\" and replace that goal to a collection of new goals $\\{P_i\\}$.
The idea here is that if you want to prove `Q`, then by $\\rho$
it suffices to prove $\\{P_i\\}$, so you can reduce the goal to proving $\\{P_i\\}$.

## Example
Say the (sub)goal is of the form
```
𝕃 (np // a) ⊗ a ⊢ np
```
with `a` a metavariable (one can recognize a metavariable by locating their bounds in the **Objects** panel above the **Goal** panel); you may apply the inference rule `rst` (by typing `apply rst` then enter in the tactic input box), arguing backwards, to change the goal into
```
𝕃 np // a ⊢ np // a
```
which now allows you to apply `ms`, which then gives two goals in the forms of
```
𝕃 np ⊢ np
```
and
```
𝕃 a ⊢ a
```
which can then be solved respectively with
```
· apply arefl
```
and
```
· apply trefl
```

## Remarks
Here are some technical remarks.

### Directions
In future levels, you will also have the chance to use the \"forward arguing\" variant of this tactic.

### Splitting
When $n\\neq1$, there will be multiple subgoals generated from one single use of `apply`, which can then be selected and individually proven with a syntax such as
```
⋮
apply a_rule_that_has_multiple_premises
· apply first_rule_used_in_the_proof_of_the_first_premise
  apply second_rule_used_in_the_proof_of_the_first_premise
  ⋮
· apply first_rule_used_in_the_proof_of_the_second_premise
  ⋮
```
where `·` is the unicode character (following by a space as above) and can be inputted conveniently by typing backslash, period, then space in the tactic input box (under the **Goal** panel).

### Editor Mode
**Lean 4** is a (mostly) text-based language, which means most researchers work with text-based codes when using it.
To practice that, you may click on the penultimate button on the top-right corner of this page to toggle the **Editor Mode**.
One sample text-based for the example mentioned in the above section is
```
def temp : 𝕃 (np // a) ⊗ a ⊢ np := by
  apply rst
  apply ms
  · apply arefl
  · apply trefl
```
"
NewTactic apply
Conclusion
"
# **Level passed!**

## Remark **(currently the followng does not work; but the expected output is documented below)**
In case you're interested in what the semantics of the parsing route you just constructed is in human-readable form, you can enter the **Editor Mode** and execute the following command
```
noncomputable def human_readable := denote Atom interpa Value sample_proof ((((they , had) , passed) , exams) , (by_ , then_)) id
set_option maxRecDepth 2048
#reduce human_readable
```
which should give you something similar to
```
(PassP they exams, Nat.succ (Nat.succ then_))
```

Are you able to guess what that means?
"

def sample_proof : 𝕃 ((
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
