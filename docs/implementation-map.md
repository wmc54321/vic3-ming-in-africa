# Implementation Map

## Launcher metadata

- `mod/ming_in_africa/descriptor.mod`: legacy in-mod descriptor with the player-facing bilingual title, semantic version, supported Victoria 3 version, tags, description, and `thumbnail.png` reference.
- `mod/ming_in_africa.mod`: repository launcher descriptor template; includes the local mod path in addition to the same public metadata.
- `mod/ming_in_africa/.metadata/metadata.json`: current launcher metadata format.
- `mod/ming_in_africa/thumbnail.png` and `.metadata/thumbnail.png`: matching launcher/legacy cover art.

The `MGN_FLAVOR_TEXT` localization key supplies Great Ming's country-selection introduction, summarizing the Nile court, its African-Chinese realm, and the choice between building a new heartland or contesting Qing legitimacy.

Peaceful unification uses Victoria 3 1.13-compatible law checks. Monarchy (including its variants), social monarchy, and corporate state form one flexible family. Both sides must be electoral or both non-electoral; landed, wealth, census, universal, and single-party voting all count as electoral and need not match one another. All other governments require an exact governance-principle match, with no distribution-of-power restriction. Concrete laws use `has_law`, while `has_law_or_variant` is reserved for laws that actually have child variants.

This document records what the code currently implements, so future agents do not need to rediscover the mod from scratch.

## Core Setup

- Country tag `MGN` defines Great Ming as an unrecognized empire with primary cultures `han`, `african_han`, and `western_han`.
- Lower Egypt is the start capital and market capital; Ming-specific hub names localize the city as Yingtian Prefecture and the port as Jinghai Port.
- Africa is owned and incorporated by `MGN` at game start through generated state history.
- Egypt's non-African 1836 remnants are reassigned to the Ottomans so `EGY` does not remain as a starting African country.
- Ming starts with Qing-like laws adjusted for slave trade, open migration, colonial resettlement, mercantilism, and professional navy.

## Cultures, Laws, and Economy

- `african_han` and `western_han` are bridge cultures for the African and Middle Eastern heritage groups.
- Generated state history makes `african_han` a homeland culture throughout the states in `04_subsaharan_africa.txt`, and `western_han` a homeland culture throughout the states in `03_north_africa.txt` and `08_middle_east.txt`. This prevents the locally rooted bridge cultures from receiving non-homeland malaria mortality in their intended regions; ordinary `han` remains non-homeland there.
- `law_mgn_heavenly_subjecthood` is the starting citizenship variant.
- `law_mgn_huayi_unity` is the later inclusive citizenship variant.
- `law_mgn_overseas_cooperative_ownership` mirrors cooperative ownership domestically while avoiding vanilla foreign collectivization for overseas investments. It also borrows a restrained market-capital package from Laissez-Faire: `country_free_charters_add = 2`, `state_capitalists_investment_pool_efficiency_mult = 0.25`, and `country_loan_interest_rate_mult = -0.10`.
- Cooperative-ownership reverse references are overridden where needed so UI and production-method unlocks recognize the Ming variant.
- Balance alternatives recorded for future tuning: a minimal version would only raise free charters from 1 to 2; a full Laissez-Faire splice with `country_loan_interest_rate_mult = -0.25`, `country_force_privatization_bool = yes`, and `country_forbid_monopoly_bool = yes` was rejected as too strong and thematically muddy.
- `law_collectivized_agriculture` is technology-unlocked and uses an explicit `can_enact` OR gate for Command Economy, Cooperative Ownership, or `law_mgn_overseas_cooperative_ownership`. This avoids the engine's unreliable handling of modded law variants in `unlocking_laws` while preserving the intended prerequisites.

## Route Journals

Implemented route journal files:

- `common/journal_entries/00_mgn_route_journal_entries.txt`
- `common/scripted_buttons/00_mgn_route_buttons.txt`
- `common/scripted_effects/00_mgn_route_effects.txt`
- `events/mgn_route_events.txt`
- `common/on_actions/00_mgn_on_actions.txt`

Player-facing journals:

- `je_mgn_two_chinas`: route navigation while Ming and Qing both exist.
- `je_mgn_rebuild_state_ming`: Ming-led reconstruction after victory, subject hierarchy, or peaceful union.
- `je_mgn_rebuild_state_qing`: Qing-led reconstruction after victory, subject hierarchy, or peaceful union.
- `je_mgn_bitter_peace`: subject-side independence route.

## Diplomatic Plays and War Goals

- Two Chinas unification war: both sides receive unification goals, with no initial infamy.
- Brotherly Imperial Amity: forces tributary/vassal status through native subject settlement.
- Migration-policy demands: open migration, regulated migration, or closed borders, based on the initiator's current law.
- Two Chinas independence: lets a subject Chinese claimant challenge the other claimant's overlordship.

## Chartered Companies

Implemented company tags:

- `MCC`: African Revenue Company.
- `MDC`: Interior Administration Company.
- `MKC`: Eastern Tributary Revenue Company.
- `MLF`: Lanfang Revenue Company.
- `MSB`: Siberian Revenue Company.
- `MCA`: Central Asian Revenue Company.

All are Chinese chartered companies with dynamic names, flags, starting law overrides, and target-region transfer effects. The Siberian company scope includes Tuva, Outer Manchuria, Amur, and Sakhalin, so the establishment button remains available when those are the only eligible holdings.

The two rebuild journals also expose border-restoration buttons. They return subject-held northeastern and northwestern Qing frontier lands to the living Mainland Company (`MDC`), falling back to direct rule when that company does not exist. Full states change owner directly from their subject state scopes rather than through nested transfer macros. Kirghizia uses the exact provinces owned by Qing in the vanilla 1836 state history, preserving the opening split with Kokand.

`common/country_formation/00_formable_countries.txt` is intentionally overridden to stop Chinese chartered companies from forming `CHI`.

## Monuments and Modifiers

- `building_mgn_forbidden_city`: buildable Yingtian Forbidden City in Lower Egypt.
- `building_mgn_nanjing_forbidden_city`: buildable after moving the capital to Nanjing.
- `mgn_heavenly_court_in_africa`: early ruling-friction modifier.
- `mgn_southern_court_administration`: decaying administrative support for the oversized African realm.
- `mgn_chinese_unification_integration_drive`: ten-year incorporation speed bonus after unification.

## Localization

Primary localization files:

- `localization/simp_chinese/mgn_l_simp_chinese.yml`
- `localization/english/mgn_l_english.yml`

Keep descriptions, tooltips, event flavor, and journal reasons aligned between both languages. Concept names may remain stable unless the user explicitly asks to rename them.
