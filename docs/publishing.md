# Publishing Guide

This document covers the repeatable release process. It intentionally contains no machine-specific paths or credentials.

## Release gate

Before publishing:

1. Regenerate vanilla-derived history with `tools/generate_initial_mod.ps1` against the supported game version.
2. Run `tools/validate_release.ps1`.
3. Test a new game with a playset containing only this mod, in both Simplified Chinese and English.
4. Confirm the country-selection screen, one year of simulation, save/reload, route journals, scripted buttons, and diplomatic plays. In the fresh 1836 start, verify that Ottoman Adana is a single state with its complete vanilla population and buildings, and that Ottoman Crete has 139,992 people (59,992 Turkish and 80,000 Greek) plus its vanilla Cotton Plantation, Fishing Wharf, and Port. For National Tutelage, explicitly test enactment under both Corporate State and Social Monarchy, declaration outside an election campaign, a save/reload while martial law is active, lifting after two years, the six-month restoration election, the two-year reimposition lockout, and repeal while martial law is active. For fixed regime state names, confirm opening “Yingtian Imperial Residence,” both 24-state law tables, direct law-to-law switching, repeal and vanilla-name restoration, one claimant controlling both starting realms, different laws across the Ming-Qing border, split-state and conquest transfers, capital movement away from and back to Lower Egypt, save/reload, Simplified Chinese and English, and the `no_dynamic_naming` rule. For the two imperial academies, confirm their shared Guozijian icon at building-list and panel sizes; construction in Lower Egypt and Beijing by Ming, Qing, and a third-country owner regardless of capital; conquest inheritance; simultaneous ownership; separate nationwide/local PM labels; `+2%` stacked nationwide Education Access; local `+2%` Peasant Education Access and `+10%` Qualifications in each academy state; and workforce scaling. Observe national, Lower Egypt, and Beijing literacy for at least two in-game years rather than treating a tooltip check as a balance test. For the two maritime wonders, confirm their shared waterfront icon; location-only construction in Guangdong and Lower Egypt; construction by Ming, Qing, and a third country; simultaneous ownership; separate local/nationwide PM labels; stacked `+10%` nationwide Influence; local Trade Capacity and Trade Advantage; workforce scaling; input goods, hiring, conquest inheritance, and save/reload.
5. Review the fresh game `error.log` for errors naming `mgn_` identifiers or this mod's files. Treat `Failed to scope to country by tag 'EGY'`, an invalid `region_state` link in South European history, or failures at the Crete blocks in `01_south_europe.txt` as release blockers.
6. Confirm `CHANGELOG.md`, all three metadata versions, and `supported_version` are current.

## GitHub release

Run:

```powershell
tools\build_release.ps1
```

This validates the project and creates `release/ming_in_africa-v<version>.zip`. The archive is the player-facing artifact; GitHub's automatically generated source archive is a development snapshot and is not the recommended manual-install download.

For a public release, commit the intended source changes, merge the release PR, create a matching annotated tag such as `v0.1.5` from the merged default branch, push the tag, then attach the generated zip to the GitHub Release.

## Steam Workshop

Publish the local mod through the Paradox Launcher, selecting the existing local mod whose content root is `mod/ming_in_africa`. Do not upload the repository root.

Before making the item public:

- use the copy in `docs/workshop-description.md` as the starting description;
- upload several in-game screenshots in addition to the existing thumbnail;
- select Alternative History and Gameplay tags;
- state support for Victoria 3 1.13.x and the state-history compatibility warning;
- link the GitHub repository and its issue tracker;
- accept the Steam Workshop Legal Agreement;
- first test subscription and update behavior with restricted visibility.

After Steam creates the item, keep its published item ID in launcher-managed local metadata only. Do not add credentials, absolute paths, or Steam session data to the repository.

## Updating an existing release

Increment the semantic version consistently in:

- `mod/ming_in_africa.mod`
- `mod/ming_in_africa/descriptor.mod`
- `mod/ming_in_africa/.metadata/metadata.json`

Update `CHANGELOG.md`, rerun validation and clean-playset testing, rebuild the zip, then update GitHub and the existing Workshop item rather than creating a duplicate item.
