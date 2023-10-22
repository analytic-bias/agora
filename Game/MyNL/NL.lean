namespace NL
variable (Atom : Type)

inductive NLType where
| atom : Atom -> NLType
| slash : NLType -> NLType -> NLType
| backslash : NLType -> NLType -> NLType
| times : NLType -> NLType -> NLType

infixr:1 (priority := high) "//" => NLType.slash
infixr:1 (priority := high) "\\\\" => NLType.backslash
infixl:1 (priority := high) "⊗" => NLType.times
prefix:max (priority := high) "!" => NLType.atom

inductive NLJudgement : Type where
| judge : (NLType Atom) -> (NLType Atom) -> NLJudgement

infixr:0 "⊢" => NLJudgement.judge

inductive NLCalculus : (NLJudgement Atom) -> Type where
| arefl : NLCalculus (!a ⊢ !a)
| rbt {a b c} : NLCalculus (b ⊢ a \\ c) -> NLCalculus (a ⊗ b ⊢ c)
| rtb {a b c} : NLCalculus (a ⊗ b ⊢ c) -> NLCalculus (b ⊢ a \\ c)
| rst {a b c} : NLCalculus (a ⊢ c // b) -> NLCalculus (a ⊗ b ⊢ c)
| rts {a b c} : NLCalculus (a ⊗ b ⊢ c) -> NLCalculus (a ⊢ c // b)
| mt {a b c d} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (a ⊗ c ⊢ b ⊗ d)
| mb {a b c d} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (b \\ c ⊢ a \\ d) -- error in https://plato.stanford.edu/entries/typelogical-grammar/#LamSys
| ms {a b c d} : NLCalculus (a ⊢ b) -> NLCalculus (c ⊢ d) -> NLCalculus (a // d ⊢ b // c)

variable (interpret_atom : Atom -> Type) (Value : Type)
set_option quotPrecheck false
-- notation:max (priority := high) "[" a "]" => (interpret_atom a)
notation:max (priority := high) "~" a => (a -> Value)

def interpret : (NLType Atom) -> Type
  | !a => interpret_atom a
  | a ⊗ b => (interpret a) × (interpret b)
  | a \\ b => ~((interpret a) × (~(interpret b)))
  | a // b => ~((~(interpret a)) × (interpret b))

def deMorgan : (~~a) -> (~~b) -> ~~(a × b) := fun c1 c2 k =>
  c1 (fun x => c2 (fun y => k (x, y)))

mutual
def l (c : NLCalculus _ (a ⊢ b)) :
      (~(interpret Atom interpret_atom Value b)) -> ~(interpret Atom interpret_atom Value a) := match c with
  | NLCalculus.arefl => fun k x => k x
  | NLCalculus.rbt f => fun x => fun | (y, z) => (l f) (fun k => k (y, x)) z
  | NLCalculus.rtb f => fun k x => k (fun | (y, z) => (l f) z (y, x))
  | NLCalculus.rst f => fun x => fun | (y, z) => (l f) (fun k => k (x, z)) y
  | NLCalculus.rts f => fun k x => k (fun | (y, z) => (l f) y (x, z))
  | NLCalculus.mt f g => fun k => fun | (x, y) => deMorgan Value ((r f) x) ((r g) y) k
  | NLCalculus.mb f g => fun k k' => k (fun | (x, y) => deMorgan Value ((r f) x) (fun k => k ((l g) y)) k')
  | NLCalculus.ms f g => fun k k' => k (fun | (x, y) => deMorgan Value (fun k => k ((l f) x)) ((r g) y) k')
def r (c : NLCalculus _ (a ⊢ b)) :
      (interpret Atom interpret_atom Value a) -> ~~(interpret Atom interpret_atom Value b) := match c with
  | NLCalculus.arefl => fun x k => k x
  | NLCalculus.rbt f => fun | (x, y) => fun z => (r f) y (fun k => k (x, z))
  | NLCalculus.rtb f => fun x k => k (fun | (y , z) => (r f) (y , x) z)
  | NLCalculus.rst f => fun | (x, y) => fun z => (r f) x (fun k => k (z, y))
  | NLCalculus.rts f => fun x k => k (fun | (y , z) => (r f) (x, z) y)
  | NLCalculus.mt f g => fun | (x, y) => fun k => deMorgan Value ((r f) x) ((r g) y) k
  | NLCalculus.mb f g => fun k' k => k (fun | (x, y) => deMorgan Value ((r f) x) (fun k'' => k'' ((l g) y)) k')
  | NLCalculus.ms f g => fun k' k => k (fun | (x, y) => deMorgan Value (fun k'' => k'' ((l f) x)) ((r g) y) k')
end

def trefl {a : NLType Atom} : NLCalculus Atom (a ⊢ a) := match a with
  | NLType.atom _ => NLCalculus.arefl
  | NLType.times _ _ => NLCalculus.mt trefl trefl
  | NLType.backslash _ _ => NLCalculus.mb trefl trefl
  | NLType.slash _ _ => NLCalculus.ms trefl trefl

notation:max (priority := high) "[" a "]" => (interpret a)

-- namespace NLTacticMacro
-- open NL
-- open NLInterpretation
-- macro "arefl" : term => `(NLCalculus.arefl)
-- macro "rbt" : term => `(NLCalculus.rbt)
-- macro "rtb" : term => `(NLCalculus.rtb)
-- macro "rst" : term => `(NLCalculus.rst)
-- macro "rts" : term => `(NLCalculus.rts)
-- macro "mt" : term => `(NLCalculus.mt)
-- macro "mb" : term => `(NLCalculus.mb)
-- macro "ms" : term => `(NLCalculus.ms)
-- end NLTacticMacro

namespace AdmissibleCut

end AdmissibleCut
