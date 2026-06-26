# AGENTS.md

This directory contains the actual Victoria 3 mod files.

Keep `plan.md` in the repository root as the design record. Implement only the "初版实现范围" unless the user explicitly asks for second-phase content.

Generated files:

- `common/history/states/00_states.txt`
- `common/history/buildings/03_north_africa.txt`
- `common/history/buildings/04_subsaharan_africa.txt`
- `common/history/buildings/08_middle_east.txt`
- `common/history/pops/03_north_africa.txt`
- `common/history/pops/04_subsaharan_africa.txt`
- `common/history/pops/08_middle_east.txt`

Regenerate them with `tools/generate_initial_mod.ps1` instead of manually editing large copied history files.
