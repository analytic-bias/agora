import Lake
open Lake DSL

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.1.0"
require Paperproof from git "https://github.com/Paper-Proof/paperproof.git"@"main"/"lean"

package «NL» {
  -- add package configuration options here
}

@[default_target]
lean_lib «NL» {
  -- add library configuration options here
  -- roots := #["NLLib"]
}

lean_exe «NLExec» {
  root := `Main
}
