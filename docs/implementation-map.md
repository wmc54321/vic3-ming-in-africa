# Implementation Map

## Launcher metadata

- `mod/ming_in_africa/descriptor.mod`: legacy in-mod descriptor with the player-facing bilingual title, semantic version, supported Victoria 3 version, tags, description, and `thumbnail.png` reference.
- `mod/ming_in_africa.mod`: repository launcher descriptor template; includes the local mod path in addition to the same public metadata.
- `mod/ming_in_africa/.metadata/metadata.json`: current launcher metadata format.
- `mod/ming_in_africa/thumbnail.png` and `.metadata/thumbnail.png`: matching launcher/legacy cover art.

The `MGN_FLAVOR_TEXT` localization key supplies Great Ming's country-selection introduction, summarizing the Nile court, its African-Chinese realm, and the choice between building a new heartland or contesting Qing legitimacy.

Peaceful unification uses Victoria 3 1.13-compatible law checks. Monarchy (including its variants), social monarchy, and corporate state form one flexible family. Both sides must be electoral or both non-electoral; landed, wealth, census, universal, and single-party voting all count as electoral and need not match one another. All other governments require an exact governance-principle match, with no distribution-of-power restriction. Concrete laws use `has_law`, while `has_law_or_variant` is reserved for laws that actually have child variants.

This document records what the code currently implements, so future agents do not need to rediscover the mod from scratch.

## External compatibility status

- Compatibility with Steam Workshop item `3464386853`, “大洋国-汉洲联省共和国,” has been investigated but is not implemented or scheduled.
- The current mod remains independently playable. Directly enabling both mod roots is not a supported combination because both provide `common/history/states/00_states.txt`, while Ming in Africa also replaces the full `common/history/states` path.
- A separate optional compatibility patch could preserve standalone play and provide a combined playset when both parent mods are enabled. This is a deferred future option and must not be started without a new explicit user decision.
- The evidence, proposed generated-patch architecture, upstream-permission concern, and test matrix are recorded in `docs/dayang-hanzhou-compatibility-plan.md`. None of the proposed compatibility files or tools currently exist.

## Core Setup

- Country tag `MGN` defines Great Ming as an unrecognized empire with primary cultures `han`, `african_han`, and `western_han`.
- Lower Egypt is the start capital and market capital; Ming-specific hub names localize the city as Yingtian Prefecture and the port as Jinghai Port.
- Africa is owned and incorporated by `MGN` at game start through generated state history.
- Egypt's non-African 1836 remnants are reassigned to the Ottomans so `EGY` does not remain as a starting African country.
- The 1836 Tibetan polity starts under direct Qing ownership but remains unincorporated: Lhasa, Ngari, and the Tibetan-owned provinces of Eastern Himalayas transfer to `CHI` with `state_type = unincorporated`. Tibetan pops, religion, homelands, and the `TIB` releasable tag are preserved. `tools/generate_initial_mod.ps1` applies the ownership/status transfer in generated state history and retargets the matching Central Asian building and pop scopes from `TIB` to `CHI`.
- Ming starts with Qing-like laws adjusted for slave trade, open migration, colonial resettlement, mercantilism, and professional navy.
- Great Ming's royal succession chain uses the same base-game Han-style portrait route as the reference Sinoverse mod: the upper half of `chinese_imperial_outfits` for robes and the lower half of `chinese_common_headgear` for round caps. The rule is identity-based rather than tied to opening character templates, so it covers current and future rulers and heirs, including children and women. Vanilla regencies first make the designated regent the current ruler with `set_character_as_ruler = yes`, so regents also inherit this route; the displaced child monarch becomes the heir and remains covered. Ordinary politicians, generals, courtiers, and republican leaders are not forced into royal dress.
- The same royal route applies to `CHI` only after it no longer has Manchu as a primary culture. Manchu-led Qing keeps the vanilla Qing imperial outfit and headgear. `common/scripted_triggers/99_mgn_clothes_triggers.txt` removes only Great Ming and post-Manchu Qing from the competing vanilla Chinese imperial/court predicates. Because `gfx/portraits/portrait_modifiers/01_clothes.txt` and `01_headgear.txt` require full virtual-path overrides, `tools/generate_portrait_compatibility.ps1` regenerates them from the current installed game files and supports a `-Check` freshness test.
- Ming starts with `line_infantry` researched so its existing 22 line-infantry battalions can be expanded and the remaining garrisons can be modernized deliberately. The opening army remains mixed—22 line infantry and 44 irregular infantry—and receives neither an automatic mass upgrade nor additional follow-on military technologies.
- Live verification of a fresh 1836 start shows 466 standing battalions in total: 74 are the deliberately scripted regional force, and 392 inherited irregular battalions are auto-aggregated into “Ming 1st Army.” The latter come from vanilla African barracks retained by the generated building history; they are not conscription capacity and are not caused by Peasant Levies.
- The accepted compatibility choice is to retain those 392 battalions and their state barracks. Automatic splitting is not implemented because history script provides no verified transfer operation for already generated combat units; reconstructing all units and barracks explicitly would enlarge the state-history compatibility surface. The player can split the default formation after starting the campaign.

## Cultures, Laws, and Economy

- Eight bridge cultures express locally rooted Sinitic communities without promoting existing regional cultures directly to primary-culture status: `african_han` (African), `western_han` (Middle Eastern), `haedong_han` (East Asian/Korean), `nanyang_han` (Southeast Asian/Bornean), `shuofang_han` (North Asian/Siberian), `tianshan_han` (Central Asian), `fusang_han` (East Asian/Japanese), and `jiaonan_han` (Southeast Asian/mainland Southeast Asian).
- Generated state history makes each bridge culture a homeland throughout its legally defined region. `african_han` covers the states in `04_subsaharan_africa.txt`; `western_han` covers `03_north_africa.txt` and `08_middle_east.txt`. The other six sets are derived directly from the matching `mgn_state_is_*_company_region` scripted trigger, so regenerating state history keeps company and homeland borders synchronized. Homelands describe the durable geographic roots of a culture rather than a company's momentary ownership and therefore persist through conquest, dissolution, and re-establishment.
- Generated African pop history adds a thin Chinese administrative or ritual presence to every starting African state. A state with a starting Government Administration receives 100 Han bureaucrats and 500 bureaucrats of its local bridge culture (`western_han` in North Africa, `african_han` in Sub-Saharan Africa); a state without one receives the same cultural counts as clergy instead, representing temples, shrines, tutors, and lineage keepers beyond the court's effective bureaucracy. Lower Egypt is the exception and receives 1,000 Han, 3,000 Western Han, and 1,000 African Han bureaucrats as the southern court's central administration. The roughly 60,000 people generated across Africa represent not only biological descendants of the original exiles but also two centuries of intermarriage, discipleship, local recruitment, and adoption into court-linked identities. `han` denotes the smaller court-registered inner lineages, while the bridge cultures denote the larger locally rooted communities. The generator derives administrative coverage from vanilla building history before rewriting ownership.
- `law_mgn_heavenly_subjecthood` is the starting citizenship variant.
- `law_mgn_huayi_unity` is the later inclusive citizenship variant.
- `law_mgn_overseas_cooperative_ownership` mirrors cooperative ownership domestically while avoiding vanilla foreign collectivization for overseas investments. It also borrows a restrained market-capital package from Laissez-Faire: `country_free_charters_add = 2`, `state_capitalists_investment_pool_efficiency_mult = 0.25`, and `country_loan_interest_rate_mult = -0.10`. The law is visible to both active Two Chinas participants so players can inspect and plan around it, but `can_enact` remains winner-only until the rival claimant has been destroyed or subordinated.
- Cooperative-ownership reverse references are overridden where needed so UI and production-method unlocks recognize the Ming variant. `common/laws/00_land_reform.txt` and `00_distribution_of_power.txt` are complete 1.13 same-name overrides whose only intended changes add People's Capital Cooperation to Collectivized Agriculture's and Anarchy's `unlocking_laws`; the earlier separate duplicate-law file was removed because live gameplay continued to use the vanilla definitions.
- Balance alternatives recorded for future tuning: a minimal version would only raise free charters from 1 to 2; a full Laissez-Faire splice with `country_loan_interest_rate_mult = -0.25`, `country_force_privatization_bool = yes`, and `country_forbid_monopoly_bool = yes` was rejected as too strong and thematically muddy.
- `law_collectivized_agriculture` retains its vanilla Socialism technology requirement and now explicitly lists `law_mgn_overseas_cooperative_ownership` beside Command Economy and Cooperative Ownership in its live `unlocking_laws` block.

### Revolutionary Committees

- `law_mgn_revolutionary_committees` is a Council Republic-only Single-Party State variant for Ming, Qing, or the current legitimate Chinese central government. Warlords, subjects, chartered companies, and countries that merely possess a Han primary culture are excluded.
- The law keeps vanilla Single-Party State legitimacy, Authority, voting, party-lock, and electoral-confidence behavior. Its additions are `country_legitimacy_govt_size_add = 2` and `+15%` political strength for both the Trade Unions and Armed Forces, representing the three-in-one committee structure.
- `common/laws/00_labour_associations.txt` is a complete Victoria 3 1.13 same-name override because a separate duplicate Factory Councils object did not replace the live definition. The only intended upstream change is in `law_factory_councils`: `unlocking_laws` includes Revolutionary Committees, and `can_enact` accepts either a revolutionary country or an enacted Revolutionary Committees law. Recompare the complete file after game updates.
- `common/laws/00_economic_system.txt` is another complete 1.13 same-name override. Its only intended upstream change is adding Revolutionary Committees to `law_command_economy.unlocking_laws`; database-level law unlock lists do not automatically recognize the variant's Single-Party State parent. Recompare the complete file after game updates.
- The variant deliberately does not satisfy Ming's higher-priority `dyn_c_ming_single_party` trigger. Council Republic plus Revolutionary Committees therefore retains `dyn_c_ming_soviet_union` (“中华苏维埃社会主义共和国联盟”); only the exact vanilla `law_single_party_state` produces “中华训政共和国.”
- `common/character_interactions/00_mgn_character_interactions.txt` adds the player-only `mgn_struggle_session`. Its active-law check is in `potential`, so it is hidden before enactment. It costs no Authority, has a shared 18-month country cooldown, may target the ruler, and always ends the target's political career.
- Ordinary targets have 50% retirement, 25% exile, and 25% death outcomes. Rulers have 50% retirement, 20% death, and 30% retirement with stronger political backlash. Every result opens a dedicated event from `events/mgn_revolutionary_committee_events.txt`; exile, death, and ruler-backlash outcomes radicalize the target's Interest Group where one exists.

## Route Journals

Implemented route journal files:

- `common/journal_entries/00_mgn_route_journal_entries.txt`
- `common/scripted_buttons/00_mgn_route_buttons.txt`
- `common/scripted_effects/00_mgn_route_effects.txt`
- `events/mgn_route_events.txt`
- `common/on_actions/00_mgn_on_actions.txt`

Player-facing journals:

- `je_mgn_two_chinas`: diplomacy and route navigation while Ming and Qing are independent rivals or one remains the other's overlord.
- `je_mgn_rebuild_state_ming`: Ming-led capital and frontier reconstruction after victory, subject hierarchy, or peaceful union.
- `je_mgn_rebuild_state_qing`: Qing-led frontier reconstruction after victory, subject hierarchy, or peaceful union.
- `je_mgn_administer_four_quarters`: shared post-unification company administration for both winners.
- `je_mgn_bitter_peace`: subject-side independence route.

The three primary panels—Two Chinas, Rebuild the State, and Administer the Four Quarters—are pinned by default. Migration and peaceful-unification buttons belong only to Two Chinas; capital and border-restoration actions belong to Rebuild the State; all eight chartered-company actions belong to Administer the Four Quarters.

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
- `MJP`: Fusang Revenue Company.
- `MSE`: Southern Seas Administration Company.

All are Chinese chartered companies with dynamic names, flags, starting law overrides, and target-region transfer effects. Every company has `han` as its first primary culture, followed by its regional bridge culture or cultures: MCC adds `african_han western_han`; MKC adds `haedong_han`; MLF adds `nanyang_han`; MSB adds `shuofang_han`; MCA adds `tianshan_han`; MJP adds `fusang_han`; and MSE adds `jiaonan_han`. MDC uses `han` alone. A one-time monthly normalization updates already-existing companies in older saves to the same order. The Siberian company scope excludes Tuva. The Fusang scope covers all ten vanilla 1.13 Japanese home-island states, including Tokai, Hokushinetsu, and Kyoto, but excludes Ryukyu. Ryukyu is part of the Interior Administration trigger and therefore transfers to MDC when that company is established from controlled territory. The Southern Seas scope covers the fifteen vanilla Indochina states from Burma through Vietnam and Malaya while excluding Borneo, which remains in the Lanfang scope.

The two rebuild journals expose only capital and border-restoration actions. Beijing and Nanjing are always visible to Ming during reconstruction; lack of full ownership makes them disabled rather than hidden. The separate `je_mgn_administer_four_quarters` journal exposes all eight company-establishment actions in geographic order and remains available so destroyed companies can be re-established. Border restoration assigns subject-held northeastern and northwestern frontier lands in the fixed priority Qing (`CHI`) → Interior Administration Company (`MDC`) → direct Ming (`MGN`) rule. Full states change owner directly from their subject state scopes rather than through nested transfer macros. Kirghizia uses the exact provinces owned by Qing in the vanilla 1836 state history, preserving the opening split with Kokand.

`common/country_formation/00_formable_countries.txt` is intentionally overridden to stop Chinese chartered companies from forming `CHI`.

## Monuments and Modifiers

- `building_mgn_forbidden_city`: buildable Yingtian Forbidden City in Lower Egypt.
- `building_mgn_nanjing_forbidden_city`: buildable after moving the capital to Nanjing.
- `mgn_heavenly_court_in_africa`: 20-year decaying early ruling-friction modifier, including an initial `-10` legitimacy penalty.
- `mgn_southern_court_administration`: 20-year decaying administrative support for the oversized African realm, starting at `+1000%` bureaucracy.
- `mgn_chinese_unification_integration_drive`: ten-year incorporation speed bonus after unification.

## Localization

Primary localization files:

- `localization/simp_chinese/mgn_l_simp_chinese.yml`
- `localization/english/mgn_l_english.yml`

Ming's eight country-specific interest-group names are assigned at game start with `set_interest_group_name`. Each custom name key has a matching `_desc` key because `InterestGroup.GetDesc` resolves the description from the active dynamic name; omitting that companion key exposes a raw placeholder in political-panel hovers.

Two of those groups also receive country-specific effect cards from `common/interest_group_traits/00_mgn_interest_group_traits.txt`. Scholar Bureaucrats use narrative replacements for the three Landowner cards while retaining their vanilla thresholds and modifiers: Gentry Relief replaces Noblesse Oblige, Patronage Networks replaces Family Ties, and Command of the Registers replaces Noble Privileges. Guild Merchants use Guild Mutual Credit and Market Ward Networks at the vanilla Petite Bourgeoisie strengths, while the hostile Guild Barriers card replaces Xenophobia's discrimination and influence penalties with `country_bureaucracy_mult = -0.1`. The other six renamed groups retain their vanilla effect cards.

Keep descriptions, tooltips, event flavor, and journal reasons aligned between both languages. Concept names may remain stable unless the user explicitly asks to rename them.

The route localization has received a player-facing tone pass: journals distinguish courts from generic “states,” company descriptions acknowledge Han as the first primary culture alongside each bridge culture, charter effects use in-world charter language while retaining mechanical clarity, and event prose avoids overt implementation language such as target-state counts or “being processed.”
