# Implementation Map

## Launcher metadata

- `mod/ming_in_africa/descriptor.mod`: legacy in-mod descriptor with the player-facing bilingual title, semantic version, supported Victoria 3 version, tags, description, and `thumbnail.png` reference.
- `mod/ming_in_africa.mod`: repository launcher descriptor template; includes the local mod path in addition to the same public metadata.
- `mod/ming_in_africa/.metadata/metadata.json`: current launcher metadata format.
- `mod/ming_in_africa/thumbnail.png` and `.metadata/thumbnail.png`: matching launcher/legacy cover art.

The `MGN_FLAVOR_TEXT` localization key supplies Great Ming's country-selection introduction, summarizing the Nile court, its African-Chinese realm, and the choice between building a new heartland or contesting Qing legitimacy.

## Main-menu cover art

- `gfx/interface/illustrations/frontend/mgn_main_menu_background.dds` is a 3840x2160 RGBA8 static cover showing the Ming court at its Nile capital in 1836, with African and Han officials, a working waterfront, and early industrial shipping. The composition now continues across the full width instead of using a black left field; the political focus remains on the right while the left carries lower-contrast port activity. The editable PNG source is `assets/source/mgn_main_menu_background.png`. The uncompressed DDS is intentional: the currently available Pillow build emits only a header when asked for BC3/DXT5, so release validation checks the exact RGBA8 payload size rather than accepting a corrupt compressed file.
- `gui/frontend/frontend_main.gui` is a complete Victoria 3 1.13 override whose only intended functional change replaces the dynamic `video_icon` / `FrontEndMainView.GetMainMenuImage` layer with an `icon` using the custom DDS. All standard menu controls and animations remain copied from vanilla. This intentionally makes the Ming cover fixed while the mod is enabled instead of participating in the vanilla theme selector.
- Recompare the GUI override with the supported game's `gui/frontend/frontend_main.gui` after every Victoria 3 update, preserve upstream UI changes, and reapply only the focused background-layer substitution. Static file and script validation do not replace an in-game check at 16:9 and at least one non-16:9 resolution.

## Country-selection objective

- `objective_mgn_two_chinas` adds a sixth card to the country-selection Objective screen. It is limited to the recommended tags `MGN` and `CHI`, uses a vertical crop of the main-menu painting, and presents distinct bilingual country-card copy for the Nile Ming and Asian Qing.
- Its single final subgoal attaches the existing `je_mgn_two_chinas` to the objective tracker; it does not duplicate the route logic. Resolving the journal through hierarchy or unification completes the selected objective through the engine's normal objective-subgoal association.
- `gui/objective_types.gui` is a complete Victoria 3 1.13 override whose only intended change narrows the six objective cards from 270 to 225 pixels (and their title widths from 250 to 205), allowing the six objectives plus the sandbox card to remain inside the vanilla 1700-pixel row. Recompare this file after every supported-game-version update.
- Country-selection journal hover text uses `<journal_key>_lobby`, not the in-game `<journal_key>_reason`; both Chinese and English now define `je_mgn_two_chinas_lobby` explicitly.

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
- Egypt's non-African 1836 remnants are reassigned to the Ottomans so `EGY` does not remain as a starting African country. Vanilla Adana begins split between Egypt and the Ottomans; generation merges its two province, building, and population scopes into one Ottoman state after reassignment. Crete begins wholly Egyptian, so generated complete same-name copies of the vanilla South European building and population files retarget its content to the new Ottoman owner. A rejected focused `99_mgn_egypt_remnants.txt` approach failed in live logs because a later duplicate `s:STATE_CRETE` block could not resolve `region_state:TUR`. The same-name overrides preserve the complete vanilla population composition and starting buildings instead of leaving empty transferred states.
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

### National Tutelage

- `law_mgn_national_tutelage` is the Corporate State/Social Monarchy counterpart to Revolutionary Committees. It uses the same narrow Ming, Qing, or legitimate Chinese central-government scope and excludes warlords, subjects, chartered companies, and unrelated Han-primary countries. It does not require victory in the Two Chinas struggle, cannot be imposed, and the AI does not enact it.
- The law retains vanilla Single-Party State legitimacy, Authority, voting, party-lock, and electoral-confidence behavior. Its additions are `country_legitimacy_govt_size_add = 2` and `+15%` political strength for both the Armed Forces and Petite Bourgeoisie, representing the party-army and urban party-state base. It deliberately adds no Command Economy or Factory Councils reverse unlocks.
- Enactment adds `je_mgn_national_tutelage`, a small Domestic Affairs journal with two mutually exclusive player-only buttons. Declaring nationwide martial law is blocked during an election campaign and for two years after a previous lifting; it adds `mgn_mobilization_period` (`+100` Authority and `-0.15` political-movement radicalism), enforces a two-year minimum duration, and postpones the next election to `9999.1.1`.
- Lifting martial law requires the minimum duration to have elapsed, no civil war, no brewing revolution, and no active election campaign. It removes the modifier, starts a two-year reimposition lockout, and calls an election six months later. If National Tutelage is repealed while martial law is active, the journal invalidation cleanup removes all martial-law state and calls an election in six months when the replacement law still permits elections.
- The local 1.13 script API exposes `set_next_election_date`, `call_election`, and `in_election_campaign`, but no direct cancellation of an election already in progress. The declaration button therefore never interrupts a live campaign. A user-led Victoria 3 1.13 in-game check on 2026-08-15 confirmed the current enact/declare/save-reload/lift/repeal flow, including persistence of the far-future election date across reload. This is version-specific evidence, not a permanent engine guarantee: repeat the matrix after supported-version updates and before release.

### Fixed Regime State Names

- `common/scripted_effects/01_mgn_regime_state_names.txt` defines deterministic state-region mappings for Revolutionary Committees and National Tutelage. The mapping is keyed only by the enacted law and the state's fixed `STATE_*` region, never by a random list or by whether Ming or Qing owned the land in 1836. One claimant can therefore rename only its current half of the map, while a unifier automatically applies the same table across both starting realms.
- The table covers 24 selected regions: Beijing, Nanjing, Guangdong, Henan, Hunan, Jiangxi, Xi'an, Guizhou, Formosa, Shandong, Outer Manchuria, Amur, Lower Egypt, Middle Egypt, Upper Egypt, Sinai, East Sahara, Gold Coast, Congo, South Cameroon, Kenya, Zanzibar, Cape Colony, and Transvaal. All other states retain their existing names, including conquests outside the initial Ming/Qing territory.
- Revolutionary names include Dongfanghong, Shaoshan, Jinggangshan, Yan'an, Anti-Revisionist, Central Soviet Region, Grand Alliance, Three-in-One, and Continuous Revolution. National Tutelage uses Zhongzheng, Zhongshan, Yixian, Minquan, Xijing, Guangfu, Xingzhong, Sanmin, Wuquan, and related fixed party-state toponyms. Chinese and English localization contain the complete one-to-one table.
- Lower Egypt has a third baseline name, `STATE_LOWER_EGYPT_mgn_imperial_residence` (“应天行在” / “Yingtian Imperial Residence”), while it is the capital of Ming, Qing, or the legitimate Chinese central government under Monarchy or Social Monarchy and neither special law is active. Revolutionary Committees overrides it with “中央苏区”; National Tutelage overrides it with “兴中”. Moving the capital removes the imperial-residence name on the next refresh.
- A state variable marks only names applied by this feature. Repeal, migration of the capital, or transfer to an ineligible owner resets marked state names and then calls vanilla `evaluate_and_assign_state_hub_dynamic_names`, preserving vanilla culture/owner rules on the seven selected regions that already have them. Hub names are never changed, so Yingtian Prefecture and Jinghai Port remain intact.
- Both laws refresh current states in `on_activate` and `on_deactivate`. `common/on_actions/00_mgn_on_actions.txt` also refreshes after the lobby, on state creation or owner change, and through a narrowly gated monthly fallback for Ming, Qing, the legitimate central government, active special-law users, or countries still holding a marked state. The fallback handles capital moves and any ordering difference between the mod child on-action and vanilla owner-change naming.
- The feature honors the `no_dynamic_naming` game rule: marked custom names are removed and no regime names are applied while that rule is active.
- A user-led Victoria 3 1.13 in-game inspection on 2026-08-15 confirmed that the feature loads and the current political state names display acceptably. No visible naming or localization defect was reported. This is not recorded as proof of every lifecycle branch: capital movement, cross-law borders, split-state transfers, save/reload, both languages, and `no_dynamic_naming` remain explicit release-regression cases.

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

The country-selection screen lists `je_mgn_two_chinas` as unique content for both `MGN` and `CHI`. The mod also carries a complete Victoria 3 1.13 override of `common/journal_entries/00_warlord_china.txt`: its only intended change narrows the vanilla lobby predicate for “Fragile Unity” from every Han- or Manchu-primary country to `CHI` itself. This prevents Great Ming from advertising a Qing-only journal while preserving the live Qing journal and all of its vanilla behavior. Recompare the override after every supported-game-version update.

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

## Economic Company and Prestige Good

`common/company_types/00_mgn_companies.txt` defines the Ming-only `company_mgn_kunyu_mining`, localized as 坤舆矿务总局 / Kunyu Directorate of Mines. It is a `bureaucrat_owned` flavored company with preferred headquarters in Transvaal, Cape Colony, or Lower Egypt. Its base portfolio deliberately spans Coal, Iron, Sulfur, Lead, and Gold Mines; this is broader than vanilla historical-company practice, so its prosperity modifier is restrained to `country_minting_mult = 0.05` and grants no additional mine throughput.

The company is visible only to `MGN` and becomes establishable after Ming has an incorporated Southern African state containing a level-5 Coal or Iron Mine. Gold is not part of the unlock because discovery timing is random. `building_steel_mill` and `building_explosives_factory` are listed as alternative `extension_building_types`; the vanilla industry-charter system permits only one industry charter, so the player chooses one branch rather than receiving both. AI construction targets guide Ming toward level 5 Coal and Iron Mines in Transvaal.

`common/prestige_goods/00_mgn_prestige_goods.txt` defines `prestige_good_mgn_dragon_seal_iron` as an Iron-based prestige good with the standard `0.1` prestige coefficient. This matches vanilla Oregrounds Iron and Russia Iron exactly at the prestige-good layer: `has_dlc_feature = mp1_content`, `base_good = iron`, and `prestige_bonus = 0.1`. The `0.1` value is consumed by the prestige-good system and is not a flat `+10%` national Prestige modifier.

The company exposes Dragon-Seal Bar Iron through `possible_prestige_goods` and deliberately omits `prestige_goods_trigger`. Like the two vanilla historical iron brands, it therefore uses only the engine's default company requirement: when the Directorate first reaches 100 Prosperity, prestige-good production enables automatically and remains permanently enabled for that company even if Prosperity later falls. No journal, country/company variable, scripted effect, or manual grant is required. Generic prestige goods use journals and variables because they can be earned by multiple qualifying companies; that machinery must not be copied onto this company-specific brand.

Prestige-good activation is separate from the Directorate's `country_minting_mult = 0.05` prosperity modifier. The Minting modifier activates at 100 Prosperity and deactivates below 75, while an already-enabled Dragon-Seal Bar Iron production line remains active. Once produced, Dragon-Seal Bar Iron receives the vanilla global prestige-good behavior automatically: stronger goods-leaderboard Prestige, increased consumer preference, export Trade Advantage, and throughput benefits for industries consuming prestige Iron. Its `possible` block requires `mp1_content`: the company remains available without mandatory DLC, while the industry-charter extension and Dragon-Seal Bar Iron depend on the Charters of Commerce feature.

The game-ready icons are `gfx/interface/icons/company_icons/historical_company_icons/company_mgn_kunyu_mining.dds` and `gfx/interface/icons/goods_icons/prestige_goods/mgn_dragon_seal_iron_prestige.dds`; both are 256x256 DXT5 DDS files with true transparency. Their editable full-resolution PNG sources are retained as `assets/source/company_mgn_kunyu_mining.png` and `assets/source/prestige_good_mgn_dragon_seal_iron.png`. The first generated compositions are the approved release assets; exact five-claw anatomy and a fourth matching top-ingot corner fitting were investigated but deliberately deferred rather than accepting lower-quality redraws.

## Monuments and Modifiers

- `building_mgn_forbidden_city`: buildable Yingtian Forbidden City in Lower Egypt.
- `building_mgn_nanjing_forbidden_city`: buildable after moving the capital to Nanjing.
- `building_mgn_imperial_academy`: the legacy save-compatible key for the buildable Imperial Academy of the Four Seas, fixed to Lower Egypt.
- `building_beijing_imperial_academy`: the buildable Metropolitan Guozijian, fixed to Beijing.
- `building_guangzhou_thirteen_factories`: the buildable Guangzhou Thirteen Factories, fixed to Guangdong.
- `building_jinghai_maritime_exchange`: the buildable Jinghai Maritime Exchange, fixed to Lower Egypt.

Neither academy checks country tag, culture, government, or capital status. Any owner of the relevant state may construct it, a conqueror inherits its benefits, and one country may own both independent `unique = yes` buildings. Each costs 1,200 construction and, at full employment, consumes 10 Paper while employing 500 Academics, 300 Clerks, and 200 Bureaucrats. Each grants workforce-scaled `+1%` nationwide Education Access plus local `+2%` Peasant Education Access and `+10%` Qualifications; owning both therefore grants `+2%` nationwide Education Access while the local effects remain in their respective states. Separate Lower Egypt and Beijing PM/PMG keys make local scope explicit in the standard UI. Ordinary Education Access remains the nationwide modifier so it cannot merge with the local Peasant Education Access line. The modifier type displays whole percentage points, and Victoria 3 1.13's generated production-method tooltip does not consume arbitrary `_desc` localization, so mechanical scope is carried by PM names and setting prose by building descriptions. Neither academy grants Innovation, research speed, Authority, Legitimacy, Prestige, or output bonuses. Both share the Guozijian-style DXT5 icon at `gfx/interface/icons/building_icons/building_mgn_imperial_academy.dds`; its full-resolution PNG source is retained under `assets/source/`.

The maritime wonders follow the same location-only ownership model and remain separate `unique = yes` buildings, so one owner may construct and stack both. Each costs 1,000 construction and, at full employment, consumes 5 Paper and 5 Merchant Marine while employing 500 Shopkeepers, 300 Clerks, and 200 Bureaucrats. Each grants workforce-scaled local `+25%` Trade Capacity and `+10%` Trade Advantage plus nationwide `+5%` Influence. Guangzhou and Jinghai use separate PM/PMG keys so the standard UI reads `Guangdong` or `Lower Egypt` for local effects and `Nationwide` for the influence effect. Both share `gfx/interface/icons/building_icons/building_mgn_maritime_exchange.dds`, whose full-resolution Canton-factories waterfront source is retained under `assets/source/`.
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
