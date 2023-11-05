theorem t04 (p q r s : Prop) : (p -> q -> r) -> ((q -> r) -> s) -> ¬ s -> ¬ p := by
  intro h1
  intro h2
  intro h3
  have h4 := (mt h2 h3)
  have h5 := (mt h1 h4)
  assumption
