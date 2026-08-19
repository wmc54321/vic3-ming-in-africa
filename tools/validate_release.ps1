param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = "Stop"
$RepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$ModRoot = Join-Path $RepositoryRoot "mod\ming_in_africa"
$errors = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError([string]$Message) {
    $script:errors.Add($Message)
}

$legacyDescriptor = Get-Content -LiteralPath (Join-Path $ModRoot "descriptor.mod") -Raw
$launcherDescriptor = Get-Content -LiteralPath (Join-Path $RepositoryRoot "mod\ming_in_africa.mod") -Raw
$metadataPath = Join-Path $ModRoot ".metadata\metadata.json"
$metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json

$legacyVersion = [regex]::Match($legacyDescriptor, '(?m)^version="([^"]+)"').Groups[1].Value
$launcherVersion = [regex]::Match($launcherDescriptor, '(?m)^version="([^"]+)"').Groups[1].Value
$versions = @(@($legacyVersion, $launcherVersion, [string]$metadata.version) | Select-Object -Unique)
if ($versions.Count -ne 1 -or [string]::IsNullOrWhiteSpace($versions[0])) {
    Add-ValidationError "Version mismatch across descriptor.mod, ming_in_africa.mod, and metadata.json."
}

$legacyGameVersion = [regex]::Match($legacyDescriptor, '(?m)^supported_version="([^"]+)"').Groups[1].Value
$launcherGameVersion = [regex]::Match($launcherDescriptor, '(?m)^supported_version="([^"]+)"').Groups[1].Value
$gameVersions = @(@($legacyGameVersion, $launcherGameVersion, [string]$metadata.supported_game_version) | Select-Object -Unique)
if ($gameVersions.Count -ne 1 -or [string]::IsNullOrWhiteSpace($gameVersions[0])) {
    Add-ValidationError "Supported game version mismatch across launcher metadata."
}

$mingCountryHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\countries\mgn - ming.txt") -Raw
$stateHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\states\00_states.txt") -Raw
$centralAsiaBuildingHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\buildings\09_central_asia.txt") -Raw
$centralAsiaPopHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\pops\09_central_asia.txt") -Raw
$middleEastBuildingHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\buildings\08_middle_east.txt") -Raw
$middleEastPopHistory = Get-Content -LiteralPath (Join-Path $ModRoot "common\history\pops\08_middle_east.txt") -Raw
$southEuropeBuildingHistoryPath = Join-Path $ModRoot "common\history\buildings\01_south_europe.txt"
$southEuropePopHistoryPath = Join-Path $ModRoot "common\history\pops\01_south_europe.txt"
$nationalTutelageLaw = Get-Content -LiteralPath (Join-Path $ModRoot "common\laws\00_mgn_distribution_of_power.txt") -Raw
$warlordChinaJournal = Get-Content -LiteralPath (Join-Path $ModRoot "common\journal_entries\00_warlord_china.txt") -Raw
$routeJournals = Get-Content -LiteralPath (Join-Path $ModRoot "common\journal_entries\00_mgn_route_journal_entries.txt") -Raw
$nationalTutelageJournal = Get-Content -LiteralPath (Join-Path $ModRoot "common\journal_entries\01_mgn_national_tutelage.txt") -Raw
$nationalTutelageButtons = Get-Content -LiteralPath (Join-Path $ModRoot "common\scripted_buttons\01_mgn_national_tutelage_buttons.txt") -Raw
$mgnStaticModifiers = Get-Content -LiteralPath (Join-Path $ModRoot "common\static_modifiers\00_mgn_modifiers.txt") -Raw
$regimeStateNames = Get-Content -LiteralPath (Join-Path $ModRoot "common\scripted_effects\01_mgn_regime_state_names.txt") -Raw
$mgnOnActions = Get-Content -LiteralPath (Join-Path $ModRoot "common\on_actions\00_mgn_on_actions.txt") -Raw
$frontendMain = Get-Content -LiteralPath (Join-Path $ModRoot "gui\frontend\frontend_main.gui") -Raw
$objectiveTypesGui = Get-Content -LiteralPath (Join-Path $ModRoot "gui\objective_types.gui") -Raw
$mgnObjectives = Get-Content -LiteralPath (Join-Path $ModRoot "common\objectives\00_mgn_objectives.txt") -Raw
$mgnObjectiveSubgoals = Get-Content -LiteralPath (Join-Path $ModRoot "common\objective_subgoals\00_mgn_subgoals.txt") -Raw
$mgnMonumentBuildings = Get-Content -LiteralPath (Join-Path $ModRoot "common\buildings\00_mgn_monuments.txt") -Raw
$mgnMonumentPmGroups = Get-Content -LiteralPath (Join-Path $ModRoot "common\production_method_groups\00_mgn_monuments.txt") -Raw
$mgnMonumentPms = Get-Content -LiteralPath (Join-Path $ModRoot "common\production_methods\00_mgn_monuments.txt") -Raw
$mgnBuildingValues = Get-Content -LiteralPath (Join-Path $ModRoot "common\script_values\00_mgn_building_values.txt") -Raw
$kunyuCompany = Get-Content -LiteralPath (Join-Path $ModRoot "common\company_types\00_mgn_companies.txt") -Raw
$dragonSealPrestigeGood = Get-Content -LiteralPath (Join-Path $ModRoot "common\prestige_goods\00_mgn_prestige_goods.txt") -Raw
$englishLocalization = Get-Content -LiteralPath (Join-Path $ModRoot "localization\english\mgn_l_english.yml") -Raw
$chineseLocalization = Get-Content -LiteralPath (Join-Path $ModRoot "localization\simp_chinese\mgn_l_simp_chinese.yml") -Raw

foreach ($required in @(
    "LICENSE",
    "NOTICE.md",
    "README.md",
    "CHANGELOG.md",
    "mod\ming_in_africa\thumbnail.png",
    "mod\ming_in_africa\.metadata\thumbnail.png",
    "mod\ming_in_africa\common\scripted_triggers\99_mgn_clothes_triggers.txt",
    "mod\ming_in_africa\common\history\buildings\09_central_asia.txt",
    "mod\ming_in_africa\common\history\pops\09_central_asia.txt",
    "mod\ming_in_africa\common\history\buildings\01_south_europe.txt",
    "mod\ming_in_africa\common\history\pops\01_south_europe.txt",
    "mod\ming_in_africa\common\journal_entries\00_warlord_china.txt",
    "mod\ming_in_africa\common\journal_entries\01_mgn_national_tutelage.txt",
    "mod\ming_in_africa\common\scripted_buttons\01_mgn_national_tutelage_buttons.txt",
    "mod\ming_in_africa\common\scripted_effects\01_mgn_regime_state_names.txt",
    "mod\ming_in_africa\gfx\portraits\portrait_modifiers\01_clothes.txt",
    "mod\ming_in_africa\gfx\portraits\portrait_modifiers\01_headgear.txt",
    "mod\ming_in_africa\gfx\interface\illustrations\frontend\mgn_main_menu_background.dds",
    "mod\ming_in_africa\gfx\interface\icons\objectives\objective_mgn_two_chinas_illu.dds",
    "mod\ming_in_africa\gfx\interface\icons\building_icons\building_mgn_imperial_academy.dds",
    "mod\ming_in_africa\gfx\interface\icons\building_icons\building_mgn_maritime_exchange.dds",
    "mod\ming_in_africa\gui\frontend\frontend_main.gui",
    "mod\ming_in_africa\gui\objective_types.gui",
    "mod\ming_in_africa\common\objectives\00_mgn_objectives.txt",
    "mod\ming_in_africa\common\objective_subgoal_categories\00_mgn_categories.txt",
    "mod\ming_in_africa\common\objective_subgoals\00_mgn_subgoals.txt",
    "mod\ming_in_africa\common\company_types\00_mgn_companies.txt",
    "mod\ming_in_africa\common\prestige_goods\00_mgn_prestige_goods.txt",
    "mod\ming_in_africa\gfx\interface\icons\company_icons\historical_company_icons\company_mgn_kunyu_mining.dds",
    "mod\ming_in_africa\gfx\interface\icons\goods_icons\prestige_goods\mgn_dragon_seal_iron_prestige.dds",
    "assets\source\mgn_main_menu_background.png",
    "assets\source\objective_mgn_two_chinas.png",
    "assets\source\building_mgn_imperial_academy.png",
    "assets\source\building_mgn_maritime_exchange.png",
    "assets\source\company_mgn_kunyu_mining.png",
    "assets\source\prestige_good_mgn_dragon_seal_iron.png",
    "tools\generate_portrait_compatibility.ps1"
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot $required))) {
        Add-ValidationError "Missing required release file: $required"
    }
}

if ($frontendMain -notmatch 'texture\s*=\s*"gfx/interface/illustrations/frontend/mgn_main_menu_background\.dds"' -or
    $frontendMain -match 'FrontEndMainView\.GetMainMenuImage') {
    Add-ValidationError "Main-menu GUI must use the fixed Ming cover instead of the vanilla selectable video layer."
}
$mainMenuCover = Get-Item -LiteralPath (Join-Path $ModRoot "gfx\interface\illustrations\frontend\mgn_main_menu_background.dds")
if ($mainMenuCover.Length -ne 33177728) {
    Add-ValidationError "Main-menu cover must be a complete 3840x2160 RGBA8 DDS payload (33,177,728 bytes)."
}
$objectiveCover = Get-Item -LiteralPath (Join-Path $ModRoot "gfx\interface\icons\objectives\objective_mgn_two_chinas_illu.dds")
if ($objectiveCover.Length -ne 4135060) {
    Add-ValidationError "Two Chinas objective cover must be a complete 779x1327 RGBA8 DDS payload (4,135,060 bytes)."
}
foreach ($fragment in @(
    'objective_mgn_two_chinas\s*=\s*\{',
    'recommended_tags\s*=\s*\{\s*MGN\s+CHI\s*\}',
    'available_for_all_countries\s*=\s*no',
    'final_subgoal\s*=\s*sg_mgn_two_chinas'
)) {
    if ($mgnObjectives -notmatch $fragment) {
        Add-ValidationError "Two Chinas objective is missing required behavior: $fragment"
    }
}
if ($mgnObjectiveSubgoals -notmatch 'objective_subgoal\s*=\s*sg_mgn_two_chinas' -or
    $mgnObjectiveSubgoals -notmatch 'type\s*=\s*je_mgn_two_chinas') {
    Add-ValidationError "Two Chinas objective subgoal must attach the existing Two Chinas journal."
}
if ($objectiveTypesGui -notmatch 'minimumsize\s*=\s*\{\s*225\s+82\s*\}' -or
    $objectiveTypesGui -notmatch 'maximumsize\s*=\s*\{\s*205\s+-1\s*\}') {
    Add-ValidationError "Objective selector must use the compact six-card layout."
}
foreach ($localization in @($englishLocalization, $chineseLocalization)) {
    foreach ($key in @(
        'je_mgn_two_chinas_lobby',
        'objective_mgn_two_chinas',
        'objective_mgn_two_chinas_desc',
        'objective_mgn_two_chinas_idle_header',
        'objective_mgn_two_chinas_idle_hint',
        'objective_mgn_two_chinas_name_MGN',
        'objective_mgn_two_chinas_desc_MGN',
        'objective_mgn_two_chinas_name_CHI',
        'objective_mgn_two_chinas_desc_CHI'
    )) {
        if ($localization -notmatch "(?m)^\s*$([regex]::Escape($key))\s*:") {
            Add-ValidationError "Two Chinas objective or lobby localization is missing $key."
        }
    }
}

if ($stateHistory -match 'country\s*=\s*c:TIB') {
    Add-ValidationError "Generated state history still assigns starting provinces to Tibet."
}
foreach ($qingTibetState in @("STATE_LHASA", "STATE_NGARI", "STATE_EASTERN_HIMALAYAS")) {
    $stateMatch = [regex]::Match(
        $stateHistory,
        "(?ms)^\s*s:$qingTibetState\s*=\s*\{(?<block>.*?)(?=^\s*s:STATE_[A-Z0-9_]+\s*=|\z)"
    )
    if (-not $stateMatch.Success -or $stateMatch.Groups["block"].Value -notmatch 'country\s*=\s*c:CHI\s+state_type\s*=\s*unincorporated') {
        Add-ValidationError "Generated state history does not keep Qing-owned $qingTibetState unincorporated."
    }
}
if ($centralAsiaBuildingHistory -match 'region_state:TIB|country\s*=\s*"?c:TIB"?') {
    Add-ValidationError "Generated Central Asian building history still targets Tibet."
}
if ($centralAsiaPopHistory -match 'region_state:TIB') {
    Add-ValidationError "Generated Central Asian pop history still targets Tibet."
}

$warlordLobbyBlock = [regex]::Match(
    $warlordChinaJournal,
    '(?ms)is_shown_in_lobby\s*=\s*\{(?<block>.*?)\n\s*\}'
).Groups['block'].Value
if ($warlordLobbyBlock -notmatch 'c:CHI\s*\?=\s*THIS' -or $warlordLobbyBlock -match 'country_has_primary_culture|c:MGN') {
    Add-ValidationError "Fragile Unity must be advertised only for CHI in the country-selection lobby."
}
$twoChinasLobbyBlock = [regex]::Match(
    $routeJournals,
    '(?ms)je_mgn_two_chinas\s*=\s*\{.*?is_shown_in_lobby\s*=\s*\{(?<block>.*?)\n\s*\}'
).Groups['block'].Value
foreach ($countryTag in @('MGN', 'CHI')) {
    if ($twoChinasLobbyBlock -notmatch "c:$countryTag\s*\?=\s*THIS") {
        Add-ValidationError "Two Chinas must be advertised for $countryTag in the country-selection lobby."
    }
}

foreach ($requiredLawFragment in @(
    'law_mgn_national_tutelage\s*=\s*\{',
    'has_law\s*=\s*law_type:law_corporate_state',
    'has_law\s*=\s*law_type:law_social_monarchy',
    'interest_group_ig_armed_forces_pol_str_mult\s*=\s*0\.15',
    'interest_group_ig_petty_bourgeoisie_pol_str_mult\s*=\s*0\.15',
    'add_journal_entry\s*=\s*\{\s*type\s*=\s*je_mgn_national_tutelage'
)) {
    if ($nationalTutelageLaw -notmatch $requiredLawFragment) {
        Add-ValidationError "National Tutelage law is missing required behavior: $requiredLawFragment"
    }
}
if ($nationalTutelageJournal -notmatch 'on_invalid\s*=\s*\{' -or $nationalTutelageJournal -notmatch 'call_election\s*=\s*\{\s*months\s*=\s*6') {
    Add-ValidationError "National Tutelage journal must clean up martial law and restore elections after invalidation."
}
foreach ($requiredButtonFragment in @(
    'button_mgn_declare_martial_law\s*=\s*\{',
    'set_next_election_date\s*=\s*"9999\.1\.1"',
    'button_mgn_lift_martial_law\s*=\s*\{',
    'call_election\s*=\s*\{\s*months\s*=\s*6'
)) {
    if ($nationalTutelageButtons -notmatch $requiredButtonFragment) {
        Add-ValidationError "National Tutelage buttons are missing required behavior: $requiredButtonFragment"
    }
}
if ($mgnStaticModifiers -notmatch 'mgn_mobilization_period\s*=\s*\{' -or $mgnStaticModifiers -notmatch 'political_movement_radicalism_add\s*=\s*-0\.15') {
    Add-ValidationError "Mobilization Period modifier is missing its martial-law effects."
}

$regimeStateRegions = @(
    "STATE_BEIJING", "STATE_NANJING", "STATE_GUANGDONG", "STATE_HENAN",
    "STATE_HUNAN", "STATE_JIANGXI", "STATE_XIAN", "STATE_GUIZHOU",
    "STATE_FORMOSA", "STATE_SHANDONG", "STATE_OUTER_MANCHURIA", "STATE_AMUR",
    "STATE_LOWER_EGYPT", "STATE_MIDDLE_EGYPT", "STATE_UPPER_EGYPT", "STATE_SINAI",
    "STATE_EAST_SAHARA", "STATE_GOLD_COAST", "STATE_CONGO", "STATE_SOUTH_CAMEROON",
    "STATE_KENYA", "STATE_ZANZIBAR", "STATE_CAPE_COLONY", "STATE_TRANSVAAL"
)
foreach ($stateRegion in $regimeStateRegions) {
    foreach ($suffix in @("mgn_revolutionary_committees", "mgn_national_tutelage")) {
        $localizationKey = "${stateRegion}_${suffix}"
        if ($regimeStateNames -notmatch "set_state_name\s*=\s*$([regex]::Escape($localizationKey))\b") {
            Add-ValidationError "Fixed regime state-name effect is missing $localizationKey."
        }
        foreach ($localization in @($englishLocalization, $chineseLocalization)) {
            if ($localization -notmatch "(?m)^\s*$([regex]::Escape($localizationKey))\s*:") {
                Add-ValidationError "Fixed regime state-name localization is missing $localizationKey."
            }
        }
    }
}
foreach ($requiredStateNameFragment in @(
    'STATE_LOWER_EGYPT_mgn_imperial_residence',
    'has_game_rule\s*=\s*no_dynamic_naming',
    'reset_state_name\s*=\s*yes',
    'evaluate_and_assign_state_hub_dynamic_names\s*=\s*yes',
    'set_variable\s*=\s*mgn_regime_state_name_applied',
    'capital\.state_region\s*=\s*s:STATE_LOWER_EGYPT'
)) {
    if ($regimeStateNames -notmatch $requiredStateNameFragment) {
        Add-ValidationError "Fixed regime state-name lifecycle is missing: $requiredStateNameFragment"
    }
}
if ($regimeStateNames -match 'random(_scope_state)?\s*=') {
    Add-ValidationError "Fixed regime state names must not use random selection."
}
foreach ($requiredOnActionFragment in @(
    'mgn_regime_state_names_game_start',
    'mgn_regime_state_names_monthly_pulse',
    'mgn_regime_state_name_owner_change',
    'on_state_created\s*=\s*\{'
)) {
    if ($mgnOnActions -notmatch $requiredOnActionFragment) {
        Add-ValidationError "Fixed regime state-name on-action is missing: $requiredOnActionFragment"
    }
}
if (([regex]::Matches($nationalTutelageLaw, 'every_scope_state\s*=\s*\{\s*mgn_refresh_regime_state_name\s*=\s*yes')).Count -lt 4) {
    Add-ValidationError "Both special laws must refresh fixed state names on activation and deactivation."
}

$adanaStateBlock = [regex]::Match(
    $stateHistory,
    '(?ms)^\s*s:STATE_ADANA\s*=\s*\{(?<block>.*?)(?=^\s*s:STATE_[A-Z0-9_]+\s*=|\z)'
).Groups['block'].Value
if (([regex]::Matches($adanaStateBlock, 'country\s*=\s*c:TUR\b')).Count -ne 1 -or $adanaStateBlock -match 'country\s*=\s*c:EGY\b') {
    Add-ValidationError "Generated Adana state history must contain one merged Ottoman state and no Egyptian fragment."
}
foreach ($history in @(
    @{ Name = 'building'; Text = $middleEastBuildingHistory },
    @{ Name = 'pop'; Text = $middleEastPopHistory }
)) {
    $adanaBlock = [regex]::Match(
        $history.Text,
        '(?ms)^\s*s:STATE_ADANA\s*=\s*\{(?<block>.*?)(?=^\s*s:STATE_[A-Z0-9_]+\s*=|\z)'
    ).Groups['block'].Value
    if (([regex]::Matches($adanaBlock, 'region_state:TUR\b')).Count -ne 1 -or $adanaBlock -match 'region_state:EGY\b') {
        Add-ValidationError "Generated Adana $($history.Name) history must target one merged Ottoman state scope."
    }
}

foreach ($iconName in @('building_mgn_imperial_academy.dds', 'building_mgn_maritime_exchange.dds')) {
    $iconPath = Join-Path $ModRoot "gfx\interface\icons\building_icons\$iconName"
    if ((Get-Item -LiteralPath $iconPath).Length -ne 65664) {
        Add-ValidationError "$iconName must be a complete 256x256 DXT5 DDS payload (65,664 bytes)."
    }
}
$kunyuCompanyIcon = Get-Item -LiteralPath (Join-Path $ModRoot "gfx\interface\icons\company_icons\historical_company_icons\company_mgn_kunyu_mining.dds")
if ($kunyuCompanyIcon.Length -ne 65664) {
    Add-ValidationError "Kunyu company icon must be a complete 256x256 DXT5 DDS payload (65,664 bytes)."
}
$dragonSealIronIcon = Get-Item -LiteralPath (Join-Path $ModRoot "gfx\interface\icons\goods_icons\prestige_goods\mgn_dragon_seal_iron_prestige.dds")
if ($dragonSealIronIcon.Length -ne 65664) {
    Add-ValidationError "Dragon-Seal Bar Iron icon must be a complete 256x256 DXT5 DDS payload (65,664 bytes)."
}
foreach ($requiredCompanyFragment in @(
    'company_mgn_kunyu_mining\s*=\s*\{',
    'c:MGN\s*\?=\s*this',
    'building_coal_mine',
    'building_iron_mine',
    'building_sulfur_mine',
    'building_lead_mine',
    'building_gold_mine',
    'building_steel_mill',
    'building_explosives_factory',
    'prestige_good_mgn_dragon_seal_iron',
    'region\s*=\s*sr:region_southern_africa',
    'level\s*>=\s*5',
    'country_minting_mult\s*=\s*0\.05'
)) {
    if ($kunyuCompany -notmatch $requiredCompanyFragment) {
        Add-ValidationError "Kunyu Directorate of Mines is missing required behavior: $requiredCompanyFragment"
    }
}
if ($kunyuCompany -match 'has_dlc_feature') {
    Add-ValidationError "Kunyu Directorate of Mines must remain available without a mandatory DLC gate."
}
foreach ($requiredPrestigeGoodFragment in @(
    'prestige_good_mgn_dragon_seal_iron\s*=\s*\{',
    'has_dlc_feature\s*=\s*mp1_content',
    'base_good\s*=\s*iron',
    'prestige_bonus\s*=\s*0\.1',
    'mgn_dragon_seal_iron_prestige\.dds'
)) {
    if ($dragonSealPrestigeGood -notmatch $requiredPrestigeGoodFragment) {
        Add-ValidationError "Dragon-Seal Bar Iron is missing required behavior: $requiredPrestigeGoodFragment"
    }
}
foreach ($localization in @($englishLocalization, $chineseLocalization)) {
    foreach ($key in @('company_mgn_kunyu_mining', 'prestige_good_mgn_dragon_seal_iron')) {
        if ($localization -notmatch "(?m)^\s*$([regex]::Escape($key))\s*:") {
            Add-ValidationError "Kunyu company or prestige-good localization is missing $key."
        }
    }
}
foreach ($requiredBuildingFragment in @(
    'building_guangzhou_thirteen_factories\s*=\s*\{',
    'building_jinghai_maritime_exchange\s*=\s*\{',
    'state_region\s*=\s*s:STATE_GUANGDONG',
    'state_region\s*=\s*s:STATE_LOWER_EGYPT',
    'required_construction\s*=\s*construction_cost_maritime_exchange'
)) {
    if ($mgnMonumentBuildings -notmatch $requiredBuildingFragment) {
        Add-ValidationError "Maritime wonders are missing required building behavior: $requiredBuildingFragment"
    }
}
foreach ($requiredPmGroup in @(
    'pmg_base_building_guangzhou_thirteen_factories',
    'pmg_guangzhou_thirteen_factories_network',
    'pmg_base_building_jinghai_maritime_exchange',
    'pmg_jinghai_maritime_exchange_network'
)) {
    if ($mgnMonumentPmGroups -notmatch "$requiredPmGroup\s*=\s*\{") {
        Add-ValidationError "Maritime wonder production-method group is missing: $requiredPmGroup"
    }
}
foreach ($requiredPmFragment in @(
    'state_trade_capacity_mult\s*=\s*0\.25',
    'state_trade_advantage_mult\s*=\s*0\.10',
    'country_influence_mult\s*=\s*0\.05',
    'goods_input_paper_add\s*=\s*5',
    'goods_input_merchant_marine_add\s*=\s*5',
    'building_employment_shopkeepers_add\s*=\s*500',
    'building_employment_clerks_add\s*=\s*300',
    'building_employment_bureaucrats_add\s*=\s*200'
)) {
    if ($mgnMonumentPms -notmatch $requiredPmFragment) {
        Add-ValidationError "Maritime wonder production methods are missing: $requiredPmFragment"
    }
}
if ($mgnBuildingValues -notmatch 'construction_cost_maritime_exchange\s*=\s*1000') {
    Add-ValidationError "Maritime wonders must cost 1,000 construction."
}
foreach ($localization in @($englishLocalization, $chineseLocalization)) {
    foreach ($key in @(
        'building_guangzhou_thirteen_factories',
        'building_guangzhou_thirteen_factories_desc',
        'building_jinghai_maritime_exchange',
        'building_jinghai_maritime_exchange_desc',
        'pm_guangzhou_thirteen_factories',
        'pm_guangzhou_thirteen_factories_network',
        'pm_jinghai_maritime_exchange',
        'pm_jinghai_maritime_exchange_network'
    )) {
        if ($localization -notmatch "(?m)^\s*$([regex]::Escape($key))\s*:") {
            Add-ValidationError "Maritime wonder localization is missing $key."
        }
    }
}

if ((Test-Path -LiteralPath $southEuropeBuildingHistoryPath) -and (Test-Path -LiteralPath $southEuropePopHistoryPath)) {
    foreach ($southEuropeHistoryPath in @($southEuropeBuildingHistoryPath, $southEuropePopHistoryPath)) {
        $bytes = [IO.File]::ReadAllBytes($southEuropeHistoryPath)
        if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
            Add-ValidationError "Generated South European history override must use UTF-8 BOM: $southEuropeHistoryPath"
        }
    }
    $southEuropeBuildingHistory = Get-Content -LiteralPath $southEuropeBuildingHistoryPath -Raw
    $southEuropePopHistory = Get-Content -LiteralPath $southEuropePopHistoryPath -Raw
    $creteBuildingHistory = [regex]::Match(
        $southEuropeBuildingHistory,
        '(?ms)^\s*s:STATE_CRETE\s*=\s*\{(?<block>.*?)(?=^\s*s:STATE_[A-Z0-9_]+\s*=|\z)'
    ).Groups['block'].Value
    $cretePopHistory = [regex]::Match(
        $southEuropePopHistory,
        '(?ms)^\s*s:STATE_CRETE\s*=\s*\{(?<block>.*?)(?=^\s*s:STATE_[A-Z0-9_]+\s*=|\z)'
    ).Groups['block'].Value
    if (([regex]::Matches($creteBuildingHistory, 'region_state:TUR\b')).Count -ne 1 -or
        $creteBuildingHistory -match 'region_state:EGY\b|country\s*=\s*"?c:EGY"?' -or
        $southEuropeBuildingHistory -notmatch 's:STATE_WEST_AEGEAN_ISLANDS\s*=' -or
        $creteBuildingHistory -notmatch 'create_building\s*=') {
        Add-ValidationError "Generated South European building override must be a full same-name copy with nonempty Ottoman Crete and no Egyptian references."
    }
    if (([regex]::Matches($cretePopHistory, 'region_state:TUR\b')).Count -ne 1 -or
        $cretePopHistory -match 'region_state:EGY\b' -or
        $southEuropePopHistory -notmatch 's:STATE_WEST_AEGEAN_ISLANDS\s*=' -or
        $cretePopHistory -notmatch 'create_pop\s*=') {
        Add-ValidationError "Generated South European pop override must be a full same-name copy with nonempty Ottoman Crete and no Egyptian references."
    }
}
foreach ($obsoleteCreteHistory in @(
    "common\history\buildings\99_mgn_egypt_remnants.txt",
    "common\history\pops\99_mgn_egypt_remnants.txt"
)) {
    if (Test-Path -LiteralPath (Join-Path $ModRoot $obsoleteCreteHistory)) {
        Add-ValidationError "Obsolete additive Crete history must be removed because duplicate state blocks cannot resolve region_state scopes: $obsoleteCreteHistory"
    }
}

$environmentPath = Join-Path $RepositoryRoot ".env.local"
if (Test-Path -LiteralPath $environmentPath -PathType Leaf) {
    try {
        & (Join-Path $PSScriptRoot "generate_portrait_compatibility.ps1") -Check
    }
    catch {
        Add-ValidationError "Portrait compatibility validation failed: $($_.Exception.Message)"
    }
}

$thumbnail = Join-Path $ModRoot "thumbnail.png"
$metadataThumbnail = Join-Path $ModRoot ".metadata\thumbnail.png"
if ((Test-Path $thumbnail) -and (Test-Path $metadataThumbnail)) {
    if ((Get-FileHash -LiteralPath $thumbnail).Hash -ne (Get-FileHash -LiteralPath $metadataThumbnail).Hash) {
        Add-ValidationError "Launcher thumbnails do not match."
    }
}

foreach ($localization in Get-ChildItem -LiteralPath (Join-Path $ModRoot "localization") -Recurse -Filter "*.yml") {
    $bytes = [IO.File]::ReadAllBytes($localization.FullName)
    if ($bytes.Length -lt 3 -or $bytes[0] -ne 0xEF -or $bytes[1] -ne 0xBB -or $bytes[2] -ne 0xBF) {
        Add-ValidationError "Localization must use UTF-8 BOM: $($localization.FullName)"
    }
    $keys = Get-Content -LiteralPath $localization.FullName | ForEach-Object {
        if ($_ -match '^\s+([^#\s][^:]*):') { $Matches[1] }
    }
    foreach ($duplicate in $keys | Group-Object | Where-Object Count -gt 1) {
        Add-ValidationError "Duplicate localization key '$($duplicate.Name)' in $($localization.FullName)"
    }
}

foreach ($scriptFile in Get-ChildItem -LiteralPath $ModRoot -Recurse -File | Where-Object Extension -in @(".txt", ".mod")) {
    $content = Get-Content -LiteralPath $scriptFile.FullName -Raw
    $openBraces = ([regex]::Matches($content, '\{')).Count
    $closeBraces = ([regex]::Matches($content, '\}')).Count
    if ($openBraces -ne $closeBraces) {
        Add-ValidationError "Unbalanced braces in $($scriptFile.FullName): $openBraces opening, $closeBraces closing."
    }
}

foreach ($versionedDocument in @("README.md", "CHANGELOG.md", "docs\workshop-description.md")) {
    $content = Get-Content -LiteralPath (Join-Path $RepositoryRoot $versionedDocument) -Raw
    if ($content -notmatch [regex]::Escape([string]$metadata.version)) {
        Add-ValidationError "Current mod version is missing from $versionedDocument"
    }
}

$textExtensions = @(".md", ".txt", ".mod", ".json", ".ps1", ".yml", ".example")
foreach ($file in Get-ChildItem -LiteralPath $RepositoryRoot -Recurse -File | Where-Object {
    $textExtensions -contains $_.Extension -and $_.FullName -notmatch '[\\/]\.git[\\/]'
}) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    if ($content -match '(?i)C:\\Users\\|steamapps\\common') {
        Add-ValidationError "Machine-specific path found in $($file.FullName)"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Release validation failed with $($errors.Count) error(s)."
}

Write-Host "Release validation passed. Mod version: $($versions[0]); game version: $($gameVersions[0])."
