namespace NL
variable (atom : Type)

inductive NLType where
| atom : atom -> NLType
| slash : NLType -> NLType -> NLType
| backslash : NLType -> NLType -> NLType
| times : NLType -> NLType -> NLType

infixr:3 (priority := high) "/" => NLType.slash
infixr:3 (priority := high) "\\" => NLType.backslash
infixl:2 (priority := high) "⊗" => NLType.times
prefix:max (priority := high) "!" => NLType.atom

inductive NLJudgement where
| judge : (NLType atom) -> (NLType atom) -> NLJudgement

infixr:0 "⊢" => NLJudgement.judge

inductive NL : (NLJudgement atom) -> Type where
| ax : NL (!a ⊢ !a)
| residuation_rm : NL (b ⊢ a \ c) -> NL (a ⊗ b ⊢ c)
| residuation_mr : NL (a ⊗ b ⊢ c) -> NL (b ⊢ a \ c)
| residuation_lm : NL (a ⊢ c / b) -> NL (a ⊗ b ⊢ c)
| residuation_ml : NL (a ⊗ b ⊢ c) -> NL (a ⊢ c / b)
| monotonicity_times : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (a ⊗ c ⊢ b ⊗ d)
| monotonicity_slash : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (a / d ⊢ b / c)
| monotonicity_backslash : NL (a ⊢ b) -> NL (c ⊢ d) -> NL (d \ a ⊢ c \ b)
end NL

namespace NLInterpretation
open NL
variable (interpret_atom : atom -> Type) (Value : Type)
set_option quotPrecheck false
-- notation:max (priority := high) "[" a "]" => (interpret_atom a)
notation:max (priority := high) "~" a => (a -> Value)

def interpret : (NLType atom) -> Type
  | !a => interpret_atom a
  | a ⊗ b => (interpret a) × (interpret b)
  | a / b => ~((interpret a) × ~(interpret b))
  | a \ b => ~(~(interpret a) × (interpret b))

end NLInterpretation
