# Agent Handoff

This is the first file a new agent/session should read.

## Project Shape

- Repository root: project documentation, generation tools, launcher descriptor template.
- Loadable mod root: `mod/ming_in_africa`.
- Public README: keep it short and introductory.
- Design records: `docs/design-plan.md` and `docs/route-journal-design.md`.
- Implementation index: `docs/implementation-map.md`.

## Local Environment

Do not hard-code a developer's Victoria 3 install path in docs or scripts.

Use `.env.local` for machine-specific paths:

```text
VICTORIA3_GAME_ROOT=<Victoria 3>/game
```

`.env.local` is intentionally ignored by git. `.env.example` shows the expected format.

## Generated Files

Regenerate these instead of hand-editing large copied vanilla history files:

- `mod/ming_in_africa/common/history/states/00_states.txt`
- `mod/ming_in_africa/common/history/buildings/03_north_africa.txt`
- `mod/ming_in_africa/common/history/buildings/04_subsaharan_africa.txt`
- `mod/ming_in_africa/common/history/buildings/08_middle_east.txt`
- `mod/ming_in_africa/common/history/pops/03_north_africa.txt`
- `mod/ming_in_africa/common/history/pops/04_subsaharan_africa.txt`
- `mod/ming_in_africa/common/history/pops/08_middle_east.txt`

Run:

```powershell
tools\generate_initial_mod.ps1
```

or pass `-GameRoot` explicitly.

## Editing Rules

- Treat localization as player-facing prose. Names of concepts, countries, laws, buttons, and time groups can stay stable; descriptions, reasons, event flavor, and tooltips should read naturally in the mod's alternate-history voice.
- Keep Chinese and English localization in sync. English can be concise, but should not become placeholder text.
- Prefer adding focused mod files under `mod/ming_in_africa/common/...` rather than broad vanilla overrides.
- Do not manually rewrite generated state/building/pop history unless the user explicitly asks for a one-off experiment.
- If vanilla files are overridden by same-name files, document why in `docs/implementation-map.md`.

## Current Narrative Premise

Great Ming survived in Africa and rules from Lower Egypt/Yingtian at game start. It claims Chinese legitimacy against Qing, can reunify China by war or political convergence, and can later reorganize far-flung territories through Chinese chartered companies.
