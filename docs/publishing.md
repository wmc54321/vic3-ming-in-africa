# Publishing Guide

This document covers the repeatable release process. It intentionally contains no machine-specific paths or credentials.

## Release gate

Before publishing:

1. Regenerate vanilla-derived history with `tools/generate_initial_mod.ps1` against the supported game version.
2. Run `tools/validate_release.ps1`.
3. Test a new game with a playset containing only this mod, in both Simplified Chinese and English.
4. Confirm the country-selection screen, one year of simulation, save/reload, route journals, scripted buttons, and diplomatic plays.
5. Review the fresh game `error.log` for errors naming `mgn_` identifiers or this mod's files.
6. Confirm `CHANGELOG.md`, all three metadata versions, and `supported_version` are current.

## GitHub release

Run:

```powershell
tools\build_release.ps1
```

This validates the project and creates `release/ming_in_africa-v<version>.zip`. The archive is the player-facing artifact; GitHub's automatically generated source archive is a development snapshot and is not the recommended manual-install download.

For a public release, commit the intended source changes, create a matching annotated tag such as `v0.1.0`, push the branch and tag, then attach the generated zip to the GitHub Release.

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
