
-- This file contains the code from the paper "Formalising
-- type-logical grammars in Agda", and was directly extracted from the
-- paper's source.
--
-- Note: because the symbol customarily used for the "left difference"
-- is unavailable in the Unicode character set, and the backslash used
-- for implication is often a reserved symbol, the source file uses a
-- different notation for the connectives: the left and right
-- implications are represented by the double arrows "⇐" and "⇒", and
-- the left and right differences are represented by the triple arrows
-- "⇚" ad "⇛".

module main where

open import Function                              using (id; flip; _∘_)
open import Data.Bool                             using (Bool; true; false; _∧_)
open import Data.Empty                            using (⊥)
open import Data.Product                          using (_×_; _,_)
open import Data.Unit                             using (⊤)
open import Reflection                            using (Term; _≟_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Relation.Nullary.Decidable            using (⌊_⌋)

module logic (Atom : Set) where

  data Type : Set where
    el           : Atom  → Type
    _⊗_ _⇒_ _⇐_  : Type  → Type  → Type
    _⊕_ _⇚_ _⇛_  : Type  → Type  → Type

  data Judgement : Set where
    _⊢_  : Type → Type → Judgement

  infix  1 LG_
  infix  2 _⊢_
  infixl 3 _[_]
  infixl 3 _[_]ᴶ
  infixr 4 _⊗_
  infixr 5 _⊕_
  infixl 6 _⇚_
  infixr 6 _⇛_
  infixr 7 _⇒_
  infixl 7 _⇐_

  data LG_ : Judgement → Set where

    ax   : ∀ {A}       →  LG el A ⊢ el A

    -- residuation and monotonicity for (⇐ , ⊗ , ⇒)
    r⇒⊗  : ∀ {A B C}   →  LG B ⊢ A ⇒ C  → LG A ⊗ B ⊢ C
    r⊗⇒  : ∀ {A B C}   →  LG A ⊗ B ⊢ C  → LG B ⊢ A ⇒ C
    r⇐⊗  : ∀ {A B C}   →  LG A ⊢ C ⇐ B  → LG A ⊗ B ⊢ C
    r⊗⇐  : ∀ {A B C}   →  LG A ⊗ B ⊢ C  → LG A ⊢ C ⇐ B

    m⊗   : ∀ {A B C D} →  LG A ⊢ B  → LG C ⊢ D  → LG A ⊗ C ⊢ B ⊗ D
    m⇒   : ∀ {A B C D} →  LG A ⊢ B  → LG C ⊢ D  → LG B ⇒ C ⊢ A ⇒ D
    m⇐   : ∀ {A B C D} →  LG A ⊢ B  → LG C ⊢ D  → LG A ⇐ D ⊢ B ⇐ C

    -- residuation and monotonicity for (⇚ , ⊕ , ⇛)
    r⇛⊕  : ∀ {A B C}   →  LG B ⇛ C ⊢ A  → LG C ⊢ B ⊕ A
    r⊕⇛  : ∀ {A B C}   →  LG C ⊢ B ⊕ A  → LG B ⇛ C ⊢ A
    r⊕⇚  : ∀ {A B C}   →  LG C ⊢ B ⊕ A  → LG C ⇚ A ⊢ B
    r⇚⊕  : ∀ {A B C}   →  LG C ⇚ A ⊢ B  → LG C ⊢ B ⊕ A

    m⊕   : ∀ {A B C D} →  LG A ⊢ B  → LG C ⊢ D  → LG A ⊕ C ⊢ B ⊕ D
    m⇛   : ∀ {A B C D} →  LG C ⊢ D  → LG A ⊢ B  → LG D ⇛ A ⊢ C ⇛ B
    m⇚   : ∀ {A B C D} →  LG A ⊢ B  → LG C ⊢ D  → LG A ⇚ D ⊢ B ⇚ C

    -- grishin distributives
    d⇛⇐  : ∀ {A B C D} →  LG A ⊗ B ⊢ C ⊕ D  → LG C ⇛ A ⊢ D ⇐ B
    d⇛⇒  : ∀ {A B C D} →  LG A ⊗ B ⊢ C ⊕ D  → LG C ⇛ B ⊢ A ⇒ D
    d⇚⇒  : ∀ {A B C D} →  LG A ⊗ B ⊢ C ⊕ D  → LG B ⇚ D ⊢ A ⇒ C
    d⇚⇐  : ∀ {A B C D} →  LG A ⊗ B ⊢ C ⊕ D  → LG A ⇚ D ⊢ C ⇐ B

  ax′ : ∀ {A} → LG A ⊢ A
  ax′ {A = el   _} = ax
  ax′ {A = _ ⊗  _} = m⊗ ax′ ax′
  ax′ {A = _ ⇐  _} = m⇐ ax′ ax′
  ax′ {A = _ ⇒  _} = m⇒ ax′ ax′
  ax′ {A = _ ⊕  _} = m⊕ ax′ ax′
  ax′ {A = _ ⇚  _} = m⇚ ax′ ax′
  ax′ {A = _ ⇛  _} = m⇛ ax′ ax′

  appl-⇒′  : ∀ {A B} → LG A ⊗ (A ⇒ B) ⊢ B
  appl-⇒′  = r⇒⊗ (m⇒ ax′ ax′)

  appl-⇐′  : ∀ {A B} → LG (B ⇐ A) ⊗ A ⊢ B
  appl-⇐′  = r⇐⊗ (m⇐ ax′ ax′)

  appl-⇛′  : ∀ {A B} → LG B ⊢ A ⊕ (A ⇛ B)
  appl-⇛′  = r⇛⊕ (m⇛ ax′ ax′)

  appl-⇚′  : ∀ {A B} → LG B ⊢ (B ⇚ A) ⊕ A
  appl-⇚′  = r⇚⊕ (m⇚ ax′ ax′)

  data Polarity : Set where + - : Polarity

  data Context (p : Polarity) : Polarity → Set where

    []    : Context p p

    _⊗>_  : Type  → Context p +  → Context p +
    _⇒>_  : Type  → Context p -  → Context p -
    _⇐>_  : Type  → Context p +  → Context p -

    _<⊗_  : Context p +  → Type  → Context p +
    _<⇒_  : Context p +  → Type  → Context p -
    _<⇐_  : Context p -  → Type  → Context p -

    _⊕>_  : Type  → Context p -  → Context p -
    _⇚>_  : Type  → Context p -  → Context p +
    _⇛>_  : Type  → Context p +  → Context p +

    _<⊕_  : Context p -  → Type  → Context p -
    _<⇚_  : Context p +  → Type  → Context p +
    _<⇛_  : Context p -  → Type  → Context p +

  data Contextᴶ (p : Polarity) : Set where

    _<⊢_  : Context p +  → Type  → Contextᴶ p
    _⊢>_  : Type  → Context p -  → Contextᴶ p

  _[_] : ∀ {p₁ p₂} → Context p₁ p₂ → Type → Type
  []        [ A ] = A
  (B ⊗> C)  [ A ] = B ⊗ (C [ A ])

  (C <⊗ B)  [ A ] = (C [ A ]) ⊗ B
  (B ⇒> C)  [ A ] = B ⇒ (C [ A ])
  (C <⇒ B)  [ A ] = (C [ A ]) ⇒ B
  (B ⇐> C)  [ A ] = B ⇐ (C [ A ])
  (C <⇐ B)  [ A ] = (C [ A ]) ⇐ B
  (B ⊕> C)  [ A ] = B ⊕ (C [ A ])
  (C <⊕ B)  [ A ] = (C [ A ]) ⊕ B
  (B ⇚> C)  [ A ] = B ⇚ (C [ A ])
  (C <⇚ B)  [ A ] = (C [ A ]) ⇚ B
  (B ⇛> C)  [ A ] = B ⇛ (C [ A ])
  (C <⇛ B)  [ A ] = (C [ A ]) ⇛ B

  _[_]ᴶ : ∀ {p} → Contextᴶ p → Type → Judgement
  (A <⊢ B) [ C ]ᴶ = A [ C ] ⊢ B
  (A ⊢> B) [ C ]ᴶ = A ⊢ B [ C ]

  module ⊗ where

    data Origin′ {B C} (J    : Contextᴶ -)
                 (f   : LG J [ B ⊗ C ]ᴶ)
                      : Set where

      origin :   ∀ {E F} (h₁  : LG E ⊢ B)
                 (h₂  : LG F ⊢ C)
                 (f′  : ∀ {G} → LG E ⊗ F ⊢ G → LG J [ G ]ᴶ)
                 (pr  : f ≡ f′ (m⊗ h₁ h₂))
                      → Origin′ J f

    mutual

      find′ : ∀ {B C} (J : Contextᴶ -) (f : LG J [ B ⊗ C ]ᴶ) → Origin′ J f
      find′ (._ ⊢> [])        (m⊗   f g)   = origin f g id refl
      find′ (._ ⊢> (A <⇐ _))  (r⊗⇐  f)     with find′ (_ ⊢> A) f
      ... | origin h₁ h₂ f′ pr rewrite pr  = origin h₁ h₂ (r⊗⇐ ∘ f′) refl
      find′ (._ ⊢> (_ ⇒> B))  (r⊗⇒  f)     with find′ (_ ⊢> B) f
      ... | origin h₁ h₂ f′ pr rewrite pr  = origin h₁ h₂ (r⊗⇒ ∘ f′) refl

      find′ ((A <⊗ _) <⊢ ._)  (m⊗  f g)  = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._)  (m⊗  f g)  = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B))  (m⇒  f g)  = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _))  (m⇒  f g)  = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B))  (m⇐  f g)  = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _))  (m⇐  f g)  = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)         (r⊗⇒ f)    = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (A <⇒ _))  (r⊗⇒ f)    = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._)  (r⇒⊗ f)    = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._)  (r⇒⊗ f)    = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)         (r⇒⊗ f)    = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)         (r⊗⇐ f)    = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B))  (r⊗⇐ f)    = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._)  (r⇐⊗ f)    = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._)  (r⇐⊗ f)    = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)         (r⇐⊗ f)    = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._)  (m⇚  f g)  = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._)  (m⇚  f g)  = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._)  (m⇛  f g)  = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._)  (m⇛  f g)  = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _))  (m⊕  f g)  = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B))  (m⊕  f g)  = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)         (r⇚⊕ f)    = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B))  (r⇚⊕ f)    = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _))  (r⇚⊕ f)    = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._)  (r⊕⇚ f)    = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._)  (r⊕⇚ f)    = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)         (r⊕⇚ f)    = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)         (r⇛⊕ f)    = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B))  (r⇛⊕ f)    = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _))  (r⇛⊕ f)    = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._)  (r⊕⇛ f)    = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._)  (r⊕⇛ f)    = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)         (r⊕⇛ f)    = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._)  (d⇛⇐ f)    = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._)  (d⇛⇐ f)    = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _))  (d⇛⇐ f)    = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B))  (d⇛⇐ f)    = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._)  (d⇛⇒ f)    = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._)  (d⇛⇒ f)    = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B))  (d⇛⇒ f)    = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _))  (d⇛⇒ f)    = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._)  (d⇚⇒ f)    = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._)  (d⇚⇒ f)    = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B))  (d⇚⇒ f)    = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _))  (d⇚⇒ f)    = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._)  (d⇚⇐ f)    = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._)  (d⇚⇐ f)    = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B))  (d⇚⇐ f)    = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _))  (d⇚⇐ f)    = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
           → ( I : Contextᴶ - ) (f : LG I [ B ⊗ C ]ᴶ)
           → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
           → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

      Origin  : ∀ {A B C} (f : LG A ⊢ B ⊗ C) → Set
      Origin  f = Origin′  (_ ⊢> []) f

      find    : ∀ {A B C} (f : LG A ⊢ B ⊗ C) → Origin f
      find    f = find′    (_ ⊢> []) f

  module ⇒ where

    data Origin′ {B C} (J : Contextᴶ +) (f : LG J [ B ⇒ C ]ᴶ) : Set where
      origin : ∀ {E F}  (h₁  : LG E ⊢ B)
               (h₂  : LG C ⊢ F)
               (f′  : ∀ {G} → LG G ⊢ E ⇒ F → LG J [ G ]ᴶ)
               (pr  : f ≡ f′ (m⇒ h₁ h₂))
                    → Origin′ J f

    mutual
      find′ : ∀ {B C} (J : Contextᴶ +) (f : LG J [ B ⇒ C ]ᴶ) → Origin′ J f
      find′ ([] <⊢ ._)       (m⇒  f g) = origin f g id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
          → ( I : Contextᴶ + ) (f : LG I [ B ⇒ C ]ᴶ)
          → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

    Origin  : ∀ {A B C} (f : LG A ⇒ B ⊢ C) → Set
    Origin  f = Origin′  ([] <⊢ _) f

    find    : ∀ {A B C} (f : LG A ⇒ B ⊢ C) → Origin f
    find    f = find′    ([] <⊢ _) f

  module ⇐ where

    data Origin′ {B C} (J : Contextᴶ +) (f : LG J [ B ⇐ C ]ᴶ) : Set where
      origin : ∀ {E F}  (h₁  : LG B ⊢ E)
               (h₂  : LG F ⊢ C)
               (f′  : ∀ {G} → LG G ⊢ E ⇐ F → LG J [ G ]ᴶ)
               (pr  : f ≡ f′ (m⇐ h₁ h₂))
                    → Origin′ J f

    mutual
      find′ : ∀ {B C} (J : Contextᴶ +) (f : LG J [ B ⇐ C ]ᴶ) → Origin′ J f
      find′ ([] <⊢ ._)       (m⇐  f g) = origin f g id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
          → ( I : Contextᴶ + ) (f : LG I [ B ⇐ C ]ᴶ)
          → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

    Origin  : ∀ {A B C} (f : LG A ⇐ B ⊢ C) → Set
    Origin  f = Origin′  ([] <⊢ _) f

    find    : ∀ {A B C} (f : LG A ⇐ B ⊢ C) → Origin f
    find    f = find′    ([] <⊢ _) f

  module ⊕ where

    data Origin′ {B C} (J : Contextᴶ +) (f : LG J [ B ⊕ C ]ᴶ) : Set where
      origin : ∀ {E F}  (h₁  : LG B ⊢ E)
               (h₂  : LG C ⊢ F)
               (f′  : ∀ {G} → LG G ⊢ E ⊕ F → LG J [ G ]ᴶ)
               (pr  : f ≡ f′ (m⊕ h₁ h₂))
                    → Origin′ J f
    mutual
      find′ : ∀ {B C} (J : Contextᴶ +) (f : LG J [ B ⊕ C ]ᴶ) → Origin′ J f
      find′ ([] <⊢ ._)       (m⊕  f g) = origin f g id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
          → ( I : Contextᴶ + ) (f : LG I [ B ⊕ C ]ᴶ)
          → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

    Origin  : ∀ {A B C} (f : LG A ⊕ B ⊢ C) → Set
    Origin  f = Origin′  ([] <⊢ _) f

    find    : ∀ {A B C} (f : LG A ⊕ B ⊢ C) → Origin f
    find    f = find′    ([] <⊢ _) f

  module ⇚ where

    data Origin′ {B C} (J : Contextᴶ -) (f : LG J [ B ⇚ C ]ᴶ) : Set where
      origin : ∀ {E F}  (h₁  : LG E ⊢ B)
               (h₂  : LG C ⊢ F)
               (f′  : ∀ {G} → LG E ⇚ F ⊢ G → LG J [ G ]ᴶ)
               (pr  : f ≡ f′ (m⇚ h₁ h₂))
                    → Origin′ J f

    mutual
      find′ : ∀ {B C} (J : Contextᴶ -) (f : LG J [ B ⇚ C ]ᴶ) → Origin′ J f
      find′ (._ ⊢> [])       (m⇚  f g) = origin f g id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
          → ( I : Contextᴶ - ) (f : LG I [ B ⇚ C ]ᴶ)
          → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

    Origin  : ∀ {A B C} (f : LG A ⊢ B ⇚ C) → Set
    Origin  f = Origin′  (_ ⊢> []) f

    find    : ∀ {A B C} (f : LG A ⊢ B ⇚ C) → Origin f
    find    f = find′    (_ ⊢> []) f

  module ⇛ where

    data Origin′ {B C} (J : Contextᴶ -) (f : LG J [ B ⇛ C ]ᴶ) : Set where
      origin : ∀ {E F}  (h₁   : LG B ⊢ E)
               (h₂   : LG F ⊢ C)
               (f′   : ∀ {G} → LG E ⇛ F ⊢ G → LG J [ G ]ᴶ)
               (pr   : f ≡ f′ (m⇛ h₁ h₂))
                     → Origin′ J f

    mutual
      find′ : ∀ {B C} (J : Contextᴶ -) (f : LG J [ B ⇛ C ]ᴶ) → Origin′ J f
      find′ (._ ⊢> [])       (m⇛  f g) = origin f g id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B C}
          → ( I : Contextᴶ - ) (f : LG I [ B ⇛ C ]ᴶ)
          → { J : Contextᴶ - } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I f {J} g with find′ I f
        ... | origin h₁ h₂ f′ pr rewrite pr = origin h₁ h₂ (g ∘ f′) refl

    Origin  : ∀ {A B C} (f : LG A ⊢ B ⇛ C) → Set
    Origin  f = Origin′  (_ ⊢> []) f

    find    : ∀ {A B C} (f : LG A ⊢ B ⇛ C) → Origin f
    find    f = find′    (_ ⊢> []) f

  module el where

    data Origin′ {B} (J : Contextᴶ +) (f : LG J [ el B ]ᴶ) : Set where
      origin :  (f′  : ∀ {G} → LG G ⊢ el B → LG J [ G ]ᴶ)
                (pr  : f ≡ f′ ax)
                     → Origin′ J f

    mutual
      find′ : ∀ {B} (J : Contextᴶ +) (f : LG J [ el B ]ᴶ) → Origin′ J f
      find′ ([] <⊢ ._)       ax        = origin id refl

      find′ ((A <⊗ _) <⊢ ._) (m⊗  f g) = go (A <⊢ _)               f (flip m⊗ g)
      find′ ((_ ⊗> B) <⊢ ._) (m⊗  f g) = go (B <⊢ _)               g (m⊗ f)
      find′ (._ ⊢> (_ ⇒> B)) (m⇒  f g) = go (_ ⊢> B)               g (m⇒ f)
      find′ (._ ⊢> (A <⇒ _)) (m⇒  f g) = go (A <⊢ _)               f (flip m⇒ g)
      find′ (._ ⊢> (_ ⇐> B)) (m⇐  f g) = go (B <⊢ _)               g (m⇐ f)
      find′ (._ ⊢> (A <⇐ _)) (m⇐  f g) = go (_ ⊢> A)               f (flip m⇐ g)
      find′ (A <⊢ ._)        (r⊗⇒ f)   = go ((_ ⊗> A) <⊢ _)        f r⊗⇒
      find′ (._ ⊢> (_ ⇒> B)) (r⊗⇒ f)   = go (_ ⊢> B)               f r⊗⇒
      find′ (._ ⊢> (A <⇒ _)) (r⊗⇒ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇒
      find′ ((_ ⊗> B) <⊢ ._) (r⇒⊗ f)   = go (B <⊢ _)               f r⇒⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇒⊗ f)   = go (_ ⊢> (A <⇒ _))        f r⇒⊗
      find′ (._ ⊢> B)        (r⇒⊗ f)   = go (_ ⊢> (_ ⇒> B))        f r⇒⊗
      find′ (A <⊢ ._)        (r⊗⇐ f)   = go ((A <⊗ _) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (_ ⇐> B)) (r⊗⇐ f)   = go ((_ ⊗> B) <⊢ _)        f r⊗⇐
      find′ (._ ⊢> (A <⇐ _)) (r⊗⇐ f)   = go (_ ⊢> A)               f r⊗⇐
      find′ ((_ ⊗> B) <⊢ ._) (r⇐⊗ f)   = go (_ ⊢> (_ ⇐> B))        f r⇐⊗
      find′ ((A <⊗ _) <⊢ ._) (r⇐⊗ f)   = go (A <⊢ _)               f r⇐⊗
      find′ (._ ⊢> B)        (r⇐⊗ f)   = go (_ ⊢> (B <⇐ _))        f r⇐⊗
      find′ ((A <⇚ _) <⊢ ._) (m⇚  f g) = go (A <⊢ _)               f (flip m⇚ g)
      find′ ((_ ⇚> B) <⊢ ._) (m⇚  f g) = go (_ ⊢> B)               g (m⇚ f)
      find′ ((A <⇛ _) <⊢ ._) (m⇛  f g) = go (_ ⊢> A)               f (flip m⇛ g)
      find′ ((_ ⇛> B) <⊢ ._) (m⇛  f g) = go (B <⊢ _)               g (m⇛ f)
      find′ (._ ⊢> (A <⊕ _)) (m⊕  f g) = go (_ ⊢> A)               f (flip m⊕ g)
      find′ (._ ⊢> (_ ⊕> B)) (m⊕  f g) = go (_ ⊢> B)               g (m⊕ f)
      find′ (A <⊢ ._)        (r⇚⊕ f)   = go ((A <⇚ _) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇚⊕ f)   = go ((_ ⇚> B) <⊢ _)        f r⇚⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇚⊕ f)   = go (_ ⊢> A)               f r⇚⊕
      find′ ((A <⇚ _) <⊢ ._) (r⊕⇚ f)   = go (A <⊢ _)               f r⊕⇚
      find′ ((_ ⇚> B) <⊢ ._) (r⊕⇚ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇚
      find′ (._ ⊢> B)        (r⊕⇚ f)   = go (_ ⊢> (B <⊕ _))        f r⊕⇚
      find′ (A <⊢ ._)        (r⇛⊕ f)   = go ((_ ⇛> A) <⊢ _)        f r⇛⊕
      find′ (._ ⊢> (_ ⊕> B)) (r⇛⊕ f)   = go (_ ⊢> B)               f r⇛⊕
      find′ (._ ⊢> (A <⊕ _)) (r⇛⊕ f)   = go ((A <⇛ _) <⊢ _)        f r⇛⊕
      find′ ((A <⇛ _) <⊢ ._) (r⊕⇛ f)   = go (_ ⊢> (A <⊕ _))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (r⊕⇛ f)   = go (B <⊢ _)               f r⊕⇛
      find′ (._ ⊢> B)        (r⊕⇛ f)   = go (_ ⊢> (_ ⊕> B))        f r⊕⇛
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇐ f)   = go ((B <⊗ _) <⊢ _)        f d⇛⇐
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇛⇐ f)   = go (_ ⊢> (_ ⊕> A))        f d⇛⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇛⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇐
      find′ ((_ ⇛> B) <⊢ ._) (d⇛⇒ f)   = go ((_ ⊗> B) <⊢ _)        f d⇛⇒
      find′ ((A <⇛ _) <⊢ ._) (d⇛⇒ f)   = go (_ ⊢> (A <⊕ _))        f d⇛⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇛⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇛⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇛⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇛⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇒ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇒
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇒ f)   = go ((_ ⊗> A) <⊢ _)        f d⇚⇒
      find′ (._ ⊢> (_ ⇒> B)) (d⇚⇒ f)   = go (_ ⊢> (B <⊕ _))        f d⇚⇒
      find′ (._ ⊢> (A <⇒ _)) (d⇚⇒ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇒
      find′ ((_ ⇚> B) <⊢ ._) (d⇚⇐ f)   = go (_ ⊢> (_ ⊕> B))        f d⇚⇐
      find′ ((A <⇚ _) <⊢ ._) (d⇚⇐ f)   = go ((A <⊗ _) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (_ ⇐> B)) (d⇚⇐ f)   = go ((_ ⊗> B) <⊢ _)        f d⇚⇐
      find′ (._ ⊢> (A <⇐ _)) (d⇚⇐ f)   = go (_ ⊢> (A <⊕ _))        f d⇚⇐

      private
        go : ∀ {B}
          → ( I : Contextᴶ + ) (f : LG I [ el B ]ᴶ)
          → { J : Contextᴶ + } (g : ∀ {G} → LG I [ G ]ᴶ → LG J [ G ]ᴶ)
          → Origin′ J (g f)
        go I x {J} g with find′ I x
        ... | origin f pr rewrite pr = origin (g ∘ f) refl

    Origin  : ∀ {A B} (f : LG el A ⊢ B) → Set
    Origin  f = Origin′  ([] <⊢ _) f

    find    : ∀ {A B} (f : LG el A ⊢ B) → Origin f
    find    f = find′    ([] <⊢ _) f

  cut′ : ∀ {A B C} (f : LG A ⊢ B) (g : LG B ⊢ C) → LG A ⊢ C

  cut′ {B = el _ }  f  g with el.find g
  ...  | (el.origin        g′ _)  = g′ f

  cut′ {B = _ ⊗ _}  f  g with ⊗.find f
  ...  | (⊗.origin  h₁ h₂  f′ _)  = f′ (r⇐⊗ (cut′ h₁ (r⊗⇐ (r⇒⊗ (cut′ h₂ (r⊗⇒ g))))))

  cut′ {B = _ ⇐ _}  f  g with ⇐.find g
  ...  | (⇐.origin  h₁ h₂  g′ _)  = g′ (r⊗⇐ (r⇒⊗ (cut′ h₂ (r⊗⇒ (cut′ (r⇐⊗ f) h₁)))))

  cut′ {B = _ ⇒ _}  f  g with ⇒.find g
  ...  | (⇒.origin  h₁ h₂  g′ _)  = g′ (r⊗⇒ (r⇐⊗ (cut′ h₁ (r⊗⇐ (cut′ (r⇒⊗ f) h₂)))))

  cut′ {B = _ ⊕ _}  f  g with ⊕.find g
  ...  | (⊕.origin  h₁ h₂  g′ _)  = g′ (r⇚⊕ (cut′ (r⊕⇚ (r⇛⊕ (cut′ (r⊕⇛ f) h₂))) h₁))

  cut′ {B = _ ⇚ _}  f  g with ⇚.find f
  ...  | (⇚.origin  h₁ h₂  f′ _)  = f′ (r⊕⇚ (r⇛⊕ (cut′ (r⊕⇛ (cut′ h₁ (r⇚⊕ g))) h₂)))

  cut′ {B = _ ⇛ _}  f  g with ⇛.find f
  ...  | (⇛.origin  h₁ h₂  f′ _)  = f′ (r⊕⇛ (r⇚⊕ (cut′ (r⊕⇚ (cut′ h₂ (r⇛⊕ g))) h₁)))

  module translation (⌈_⌉ᴬ : Atom → Set) (R : Set) where

    infixr 9 ¬_

    ¬_ : Set → Set
    ¬ A = A → R

    ⌈_⌉ : Type → Set
    ⌈ el   A  ⌉ =        ⌈ A ⌉ᴬ
    ⌈ A ⊗  B  ⌉ =    (   ⌈ A ⌉ ×    ⌈ B ⌉)
    ⌈ A ⇒  B  ⌉ = ¬  (   ⌈ A ⌉ × ¬  ⌈ B ⌉)
    ⌈ B ⇐  A  ⌉ = ¬  (¬  ⌈ B ⌉ ×    ⌈ A ⌉)
    ⌈ B ⊕  A  ⌉ = ¬  (¬  ⌈ B ⌉ × ¬  ⌈ A ⌉)
    ⌈ B ⇚  A  ⌉ =    (   ⌈ B ⌉ × ¬  ⌈ A ⌉)
    ⌈ A ⇛  B  ⌉ =    (¬  ⌈ A ⌉ ×    ⌈ B ⌉)

    deMorgan : {A B : Set} → (¬ ¬ A) → (¬ ¬ B) → ¬ ¬ (A × B)
    deMorgan c₁ c₂ k = c₁ (λ x → c₂ (λ y → k (x , y)))

    mutual
      ⌈_⌉ᴸ : ∀ {A B} → LG A ⊢ B → ¬ ⌈ B ⌉ → ¬ ⌈ A ⌉
      ⌈_⌉ᴿ : ∀ {A B} → LG A ⊢ B → ⌈ A ⌉ → ¬ ¬ ⌈ B ⌉

      ⌈ ax       ⌉ᴸ k x  = k x
      ⌈ r⇒⊗ f    ⌉ᴸ   x  =    λ{(y , z) → ⌈ f ⌉ᴸ (λ k → k (y , x)) z}
      ⌈ r⊗⇒ f    ⌉ᴸ k x  = k (λ{(y , z) → ⌈ f ⌉ᴸ z (y , x)})
      ⌈ r⇐⊗ f    ⌉ᴸ   x  =    λ{(y , z) → ⌈ f ⌉ᴸ (λ k → k (x , z)) y}
      ⌈ r⊗⇐ f    ⌉ᴸ k x  = k (λ{(y , z) → ⌈ f ⌉ᴸ y (x , z)})
      ⌈ m⊗  f g  ⌉ᴸ k    =    λ{(x , y) → deMorgan (⌈ f ⌉ᴿ x) (⌈ g ⌉ᴿ y) k}
      ⌈ m⇒  f g  ⌉ᴸ k k′ = k (λ{(x , y) → deMorgan (⌈ f ⌉ᴿ x) (λ k → k  (⌈ g ⌉ᴸ y)) k′})
      ⌈ m⇐  f g  ⌉ᴸ k k′ = k (λ{(x , y) → deMorgan (λ k → k  (⌈ f ⌉ᴸ x)) (⌈ g ⌉ᴿ y) k′})
      ⌈ r⇛⊕ f    ⌉ᴸ k x  = k (λ{(y , z) → ⌈ f ⌉ᴸ z (y , x)})
      ⌈ r⊕⇛ f    ⌉ᴸ   x  =    λ{(y , z) → ⌈ f ⌉ᴸ (λ k → k (y , x)) z}
      ⌈ r⇚⊕ f    ⌉ᴸ k x  = k (λ{(y , z) → ⌈ f ⌉ᴸ y (x , z)})
      ⌈ r⊕⇚ f    ⌉ᴸ   x  =    λ{(y , z) → ⌈ f ⌉ᴸ (λ k → k (x , z)) y}
      ⌈ m⊕  f g  ⌉ᴸ k k′ = k (λ{(x , y) → k′ (⌈ f ⌉ᴸ x , ⌈ g ⌉ᴸ y)})
      ⌈ m⇛  f g  ⌉ᴸ k    =    λ{(x , y) → deMorgan (λ k → k (⌈ f ⌉ᴸ x)) (⌈ g ⌉ᴿ y) k}
      ⌈ m⇚  f g  ⌉ᴸ k    =    λ{(x , y) → deMorgan (⌈ f ⌉ᴿ x) (λ k → k (⌈ g ⌉ᴸ y)) k}
      ⌈ d⇛⇐ f    ⌉ᴸ k    =    λ{(x , y) → k (λ{(z , w) → ⌈ f ⌉ᴸ (λ k → k (x , z)) (y , w)})}
      ⌈ d⇛⇒ f    ⌉ᴸ k    =    λ{(x , y) → k (λ{(z , w) → ⌈ f ⌉ᴸ (λ k → k (x , w)) (z , y)})}
      ⌈ d⇚⇒ f    ⌉ᴸ k    =    λ{(x , y) → k (λ{(z , w) → ⌈ f ⌉ᴸ (λ k → k (w , y)) (z , x)})}
      ⌈ d⇚⇐ f    ⌉ᴸ k    =    λ{(x , y) → k (λ{(z , w) → ⌈ f ⌉ᴸ (λ k → k (z , y)) (x , w)})}

      ⌈ ax       ⌉ᴿ  x      k  = k x
      ⌈ r⇒⊗ f    ⌉ᴿ (x , y) z  = ⌈ f ⌉ᴿ y (λ k → k (x , z))
      ⌈ r⊗⇒ f    ⌉ᴿ  x      k  = k (λ{(y , z) → ⌈ f ⌉ᴿ (y , x) z})
      ⌈ r⇐⊗ f    ⌉ᴿ (x , y) z  = ⌈ f ⌉ᴿ x (λ k → k (z , y))
      ⌈ r⊗⇐ f    ⌉ᴿ  x      k  = k (λ{(y , z) → ⌈ f ⌉ᴿ (x , z) y})
      ⌈ m⊗  f g  ⌉ᴿ (x , y) k  = deMorgan (⌈ f ⌉ᴿ x) (⌈ g ⌉ᴿ y) k
      ⌈ m⇒  f g  ⌉ᴿ  k′     k  = k (λ{(x , y) → deMorgan (⌈ f ⌉ᴿ x) (λ k → k (⌈ g ⌉ᴸ y)) k′})
      ⌈ m⇐  f g  ⌉ᴿ  k′     k  = k (λ{(x , y) → deMorgan (λ k → k (⌈ f ⌉ᴸ x)) (⌈ g ⌉ᴿ y) k′})
      ⌈ r⇛⊕ f    ⌉ᴿ  x      k  = k (λ{(y , z) → ⌈ f ⌉ᴿ (y , x) z})
      ⌈ r⊕⇛ f    ⌉ᴿ (x , y) z  = ⌈ f ⌉ᴿ y (λ k → k (x , z))
      ⌈ r⊕⇚ f    ⌉ᴿ (x , y) z  = ⌈ f ⌉ᴿ x (λ k → k (z , y))
      ⌈ r⇚⊕ f    ⌉ᴿ  x      k  = k (λ{(y , z) → ⌈ f ⌉ᴿ (x , z) y})
      ⌈ m⊕  f g  ⌉ᴿ  k′     k  = k (λ{(x , y) → k′ (⌈ f ⌉ᴸ x , ⌈ g ⌉ᴸ y)})
      ⌈ m⇛  f g  ⌉ᴿ (x , y) k  = deMorgan (λ k → k (⌈ f ⌉ᴸ x)) (⌈ g ⌉ᴿ y) k
      ⌈ m⇚  f g  ⌉ᴿ (x , y) k  = deMorgan (⌈ f ⌉ᴿ x) (λ k → k (⌈ g ⌉ᴸ y)) k
      ⌈ d⇛⇐ f    ⌉ᴿ (x , y) k  = k (λ{(z , w) → ⌈ f ⌉ᴿ (y , w) (λ k → k (x , z))})
      ⌈ d⇛⇒ f    ⌉ᴿ (x , y) k  = k (λ{(z , w) → ⌈ f ⌉ᴿ (z , y) (λ k → k (x , w))})
      ⌈ d⇚⇒ f    ⌉ᴿ (x , y) k  = k (λ{(z , w) → ⌈ f ⌉ᴿ (z , x) (λ k → k (w , y))})
      ⌈ d⇚⇐ f    ⌉ᴿ (x , y) k  = k (λ{(z , w) → ⌈ f ⌉ᴿ (x , w) (λ k → k (z , y))})

module example where

  postulate
    Entity  : Set
    forAll  : (Entity → Bool) → Bool
    exists  : (Entity → Bool) → Bool
    ʟᴏᴠᴇs   : Entity → Entity → Bool
    ᴘᴇʀsᴏɴ  : Entity → Bool

    _⊃_     : Bool → Bool → Bool

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

  someone   : ⌈ (np ⇐ n) ⊗ n ⌉
  someone   = ((λ{(g , f) → exists (λ x → f x ∧ g x)}) , ᴘᴇʀsᴏɴ)

  loves     : ⌈ (np ⇒ s) ⇐ np ⌉
  loves     = λ{(k , y) → k (λ{(x , k) → k (ʟᴏᴠᴇs x y)})}

  everyone  : ⌈ (np ⇐ n) ⊗ n ⌉
  everyone  = ((λ{(g , f) → forAll (λ x → f x ⊃ g x)}) , ᴘᴇʀsᴏɴ)

  -- open import Data.Bool                  using (Bool; true; false)
  -- open import Data.Empty                 using (⊥)
  -- open import Data.List                  using (List; _∷_; [])
  -- open import Data.String                using (String; _++_)
  -- open import Data.Unit                  using (⊤)
  -- open import Relation.Nullary.Decidable using (⌊_⌋)
  -- open import Reflection

  -- mutual
  --   dropAbs : Term → Term
  --   dropAbs (var x args)                                = var x (dropAbsArgs args)
  --   dropAbs (con c args)                                = con c (dropAbsArgs args)
  --   dropAbs (def f args)                                = def f (dropAbsArgs args)
  --   dropAbs (lam v (abs _ x))                           = lam v (abs "_" (dropAbs x))
  --   dropAbs (pi (arg i (el s₁ t₁)) (abs _ (el s₂ t₂)))  = pi (arg i (el s₁ (dropAbs t₁))) (abs "_" (el s₂ (dropAbs t₂)))
  --   dropAbs t = t

  --   dropAbsArgs : List (Arg Term) → List (Arg Term)
  --   dropAbsArgs []               = []
  --   dropAbsArgs (arg i x ∷ args) = arg i (dropAbs x) ∷ dropAbsArgs args

  -- assert : Bool → Term
  -- assert true  = def (quote ⊤) []
  -- assert false = def (quote ⊥) []

  -- infix 0 _↦_

  -- macro
  --   _↦_ : Term → Term → Term
  --   act ↦ exp = assert ⌊ dropAbs act ≟ dropAbs exp ⌋


  sᴇɴᴛ₀ sᴇɴᴛ₁ sᴇɴᴛ₂ sᴇɴᴛ₃ sᴇɴᴛ₄ sᴇɴᴛ₅ sᴇɴᴛ₆ : LG
    ( ( np ⇐ n ) ⊗ n ) ⊗ ( ( ( np ⇒ s ) ⇐ np ) ⊗ ( ( np ⇐ n ) ⊗ n ) ) ⊢ s

  sᴇɴᴛ₀  = r⇒⊗ (r⇐⊗ (m⇐ (m⇒ (r⇐⊗ ax′) ax) (r⇐⊗ ax′)))
  sᴇɴᴛ₁  = r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ (r⇐⊗ (m⇐ ax′ (r⇐⊗ ax′))))) ax))

  sᴇɴᴛ₂  = r⇒⊗ (r⇒⊗ (r⇐⊗ (m⇐ (r⊗⇒ (r⇐⊗ (m⇐ (m⇒ (r⇐⊗ ax′) ax) ax))) ax)))
  sᴇɴᴛ₃  = r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ (r⇒⊗ (r⇐⊗ (m⇐ (r⊗⇒ (r⇐⊗ ax′)) ax))))) ax))
  sᴇɴᴛ₄  = r⇒⊗ (r⇐⊗ (m⇐ (r⊗⇒ (r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ ax′)) ax)))) (r⇐⊗ ax′)))
  sᴇɴᴛ₅  = r⇒⊗ (r⇒⊗ (r⇐⊗ (m⇐ (r⊗⇒ (r⇐⊗ (m⇐ (r⊗⇒ (r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ ax′)) ax)))) ax))) ax)))
  sᴇɴᴛ₆  = r⇒⊗ (r⇒⊗ (r⇐⊗ (m⇐ (r⊗⇒ (r⊗⇒ (r⇐⊗ (r⇐⊗ (m⇐ (r⊗⇐ (r⇒⊗ (r⇐⊗ ax′))) ax))))) ax)))

  s1 = ⌈ sᴇɴᴛ₀ ⌉ᴿ (someone , loves , everyone) id

  -- sent₀  : ⌈ sᴇɴᴛ₀ ⌉ᴿ (someone , loves , everyone) id  ↦  forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ exists (λ x → ᴘᴇʀsᴏɴ x ∧ ʟᴏᴠᴇs x y))
  -- sent₁  : ⌈ sᴇɴᴛ₁ ⌉ᴿ (someone , loves , everyone) id  ↦  exists (λ x → ᴘᴇʀsᴏɴ x ∧ forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ ʟᴏᴠᴇs x y))

  -- sent₂  : ⌈ sᴇɴᴛ₂ ⌉ᴿ (someone , loves , everyone) id  ↦  forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ exists (λ x → ᴘᴇʀsᴏɴ x ∧ ʟᴏᴠᴇs x y))
  -- sent₃  : ⌈ sᴇɴᴛ₃ ⌉ᴿ (someone , loves , everyone) id  ↦  exists (λ x → ᴘᴇʀsᴏɴ x ∧ forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ ʟᴏᴠᴇs x y))
  -- sent₄  : ⌈ sᴇɴᴛ₄ ⌉ᴿ (someone , loves , everyone) id  ↦  forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ exists (λ x → ᴘᴇʀsᴏɴ x ∧ ʟᴏᴠᴇs x y))
  -- sent₅  : ⌈ sᴇɴᴛ₅ ⌉ᴿ (someone , loves , everyone) id  ↦  forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ exists (λ x → ᴘᴇʀsᴏɴ x ∧ ʟᴏᴠᴇs x y))
  -- sent₆  : ⌈ sᴇɴᴛ₆ ⌉ᴿ (someone , loves , everyone) id  ↦  forAll (λ y → ᴘᴇʀsᴏɴ y ⊃ exists (λ x → ᴘᴇʀsᴏɴ x ∧ ʟᴏᴠᴇs x y))

  -- sent₀  = _
  -- sent₁  = _
  -- sent₂  = _
  -- sent₃  = _
  -- sent₄  = _
  -- sent₅  = _
  -- sent₆  = _
