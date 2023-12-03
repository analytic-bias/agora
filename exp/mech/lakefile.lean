import Lake
open Lake DSL

package «Mech» {
  -- add package configuration options here
}

@[default_target]
lean_lib «Mech» {
  -- roots := #["Mech"]
  -- add library configuration options here
}

@[default_target]
lean_exe «MechExec» {
  root := `Main
}
