namespace NL
variable (Atom : Type)

inductive NLType where
| atom : Atom -> NLType
| slash : NLType -> NLType -> NLType
| backslash : NLType -> NLType -> NLType
| times : NLType -> NLType -> NLType

infix:1 (priority := high) " // " => NLType.slash
infix:1 (priority := high) " \\\\ " => NLType.backslash
infix:2 (priority := high) " ⊗ " => NLType.times
prefix:max (priority := high) "!" => NLType.atom

inductive NLJudgement : Type where
| judge : (NLType Atom) -> (NLType Atom) -> NLJudgement

infix:0 " ⊢ " => NLJudgement.judge

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
def denotel (c : NLCalculus _ (a ⊢ b)) :
      (~(interpret Atom interpret_atom Value b)) -> ~(interpret Atom interpret_atom Value a) := match c with
  | NLCalculus.arefl => fun k x => k x
  | NLCalculus.rbt f => fun x => fun | (y, z) => (denotel f) (fun k => k (y, x)) z
  | NLCalculus.rtb f => fun k x => k (fun | (y, z) => (denotel f) z (y, x))
  | NLCalculus.rst f => fun x => fun | (y, z) => (denotel f) (fun k => k (x, z)) y
  | NLCalculus.rts f => fun k x => k (fun | (y, z) => (denotel f) y (x, z))
  | NLCalculus.mt f g => fun k => fun | (x, y) => deMorgan Value ((denoter f) x) ((denoter g) y) k
  | NLCalculus.mb f g => fun k k' => k (fun | (x, y) => deMorgan Value ((denoter f) x) (fun k => k ((denotel g) y)) k')
  | NLCalculus.ms f g => fun k k' => k (fun | (x, y) => deMorgan Value (fun k => k ((denotel f) x)) ((denoter g) y) k')
def denoter (c : NLCalculus _ (a ⊢ b)) :
      (interpret Atom interpret_atom Value a) -> ~~(interpret Atom interpret_atom Value b) := match c with
  | NLCalculus.arefl => fun x k => k x
  | NLCalculus.rbt f => fun | (x, y) => fun z => (denoter f) y (fun k => k (x, z))
  | NLCalculus.rtb f => fun x k => k (fun | (y , z) => (denoter f) (y , x) z)
  | NLCalculus.rst f => fun | (x, y) => fun z => (denoter f) x (fun k => k (z, y))
  | NLCalculus.rts f => fun x k => k (fun | (y , z) => (denoter f) (x, z) y)
  | NLCalculus.mt f g => fun | (x, y) => fun k => deMorgan Value ((denoter f) x) ((denoter g) y) k
  | NLCalculus.mb f g => fun k' k => k (fun | (x, y) => deMorgan Value ((denoter f) x) (fun k'' => k'' ((denotel g) y)) k')
  | NLCalculus.ms f g => fun k' k => k (fun | (x, y) => deMorgan Value (fun k'' => k'' ((denotel f) x)) ((denoter g) y) k')
end
def denote := denoter

def trefl {a : NLType Atom} : NLCalculus Atom (a ⊢ a) := match a with
  | NLType.atom _ => NLCalculus.arefl
  | NLType.times _ _ => NLCalculus.mt trefl trefl
  | NLType.backslash _ _ => NLCalculus.mb trefl trefl
  | NLType.slash _ _ => NLCalculus.ms trefl trefl

-- notation:max (priority := high) "[" a "]" => (interpret a)

-- TODO AdmissibleCut OperationalDecidability
