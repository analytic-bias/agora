namespace Mech

def hello := "world"

-- Copilot experment:
-- syntax tree of a generic first-order language
inductive Term (α : Type) where
  | var : Nat → Term α
  | const : α → Term α
  | app : Term α → Term α → Term α

-- syntax tree of a generic first-order language
inductive Formula (α : Type) where
  | pred : α → Array (Term α) → Formula α
  | not : Formula α → Formula α
  | and : Formula α → Formula α → Formula α
  | or : Formula α → Formula α → Formula α
  | imp : Formula α → Formula α → Formula α
  | forall : Nat → Formula α → Formula α
  | exists : Nat → Formula α → Formula α

-- syntax tree of a generic first-order language
inductive FOL (α : Type) where
  | term : Term α → FOL α
  | formula : Formula α → FOL α

-- syntax tree of a generic first-order language
inductive FOLProof (α : Type) where
  | axiom : Formula α → FOLProof α
  | assumption : Formula α → FOLProof α
  | modus_ponens :
      FOLProof α → FOLProof α → FOLProof α
  | forall_elim : Nat → Term α → Formula α → FOLProof α
  | forall_intro : Nat → Formula α → FOLProof α
  | exists_elim : Nat → Formula α → Term α → FOLProof α
  | exists_intro : Nat → Formula α → Term α → FOLProof α
  | not_not_elim : Formula α → FOLProof α
  | not_not_intro : Formula α → FOLProof α
  | not_and_elim_left : Formula α → Formula α → FOLProof α
  | not_and_elim_right : Formula α → Formula α → FOLProof α
  | not_and_intro : Formula α → Formula α → FOLProof α
  | not_or_elim : Formula α → Formula α → Formula α → FOLProof α
  | not_or_intro_left : Formula α → Formula α → FOLProof α
  | not_or_intro_right : Formula α → Formula α → FOLProof α
  | not_imp_elim_left : Formula α → Formula α → FOLProof α
  | not_imp_elim_right : Formula α → Formula α → FOLProof α

-- Γ, a generic collection of sentences, and the notions of its consistency and satisfiability (in terms of a model in the metalanguage of Lean's type theory), to be used in the proof of Gödel's completeness theorem
