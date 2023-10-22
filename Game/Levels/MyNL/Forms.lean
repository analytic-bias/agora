namespace NL

variable (atom : Type)

inductive NLType where
| atom : atom -> NLType
| slash : NLType -> NLType -> NLType
| backslash : NLType -> NLType -> NLType
| times : NLType -> NLType -> NLType

infixr:2 "//" => NLType.slash
infixr:2 "\\\\" => NLType.backslash
infixl:1 "⊗" => NLType.times
prefix:max "!" => NLType.atom

inductive NLJudgement where
| judge : (NLType atom) -> (NLType atom) -> NLJudgement

infixr:0 "⊢" => NLJudgement.judge

inductive NL : (NLJudgement atom) -> Type where
| ax : NL (!a ⊢ !a)
| residuation_rm : NL (b ⊢ a \\ c) -> NL (a ⊗ b ⊢ c)
| residuation_mr : NL (a ⊗ b ⊢ c) -> NL (b ⊢ a \\ c)
| residuation_lm : NL (a ⊢ c // b) -> NL (a ⊗ b ⊢ c)
| residuation_ml : NL (a ⊗ b ⊢ c) -> NL (a ⊢ c // b)
| monotonicity_times : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (a ⊗ c ⊢ b ⊗ d)
| monotonicity_slash : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (a // d ⊢ b // c)
| monotonicity_backslash : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (d \\ a ⊢ c \\ b)
end NL

open NL

