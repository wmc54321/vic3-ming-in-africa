# Ming in Africa

Initial Victoria 3 mod implementation for the "Ming in Africa" plan.

The first version intentionally focuses on loadable 1836 setup:

- New country tag `MGN`
- All African states owned and incorporated by MGN
- Lower Egypt as capital and market capital, with Ming-specific hub names
- Han, African Han, and Western Han as primary cultures
- Qing-like starting laws with slave trade, no migration controls, colonial resettlement, mercantilism, and professional navy
- Ming-specific citizenship variants: Heavenly Subjects at game start, with Sino-Barbarian Unity as a later multicultural reform
- Decaying Southern Court Administration bureaucracy boost for the oversized African realm
- Buildable Southern Forbidden City monument in the capital
- No extra Han migrant pops in Africa
- Egypt's non-African 1836 remnants are reassigned to the Ottomans so Egypt does not survive as a starting African country.

Generated history files are produced from the local Victoria 3 install by `tools/generate_initial_mod.ps1`.

For local testing from this repository, use `mod/ming_in_africa` as the mod folder. The companion `mod/ming_in_africa.mod` file is included as a launcher descriptor template; adjust `path` if copying the mod elsewhere.
