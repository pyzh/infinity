/- Setoid : universe-polymorphic -/

set_option pp.universes true
set_option pp.metavar_args false
universe variable u

/-  naming conventions:
        - names with suffix Type are types,
            with suffix Prop are properties,
            with suffix Set are setoids,
            with suffix Cat are categories.
        - additional definitions for `MyType` are in `My` namespace
-/

-- equivalence
definition EquType (El : Type) : Type := El → El → Prop

-- axioms of equivalence
section withEqu
    variables {El : Type} (Equ : EquType El)
    definition Equ.ReflProp : Prop := ∀{e : El}, Equ e e
    definition Equ.TransProp : Prop := ∀{e1 e2 e3 : El}, Equ e1 e2 → Equ e2 e3 → Equ e1 e3
    definition Equ.SymProp : Prop := ∀{e1 e2 : El}, Equ e1 e2 → Equ e2 e1
end withEqu

/-
 - Definition of the type of categories (CatType) and the category of setoids (SetoidCat)
 -/

-- the type of setoids, objects of the category `Setoid`
record SetoidType : Type :=
    (El : Type)
    (Equ : EquType El)
    (Refl : Equ.ReflProp Equ)
    (Trans : Equ.TransProp Equ)
    (Sym : Equ.SymProp Equ)
print SetoidType
abbreviation Setoid.MkOb := SetoidType.mk

-- carrier of setoid
attribute SetoidType.El [coercion]
notation `[` S `]` := SetoidType.El S        -- elements of `S`
notation a `≡` S `≡` b :10 := SetoidType.Equ S a b      -- `a=b` in `S`
notation `⊜` := SetoidType.Refl _
notation ab `⊡` S `⊡` bc :100 := SetoidType.Trans S ab bc

-- morphisms in the category `Setoid`
namespace Setoid
    record HomType (A B : SetoidType) : Type :=
        (onEl : Π(a : A), B)
        (onEqu : ∀{a1 a2 : A}, (a1 ≡_≡ a2) → (onEl a1 ≡_≡ onEl a2))
    abbreviation MkHom {A B : SetoidType} := @Setoid.HomType.mk A B
end Setoid

-- action on carrier
attribute Setoid.HomType.onEl [coercion]
infixl `$`:100 := Setoid.HomType.onEl
attribute Setoid.HomType.onEqu [coercion]
infixl `$/`:100 := Setoid.HomType.onEqu

-- hom-sets in `Setoid` category
definition Setoid.HomSet (A B : SetoidType) : SetoidType :=
    Setoid.MkOb
    /- El-/ (Setoid.HomType A B)
    /- Equ-/ ( λ(f g : Setoid.HomType A B), ∀(a : A), (f a) ≡_≡ (g a))
    /- Refl-/ ( λ f, λ a, ⊜)
    /- Trans -/ ( λ f g h, λ fg gh, λ a, (fg a) ⊡_⊡ (gh a))
    /- Sym -/ ( λ f g, λ fg, λ a, SetoidType.Sym B (fg a))

definition app_set_hom_equ {A B : SetoidType} {f g : Setoid.HomType A B}
    (eq : ∀(a : A), (f a) ≡_≡ (g a)) (a : A) : (f a) ≡_≡ (g a)
:= eq a

infixl `/$`:100 := app_set_hom_equ

-- the dedicated arrow for morphisms of setoids
infixr `⥤`:10 := Setoid.HomSet

namespace Setoid

    abbreviation MkHom2 (A B C : SetoidType)
        (onElEl : ∀(a : A), ∀(b : B), [C])
        (onElEqu : ∀(a : A), ∀{b1 b2 : B}, ∀(e : b1 ≡_≡ b2), (onElEl a b1 ≡_≡ onElEl a b2))
        (onEquEl : ∀{a1 a2 : A}, ∀(e : a1 ≡_≡ a2), ∀(b : B), (onElEl a1 b ≡_≡ onElEl a2 b))
        : A ⥤ B ⥤ C :=
        @MkHom A (B ⥤ C)
            ( λ (a : A), @MkHom B C (@onElEl a) (@onElEqu a))
            @onEquEl

    definition Mul.onElEl {A B C : SetoidType} (f : B ⥤ C) (g : A ⥤ B) : A ⥤ C :=
        MkHom
            ( λ (a : A), f $ (g $ a))
            ( λ (a1 a2 : A), λ(a12 : a1 ≡_≡ a2), f $/ (g $/ a12) )
    definition HomEquProp {A B : SetoidType} (f g : A ⥤ B) : Prop := f ≡(A ⥤ B)≡ g

    definition SubSingletonProp (S : SetoidType) : Prop := ∀(a b : S), a ≡_≡ b

    record SingletonType (S : SetoidType) : Type :=
        (center : S)
        (connect : ∀(s : S), center ≡S≡ s)

    lemma SingletonIsSub {S : SetoidType} (ok : SingletonType S) : SubSingletonProp S :=
        let okk := SingletonType.connect ok in
        λ a b, (SetoidType.Sym _ (okk a)) ⊡_⊡ ((okk b))

    abbreviation MkSingleton {S : SetoidType} := @SingletonType.mk S
end Setoid

infixl `∙`: 100 := Setoid.Mul.onElEl
infix `⥰`: 10 := Setoid.HomEquProp


-- TODO: Hom (pro)functor;
-- TODO: Sigma: (B→Type) → (E→B), UnSigma: (E→B) → (B→Type)
-- TODO: initial as limit, comma categories, cats of algebras
-- TODO: adjunctions: by isomorphism of profunctors
-- TODO: TT-like recursor, induction

-- TODO: Id(Refl) coincide with SetoidType.Equ