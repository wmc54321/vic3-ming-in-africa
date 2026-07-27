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

## Opening Army: Verified Behavior

- A fresh 1836 game currently shows 466 standing battalions: the scripted four regional armies contain 74 battalions, while 392 inherited irregular battalions are aggregated by the engine into a default “Ming 1st Army.” They are real standing battalions with manpower, not conscription capacity.
- The 392 battalions originate from vanilla African `building_barrack` history after building ownership is consolidated under `MGN`. This is independent of the army-model law: activating Professional Army changes the law but does not remove or split that formation.
- Keep those barracks and the 392 battalions for now. Do not add a full `replace_path` for `common/history/military_formations`, do not strip African barracks in the generator, and do not force `law_professional_army` as a workaround.
- The script API used by history files has no verified operation for redistributing already auto-generated combat units among formations. Automatic splitting would therefore require an explicit reconstruction of the units and their state barracks; that larger, compatibility-sensitive rewrite is rejected for now. Players may split the default formation manually.
- The only accepted opening-army modernization change is researched `line_infantry`; it does not automatically upgrade the inherited irregular battalions.

## Same-Name Vanilla Overrides

- `mod/ming_in_africa/common/laws/00_labour_associations.txt` is a complete Victoria 3 1.13 copy. It exists because a separate duplicate `law_factory_councils` object did not replace the live vanilla definition. The only intended change is that Factory Councils may be enacted while revolutionary or under `law_mgn_revolutionary_committees`, with the matching reverse-reference UI entry.
- `mod/ming_in_africa/common/laws/00_economic_system.txt` is likewise a complete Victoria 3 1.13 copy. Its only intended change is adding `law_mgn_revolutionary_committees` to Command Economy's `unlocking_laws`, because that database-level list does not inherit the variant's `law_single_party_state` parent.
- `mod/ming_in_africa/common/laws/00_land_reform.txt` and `00_distribution_of_power.txt` are complete Victoria 3 1.13 copies. Their only intended changes add `law_mgn_overseas_cooperative_ownership` to Collectivized Agriculture's and Anarchy's respective `unlocking_laws`; separate duplicate law objects proved unreliable in live gameplay.
- Recompare all four files with their current vanilla counterparts after every supported-game-version update. Preserve all upstream changes and reapply only the documented target blocks.

## Current Narrative Premise

Great Ming survived in Africa and rules from Lower Egypt/Yingtian at game start. It claims Chinese legitimacy against Qing, can reunify China by war or political convergence, and can later reorganize far-flung territories through Chinese chartered companies.
