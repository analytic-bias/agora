module ling where
open import main

open import Function                              using (id; flip; _∘_)
open import Data.Bool                             using (Bool; true; false; _∧_)
open import Data.Empty                            using (⊥)
open import Data.Product                          using (_×_; _,_)
open import Data.Unit                             using (⊤)
open import Reflection                            using (Term; _≟_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Relation.Nullary.Decidable            using (⌊_⌋)

module tense where

  open import Data.Nat as Nat using (ℕ; _+_)
  import Data.List
  open import Data.List as List using (List; _∷_; [])

  postulate
    Entity  : Set
    PassP   : Entity → Entity → (Bool)
    They    : Entity
    Exams   : Entity

  data ReiAtom : Set where
    E R S : ReiAtom
  data Rei : Set where
    NA : Rei
    ReiD : (List ReiAtom) -> Rei
  data Atom : Set where
    NP T : Atom
    S : Rei -> Atom

  ⌈_⌉ᴬ : Atom → Set
  ⌈ NP  ⌉ᴬ = Entity
  ⌈ S _ ⌉ᴬ = Bool × ℕ
  ⌈ T   ⌉ᴬ = ℕ

  open logic              Atom
  open logic.translation  Atom ⌈_⌉ᴬ (Bool × ℕ)

  np t : Type
  np  = el NP
  s : Rei -> Type
  s tt = el (S tt)
  t   = el T

  anteriorize             : Rei -> Rei
  anteriorize (ReiD (a ∷ b ∷ [])) = ReiD (a ∷ R ∷ b ∷ [])
  anteriorize _           = NA
  
  passed   : ⌈ (np ⇒ (s (ReiD (E ∷ S ∷ [])))) ⇐ np ⌉
  passed   = λ{(k , y) → k λ{(x , kk) → kk ((PassP x y) , 1)}}
  
  had : {r : Rei} → ⌈ (np ⇒ (((s (anteriorize r)) ⇐ np) ⇐ ((np ⇒ (s r)) ⇐ np))) ⌉
  had = λ{(x , k) → k λ{(k , y) → k λ{(t , k) → (y ((((λ z → z ((x , (λ{(b , n) → t (b , (_+_ n 1))}))))) , k)))}}}

  by : {r : Rei} → ⌈ ((s r) ⇒ (s r)) ⇐ t ⌉
  by = λ{(k , t) → k (λ{((b , n) , s) → s (b , (_+_ t n))})}

  then : ⌈ t ⌉
  then = 10 -- an arbitrary time index
  they : ⌈ np ⌉
  they = They
  exams : ⌈ np ⌉
  exams = Exams
  
  sentence : {r : Rei} → LG ((
    (((np ⊗
    (np ⇒ (((s (anteriorize r)) ⇐ np) ⇐ ((np ⇒ (s r)) ⇐ np)))) ⊗
    ((np ⇒ (s r)) ⇐ np)) ⊗
    np) ⊗
    ((((s (anteriorize r)) ⇒ (s (anteriorize r))) ⇐ t) ⊗
    t)) ⊢ s (anteriorize r))
  sentence = r⇒⊗ (r⇐⊗ (m⇐ (m⇒ (r⇐⊗ (r⇐⊗ (r⇒⊗ (m⇒ ax (m⇐ (m⇐ ax ax) (m⇐ (m⇒ ax ax) ax)))))) ax) ax))

  out = ⌈ sentence ⌉ᴿ ((((they , had) , passed) , exams) , (by , then)) id

  -- C-c C-n tense.out -> tense.PassP tense.They tense.Exams , 12
  -- 12 = 1 + 1 + 10

module nobody where

  open import Data.Nat as Nat using (ℕ; _+_)
  import Data.List
  open import Data.List as List using (List; _∷_; [])

  postulate
    Entity  : Set
    LoveP   : Entity → Entity → (Bool)
    forAll  : (Entity → Bool) → Bool
    exists  : (Entity → Bool) → Bool
    PersonP  : Entity → Bool
    neg     : Bool → Bool
  
  data Atom : Set where N NP S : Atom

  ⌈_⌉ᴬ : Atom → Set
  ⌈ N   ⌉ᴬ = Entity → Bool
  ⌈ NP  ⌉ᴬ = Entity
  ⌈ S   ⌉ᴬ = Bool

  open logic              Atom
  open logic.translation  Atom ⌈_⌉ᴬ Bool

  n np s : Type
  n   = el N
  np  = el NP
  s   = el S
  
  nobody : ⌈ (np ⇐ n) ⊗ n ⌉
  nobody = ((λ{(g , f) → neg (exists (λ x → f x ∧ g x))}) , PersonP)

  loves : ⌈ (np ⇒ s) ⇐ np ⌉
  loves = λ{(k , y) → k (λ{(x , k) → k (LoveP x y)})}

  sent0 sent1 : LG ( ( np ⇐ n ) ⊗ n ) ⊗ ( ( ( np ⇒ s ) ⇐ np ) ⊗ ( ( np ⇐ n ) ⊗ n ) ) ⊢ s
  sent0  = r⇒⊗ (r⇐⊗ (m⇐ (m⇒ (r⇐⊗ ax′) ax) (r⇐⊗ ax′)))
  sent1  = r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ (r⇐⊗ (m⇐ ax′ (r⇐⊗ ax′))))) ax))
  
  out0 = ⌈ sent0 ⌉ᴿ (nobody , loves , nobody) id
  out1 = ⌈ sent1 ⌉ᴿ (nobody , loves , nobody) id

  -- C-c C-n nobody.out0
