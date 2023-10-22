import Game.Metadata
import Game.Levels.MyNL.NL

-- World "NL"
-- Level 1
-- Title "Quantifiers - 1"

open NLCommon

-- Someone loves everyone.

#check Atom

def Value : Type := Bool

axiom Entity : Type
axiom Universal : (Entity -> Value) -> Value
axiom Existential : (Entity -> Value) -> Value
axiom LoveP : Entity -> Entity -> Value
axiom PersonP : Entity -> Value

Introduction
"
# \"Someone loves everyone.\"

test
"
