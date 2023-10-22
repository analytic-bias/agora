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

inductive NLCalculus : (NLJudgement atom) -> Type where
| reflexivity : NLCalculus (!a ⊢ !a)
| residuation_rm {a b c} : NLCalculus (b ⊢ a \ c) -> NLCalculus (a ⊗ b ⊢ c)
| residuation_mr {a b c} : NLCalculus (a ⊗ b ⊢ c) -> NLCalculus (b ⊢ a \ c)
| residuation_lm {a b c} : NLCalculus (a ⊢ c / b) -> NLCalculus (a ⊗ b ⊢ c)
| residuation_ml {a b c} : NLCalculus (a ⊗ b ⊢ c) -> NLCalculus (a ⊢ c / b)
| monotonicity_times {a b c} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (a ⊗ c ⊢ b ⊗ d)
| monotonicity_backslash {a b c} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (b \ c ⊢ a \ d) -- error in https://plato.stanford.edu/entries/typelogical-grammar/#LamSys
| monotonicity_slash {a b c} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (a / d ⊢ b / c)
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
  | a \ b => ~((interpret a) × (~(interpret b)))
  | a / b => ~((~(interpret a)) × (interpret b))

def deMorgan : (~~a) -> (~~b) -> ~~(a × b) := fun c1 c2 k =>
  c1 (fun x => c2 (fun y => k (x, y)))

mutual
def l (c : NLCalculus _ (a ⊢ b)) :
      (~(interpret interpret_atom Value b)) -> ~(interpret interpret_atom Value a) := match c with
  | NLCalculus.reflexivity => fun k x => k x
  | NLCalculus.residuation_rm f => fun x => fun | (y, z) => (l f) (fun k => k (y, x)) z
  | NLCalculus.residuation_mr f => fun k x => k (fun | (y, z) => (l f) z (y, x))
  | NLCalculus.residuation_lm f => fun x => fun | (y, z) => (l f) (fun k => k (x, z)) y
  | NLCalculus.residuation_ml f => fun k x => k (fun | (y, z) => (l f) y (x, z))
  | NLCalculus.monotonicity_times f g => fun k => fun | (x, y) => deMorgan Value ((r f) x) ((r g) y) k
  | NLCalculus.monotonicity_backslash f g => fun k k' => k (fun | (x, y) => deMorgan Value ((r f) x) (fun k => k ((l g) y)) k')
  | NLCalculus.monotonicity_slash f g => fun k k' => k (fun | (x, y) => deMorgan Value (fun k => k ((l f) x)) ((r g) y) k')
def r (c : NLCalculus _ (a ⊢ b)) :
      (interpret interpret_atom Value a) -> ~~(interpret interpret_atom Value b) := match c with
  | NLCalculus.reflexivity => fun x k => k x
  | NLCalculus.residuation_rm f => fun | (x, y) => fun z => (r f) y (fun k => k (x, z))
  | NLCalculus.residuation_mr f => fun x k => k (fun | (y , z) => (r f) (y , x) z)
  | NLCalculus.residuation_lm f => fun | (x, y) => fun z => (r f) x (fun k => k (z, y))
  | NLCalculus.residuation_ml f => fun x k => k (fun | (y , z) => (r f) (x, z) y)
  | NLCalculus.monotonicity_times f g => fun | (x, y) => fun k => deMorgan Value ((r f) x) ((r g) y) k
  | NLCalculus.monotonicity_backslash f g => fun k' k => k (fun | (x, y) => deMorgan Value ((r f) x) (fun k'' => k'' ((l g) y)) k')
  | NLCalculus.monotonicity_slash f g => fun k' k => k (fun | (x, y) => deMorgan Value (fun k'' => k'' ((l f) x)) ((r g) y) k')
end

end NLInterpretation
