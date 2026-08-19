# Agent Handoff

This is the first file a new agent/session should read.

## Project Shape

- Repository root: project documentation, generation tools, launcher descriptor template.
- Loadable mod root: `mod/ming_in_africa`.
- Public README: keep it short and introductory.
- Design records: `docs/design-plan.md` and `docs/route-journal-design.md`.
- Implementation index: `docs/implementation-map.md`.
- External-mod compatibility research: `docs/dayang-hanzhou-compatibility-plan.md` records the investigated 1.13 Hanzhou/Dayang conflict surface and a staged compatibility-patch plan. It is a deferred, optional future feature: do not implement it unless the user explicitly reopens the decision.

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
- `mod/ming_in_africa/common/history/buildings/01_south_europe.txt`
- `mod/ming_in_africa/common/history/buildings/03_north_africa.txt`
- `mod/ming_in_africa/common/history/buildings/04_subsaharan_africa.txt`
- `mod/ming_in_africa/common/history/buildings/08_middle_east.txt`
- `mod/ming_in_africa/common/history/buildings/09_central_asia.txt`
- `mod/ming_in_africa/common/history/pops/01_south_europe.txt`
- `mod/ming_in_africa/common/history/pops/03_north_africa.txt`
- `mod/ming_in_africa/common/history/pops/04_subsaharan_africa.txt`
- `mod/ming_in_africa/common/history/pops/08_middle_east.txt`
- `mod/ming_in_africa/common/history/pops/09_central_asia.txt`

Run:

```powershell
tools\generate_initial_mod.ps1
```

or pass `-GameRoot` explicitly.

The generated `01_south_europe.txt` building and pop files are complete same-name vanilla overrides whose only intended change is retargeting Crete from the removed Egyptian tag to the Ottomans. A separate later-loading file with another `s:STATE_CRETE` block does not work: the engine reports an invalid `region_state` event-target link. Recompare these complete overrides after every supported-game-version update.

The portrait modifier overrides are also generated from the locally installed game files:

- `mod/ming_in_africa/gfx/portraits/portrait_modifiers/01_clothes.txt`
- `mod/ming_in_africa/gfx/portraits/portrait_modifiers/01_headgear.txt`

Run `tools\generate_portrait_compatibility.ps1` after every supported-game-version update, and use `-Check` to verify that the committed copies still match the current game files plus the focused Ming/post-Manchu Qing additions. Do not edit these two generated files by hand.

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

- `mod/ming_in_africa/gui/frontend/frontend_main.gui` is a complete Victoria 3 1.13 copy. Its only intended functional change replaces the selectable main-menu `.bk2` video layer with the mod's static 3840x2160 cover at `gfx/interface/illustrations/frontend/mgn_main_menu_background.dds`; the editable PNG source is under `assets/source/`. Recompare the full GUI file after every supported-game-version update and reapply only that background-layer substitution. The fixed cover intentionally ignores the vanilla main-menu image theme selector while the mod is enabled.

- `mod/ming_in_africa/gui/objective_types.gui` is a complete Victoria 3 1.13 copy. Its only intended change reduces the objective-card width from 270 to 225 pixels and the matching title width from 250 to 205, so the custom sixth “Two Chinas” objective still fits beside the five vanilla objectives and sandbox card. Recompare the full file after every supported-game-version update and reapply only those four width values.

- `mod/ming_in_africa/common/journal_entries/00_warlord_china.txt` is a complete Victoria 3 1.13 copy. Its only intended change is the `is_shown_in_lobby` predicate: vanilla advertises “Fragile Unity” to every Han- or Manchu-primary country, which incorrectly includes Great Ming, while the override limits that lobby entry to `CHI`. Great Ming and Qing instead both advertise the mod's `je_mgn_two_chinas`. Recompare the full file after every supported-game-version update.

- `common/history/states/00_states.txt` and the generated `common/history/buildings/09_central_asia.txt` / `pops/09_central_asia.txt` place the 1836 Tibetan polity under direct Qing ownership as unincorporated territory. Lhasa, Ngari, and Tibet's provinces in Eastern Himalayas transfer from `TIB` to `CHI` with `state_type = unincorporated`; Tibetan culture, religion, homelands, and releasability remain unchanged. Regenerate these files from the current game rather than editing them by hand.

- `mod/ming_in_africa/gfx/portraits/portrait_modifiers/01_clothes.txt` and `01_headgear.txt` are generated full virtual-path overrides. They add high-priority base-game portrait routes for Great Ming and for Qing after it no longer has Manchu as a primary culture: current and future rulers and heirs—including children, women, and regents whom the vanilla regency system installs as the current ruler—use the upper half of `chinese_imperial_outfits` and the lower half of `chinese_common_headgear`. The route is role/owner-based rather than tied to opening templates. Ordinary officials and republican leaders are deliberately outside its scope. `common/scripted_triggers/99_mgn_clothes_triggers.txt` excludes the same royal scopes from the vanilla Qing imperial/court routes. Manchu-led Qing remains unchanged.

- `mod/ming_in_africa/common/laws/00_labour_associations.txt` is a complete Victoria 3 1.13 copy. It exists because a separate duplicate `law_factory_councils` object did not replace the live vanilla definition. The only intended change is that Factory Councils may be enacted while revolutionary or under `law_mgn_revolutionary_committees`, with the matching reverse-reference UI entry.
- `mod/ming_in_africa/common/laws/00_economic_system.txt` is likewise a complete Victoria 3 1.13 copy. Its only intended change is adding `law_mgn_revolutionary_committees` to Command Economy's `unlocking_laws`, because that database-level list does not inherit the variant's `law_single_party_state` parent.
- `mod/ming_in_africa/common/laws/00_land_reform.txt` and `00_distribution_of_power.txt` are complete Victoria 3 1.13 copies. Their only intended changes add `law_mgn_overseas_cooperative_ownership` to Collectivized Agriculture's and Anarchy's respective `unlocking_laws`; separate duplicate law objects proved unreliable in live gameplay.
- Recompare all four files with their current vanilla counterparts after every supported-game-version update. Preserve all upstream changes and reapply only the documented target blocks.

## National Tutelage Election Handling

- `law_mgn_national_tutelage` adds `je_mgn_national_tutelage`. Martial law postpones the next election with `set_next_election_date = "9999.1.1"`; lifting it calls an election six months later. The local 1.13 script API has no verified effect for cancelling a campaign already in progress, so declaration is intentionally unavailable during an election campaign.
- Keep the journal invalidation cleanup when changing the law: it removes the martial-law modifier and variables and restores an election when the replacement law still permits voting. User-led Victoria 3 1.13 testing on 2026-08-15 confirmed enactment, declaration, save/reload persistence, lifting, and repeal, including the far-future election date. Before every release and after supported-version updates, repeat that matrix. If a supported version stops accepting or persisting the date, do not substitute a cosmetic voting modifier; re-investigate the election API first.

## Regime State-Name Lifecycle

- `common/scripted_effects/01_mgn_regime_state_names.txt` owns the fixed 24-state Revolutionary Committees/National Tutelage mapping and Lower Egypt's monarchic-capital baseline “Yingtian Imperial Residence.” Do not randomize the table or make names depend on Ming-versus-Qing starting ownership: the same geographic state under the same law must have the same name in every campaign.
- The feature marks only states it renames. On repeal, capital movement, or owner change, restore a marked state with `reset_state_name` followed by vanilla `evaluate_and_assign_state_hub_dynamic_names`; a bare reset loses culture/owner variants on Formosa, Amur, Outer Manchuria, and several selected African states. Do not reset hub names: Yingtian Prefecture and Jinghai Port are separate opening-history names.
- Keep the focused child on-actions and the gated monthly fallback in `common/on_actions/00_mgn_on_actions.txt`. The fallback is intentional because the local 1.13 code on-action evaluates vanilla dynamic names directly during owner changes and exposes no dedicated capital-change on-action; it also removes “Yingtian Imperial Residence” after a capital move. Re-test enactment, repeal, law-to-law switching, conquest, split states, capital movement, save/reload, and the `no_dynamic_naming` rule after supported-version updates.
- On 2026-08-15 the user entered Victoria 3 1.13 and accepted the current in-game state-name presentation, with no visible naming or localization defect reported. Treat this as a passed presentation check, not as a substitute for the full lifecycle matrix above; do not mark migration, split-state, cross-law, save/reload, English, or game-rule coverage complete without a specific result.

## Imperial Academy Balance and UI

- The academy system is location-bound, not country- or capital-bound. `building_mgn_imperial_academy` is the legacy save-compatible key for the Imperial Academy of the Four Seas in Lower Egypt; `building_beijing_imperial_academy` is the Metropolitan Guozijian in Beijing. Any country controlling the relevant state may construct or inherit the academy regardless of its capital. The two independent `unique = yes` buildings may coexist under one owner and their nationwide effects intentionally stack.
- Both cost 1,200 construction and, at full employment, consume 10 Paper while employing 500 Academics, 300 Clerks, and 200 Bureaucrats. Each has two fixed production-method groups: a workforce-scaled country modifier for `+1%` Education Access and workforce-scaled state modifiers for local `+2%` Peasant Education Access and `+10%` Qualifications. Keep the Lower Egypt and Beijing PM/PMG keys separate so the standard UI can label their local scopes correctly.
- The Lower Egypt names are `Four Quarters Dispatches (Nationwide)` and `Yingtian Statecraft (Lower Egypt)`; the Beijing names are `Provincial Education Directives (Nationwide)` and `Metropolitan Statecraft (Beijing)`. Reusing Peasant Education Access for both national and local scopes makes the standard UI merge them into one misleading local total, so the nationwide modifier must remain ordinary Education Access.
- Both share the Guozijian-precinct icon at `gfx/interface/icons/building_icons/building_mgn_imperial_academy.dds`; the editable source is `assets/source/building_mgn_imperial_academy.png`. Victoria 3 1.13's generated production-method hover does not consume arbitrary `pm_*_desc` localization, so scope belongs in the PM names and setting prose in the two building descriptions. Do not add a global GUI override solely to inject prose.
- The original split-scope presentation was accepted after an in-game UI check. The replacement Guozijian icon has passed only static 64x64 readability review, while the later location-only construction rules have not yet been confirmed in game. Before release, separately test construction by Ming, Qing, and a third-country owner; construction after moving the capital; conquest/inheritance; simultaneous ownership and `+2%` stacked nationwide Education Access; both local modifier sets; save/reload; icon presentation; and national, Lower Egypt, and Beijing literacy over at least two in-game years.

## Maritime Wonder Balance and UI

- `building_guangzhou_thirteen_factories` is fixed to Guangdong and `building_jinghai_maritime_exchange` to Lower Egypt. Neither checks country, culture, government, or capital, and their independent `unique = yes` definitions may coexist under one owner.
- Each costs 1,000 construction. At full employment it consumes 5 Paper and 5 Merchant Marine, employs 500 Shopkeepers, 300 Clerks, and 200 Bureaucrats, and provides workforce-scaled local `+25%` Trade Capacity and `+10%` Trade Advantage plus nationwide `+5%` Influence.
- Keep the PM/PMG keys separate. Guangzhou uses `Canton Trade (Guangdong)` and `Thirteen Factories Network (Nationwide)`; Jinghai uses `Jinghai Exchange (Lower Egypt)` and `Four Seas Network (Nationwide)`. The scope labels and building descriptions provide the normal hover presentation without a GUI override.
- Both share `gfx/interface/icons/building_icons/building_mgn_maritime_exchange.dds`, with the editable Canton-factories waterfront source at `assets/source/building_mgn_maritime_exchange.png`. The icon has passed only static 64x64 readability review; neither building has yet been confirmed in game. Before release, test both locations under Ming, Qing, and a third country; simultaneous ownership and stacked `+10%` Influence; workforce scaling; goods consumption and hiring; conquest inheritance; save/reload; both languages; and icon clarity at building-list and panel sizes.

## Kunyu Mining Company and DLC Boundary

- `common/company_types/00_mgn_companies.txt` defines the economic company `company_mgn_kunyu_mining`; do not confuse it with the eight country-tag chartered subjects. It is Ming-only, bureaucrat-owned, covers Coal, Iron, Sulfur, Lead, and Gold Mines, and unlocks from an incorporated Southern African state with a level-5 Coal or Iron Mine.
- The five-type portfolio is intentionally broader than vanilla historical companies. Keep the prosperity reward at `+5%` Minting and do not add mine throughput, construction, or tax bonuses without a fresh balance pass. Steel Mills and Explosives Factories are alternative industry-charter extensions; vanilla permits only one industry charter, so they are a player choice rather than two simultaneous grants.
- `common/prestige_goods/00_mgn_prestige_goods.txt` defines the Iron-based `prestige_good_mgn_dragon_seal_iron`. Its `has_dlc_feature = mp1_content`, `base_good = iron`, and `prestige_bonus = 0.1` fields match vanilla Oregrounds Iron and Russia Iron. The `0.1` value is a prestige-good coefficient, not a flat `+10%` national Prestige modifier.
- Keep `possible_prestige_goods = { prestige_good_mgn_dragon_seal_iron }` on the company and do not add `prestige_goods_trigger`, a journal, or unlock variables. With no custom trigger, the engine automatically enables the historical company-specific good when the Directorate first reaches 100 Prosperity; the enabled production then remains permanent for that company. Generic prestige-good journals solve a different cross-company unlock problem and are not a template for this brand.
- Keep prestige-good activation distinct from the Directorate's prosperity modifier. `+5%` Minting activates at 100 Prosperity and deactivates below 75, while Dragon-Seal Bar Iron remains enabled after its first activation. The base company itself has no mandatory DLC gate; the prestige good and industry-charter extension require the Charters of Commerce feature.
- Game icons are the 256x256 DXT5 files `gfx/interface/icons/company_icons/historical_company_icons/company_mgn_kunyu_mining.dds` and `gfx/interface/icons/goods_icons/prestige_goods/mgn_dragon_seal_iron_prestige.dds`; editable sources live under `assets/source/`. The user selected the first generated compositions after later five-claw and corner-fitting redraws proved visually weaker; do not replace them with those rejected candidates. Preserve true transparency. Before release, test company visibility only for Ming, the level-5 unlock, headquarters choice, all five base buildings, one-of-two industry charters with and without Charters of Commerce, the 100/75 Minting thresholds, automatic and permanent Dragon-Seal Bar Iron activation at 100 Prosperity, market display and default prestige-good effects, both localizations, save/reload, and small-size icon clarity.

## Current Narrative Premise

Great Ming survived in Africa and rules from Lower Egypt/Yingtian at game start. It claims Chinese legitimacy against Qing, can reunify China by war or political convergence, and can later reorganize far-flung territories through Chinese chartered companies.
