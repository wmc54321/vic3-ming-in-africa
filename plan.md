# 大明在非洲 Mod 方案草案

## 目标

给《维多利亚 3》做一个开局剧本式 mod：非洲大陆统一为一个新国家“大明”，首版主流文化采用 `han african_han western_han`，法律大体沿用大清但保留奴隶贸易、无移民控制和殖民安置；原有非洲国家开局不应存在；大明和大清、其他中国分裂国家之间应能互相打“统一中国”，且大清与大明之间无视国家地位限制，互相可用要求成为朝贡国/附庸国类战争目标。大明还应能对其他中华国家发起“开放迁徙”类战争目标，强制目标改为无移民控制。

本方案按当前本机游戏目录 `D:\SteamLibrary\steamapps\common\Victoria 3` 调研，关键原版文件包括：

- `game/common/country_definitions/00_countries.txt`
- `game/common/history/countries/chi - china.txt`
- `game/common/history/states/00_states.txt`
- `game/common/diplomatic_plays/00_diplomatic_plays.txt`
- `game/common/journal_entries/00_warlord_china.txt`
- `game/common/journal_entries/00_reunify_china.txt`
- `game/common/strategic_regions/african_strategic_regions.txt`
- `game/common/geographic_regions/03_geographic_regions_africa.txt`
- `game/common/dynamic_country_names/00_dynamic_country_names.txt`
- `game/common/flag_definitions/00_flag_definitions.txt`
- `game/common/laws/00_citizenship.txt`
- `game/common/laws/00_slavery.txt`

## 总体路线

推荐新建独立国家 tag：`MGN`，不要复用 `CHI`。

原因是原版大量中国内容硬编码 `c:CHI` 为大清/中国中央政府。若直接把非洲改成 `CHI`，会牵连鸦片战争、义和团、脆弱的统一、琉球相关事件等原版内容。新建 `MGN` 可以让大明既参与中国统一玩法，又不吃到大清的“脆弱的统一”日志。

文化路线推荐从“主流文化有且仅有汉”调整为“汉 + 两个桥梁文化”：

- `han`：保留正统汉文化，保证原版中国统一相关脚本天然识别大明为中国圈国家。
- `african_han` / “非洲中华”：覆盖撒哈拉以南非洲 heritage group。
- `western_han` / “西域中华”：覆盖北非、中东 heritage group，用来照顾埃及、马格里布、阿拉伯化北非等文化。

旧方案“主流文化仅 `han`，通过隐藏接受度修正让非洲文化达到二等公民”仍保留在本文后文作为备选方案。新推荐方案更有设定解释力，也减少全局改写所有非洲文化的需要；代价是它不再满足最初“主流文化有且仅有汉”的严格条件。

## 初版实现范围

初版以以下选择为准，后文所有“备选”“待定”“二期”内容暂不实现：

- 国家 tag 固定为 `MGN`，不复用 `CHI`。
- 主流文化固定为 `han african_han western_han`，不采用“仅汉 + 隐藏接受度修正”的旧方案。
- 首都和市场首都固定为 `STATE_LOWER_EGYPT`。第一轮实测确认开普首都导致利益扩散过慢；开普保留为备选方案。
- 首都 hub 使用大明专属名称：城市“应天府”，港口“靖海港”。
- 开局法律采用大清法律底盘，但改为 `law_slave_trade`、`law_no_migration_controls`、`law_colonial_resettlement`、`law_mercantilism`、`law_professional_navy`，并确保 `colonization`、`international_trade`、`military_drill` 科技。
- 开局不添加汉文化移民人口，不改非洲本地 pop culture，不删除非洲 homeland。
- 添加 20 年衰减的“天朝在非洲”修正，但移除其中行政力惩罚，改为建设效率、权威、机构成本/税收能力等统治摩擦惩罚。
- 添加 20 年衰减的强力行政正面修正“南都行台”，开局至少 `+1250%` 行政力，保证统一非洲后可玩。
- 新增下埃及可建造的大明版紫禁城奇观“南都紫禁城”，图标、生产方式和效果复用北京紫禁城。
- 新增两条大明专用公民权变体法律：开局采用“天朝万民”（`law_subjecthood` 变体，等级化帝国臣民秩序，额外加同化）；后续可改革为“华夷一统”（`law_multicultural` 变体，文化多元式接受度，额外加同化，并允许使用“弘扬国家价值”法令）。
- 不添加“海外大明”日志，不添加二期事件包。
- 国号/旗帜先实现动态国名和可用旗帜；默认、君主制、普通共和、军政府/独裁、法团/法西斯、神权、委员会共和和属国 canton 均已使用大明专属朱红金黄体系旗帜。
- 非洲州、建筑、军队归属优先保证 1836 开局无错误；数值平衡留到第一轮实测后调整。
- 埃及是非洲开局国家，但原版还持有黎凡特领土；初版将埃及在非洲外的残余领土和建筑归属转给奥斯曼，避免 `EGY` 作为开局国家残留。
- “开放中华迁徙”战争目标允许叠加到其他外交博弈/战争目标上，以便目标更容易在战前退让。
- “中华臣服”战争目标恶名上调到仍低于常规附庸化、但不至于无代价扩张的水平；首版建议固定 `8`。

## 文件结构建议

```text
vic3-ming-in-africa/
  descriptor.mod
  common/
    country_definitions/00_mgn_countries.txt
    cultures/00_mgn_cultures.txt
    discrimination_traits/00_mgn_discrimination_traits.txt
    dynamic_country_names/00_mgn_dynamic_country_names.txt
    flag_definitions/00_mgn_flag_definitions.txt
    laws/00_mgn_citizenship.txt
    buildings/00_mgn_monuments.txt
    state_traits/00_mgn_state_traits.txt
    static_modifiers/00_mgn_modifiers.txt
    scripted_triggers/00_mgn_scripted_triggers.txt
    war_goal_types/00_mgn_war_goal_types.txt
    diplomatic_plays/00_mgn_diplomatic_plays.txt
    character_templates/00_mgn_character_templates.txt
    history/
      countries/mgn - ming.txt
      states/00_states.txt
      buildings/03_north_africa.txt
      buildings/04_subsaharan_africa.txt
      buildings/08_middle_east.txt
      pops/03_north_africa.txt
      pops/04_subsaharan_africa.txt
      pops/08_middle_east.txt
      population/mgn - ming.txt
      military_formations/03_military_formations_north_africa.txt
      military_formations/07_military_formations_subsaharan_africa.txt
      characters/mgn - ming.txt
  localization/
    simp_chinese/mgn_l_simp_chinese.yml
    english/mgn_l_english.yml
```

首版文件覆盖策略：

- `descriptor.mod`：首版加入 `replace_path = "common/history/states"`。不要一开始 replace buildings 或 military formations 目录。
- `common/history/states`：使用 `replace_path = "common/history/states"`，复制原版唯一的 `00_states.txt`，再改非洲州归属、整合和 homeland 保留状态。这是兼容性较差但最稳的做法，避免同一 state region 重复定义。
- `common/history/buildings`：先只复制并改 `03_north_africa.txt`、`04_subsaharan_africa.txt`，把非洲建筑所有权改为 `c:MGN`。不要一开始 replace 整个 buildings 目录，否则要同步复制所有地区建筑文件。
- `common/history/buildings/08_middle_east.txt`：只把原本属于 `EGY` 的黎凡特建筑归属改为 `TUR`，配合州归属转移，避免埃及残留。
- `common/history/military_formations`：先只复制并改北非、撒哈拉以南非洲两个文件，或直接清空原非洲军队后在 `mgn - ming.txt`/专用军队文件中创建大明固定军队。不要把所有原非洲军队无脑合并。
- 若测试发现 buildings 或 military formations 出现重复定义，再考虑对对应目录使用 `replace_path`，并同时复制该目录下全部原版文件。

## 1. 国家定义

新增 `MGN`：

```txt
MGN = {
    color = { 190 45 35 } # 朱红，和大清金色区分
    country_type = unrecognized
    tier = empire
    cultures = { han african_han western_han }
    religion = confucian
    capital = STATE_LOWER_EGYPT # 当前推荐开局首都：利益扩散更好，联通地中海、近东和通往中国的路线
}
```

说明：

- 新推荐路线下，主流文化为 `han african_han western_han`。其中 `african_han` 和 `western_han` 是新建桥梁文化，不是把现有非洲文化直接设为主流文化。
- `country_type = unrecognized` 与大清一致。
- 颜色采用朱红，和大清金色区分，同时保留明制风味。
- 当前版本首都固定为 `STATE_LOWER_EGYPT`，市场首都也同步设为 `STATE_LOWER_EGYPT`。
- 首都推荐理由：第一轮实测确认开普首都利益扩散过慢。下埃及更利于地中海、近东、欧洲和通往中国方向的外交/利益投射，也更有“天朝控苏伊士、联通中国与欧洲”的味道。下埃及有尼罗河特质、港口、80 耕地、棉花/鸦片/糖等作物，且无疟疾；缺点是本州煤铁不足，也没有天然良港。
- 开普备选：若之后更重视本州海港修正、南非煤铁金经营和低摩擦建设，可把首都和市场首都改回 `STATE_CAPE_COLONY`。开普殖民地有 `state_trait_natural_harbors`，无疟疾，适合承接移民、行政机构、大学、港口和早期工业。
- 资源型备选：`STATE_TRANSVAAL` 煤铁金和 Waterberg 煤田很强，但内陆且有疟疾，更适合作为工业/矿业核心，不建议做首都。`STATE_CONGO`、`STATE_NIGER_DELTA`、`STATE_ZANZIBAR` 资源或位置有亮点，但疟疾问题明显；若想刻意提高“非酋”味，可作为风味备选。

### 桥梁文化

新增两个文化：

```txt
african_han = {
    color = rgb{ 180 90 55 }
    religion = confucian
    heritage = heritage_afro_sinitic
    language = language_mandarin
    traditions = { tradition_sinosphere }
    name_format = last_first
    graphics = east_asian
    ethnicities = { 1 = asian 1 = african }
}

western_han = {
    color = rgb{ 170 105 65 }
    religion = confucian
    heritage = heritage_western_sinitic
    language = language_mandarin
    traditions = { tradition_sinosphere }
    name_format = last_first
    graphics = east_asian
    ethnicities = { 1 = asian 1 = middle_eastern }
}
```

新增两个 heritage：

```txt
heritage_afro_sinitic = {
    trait_group = heritage_group_african
}

heritage_western_sinitic = {
    trait_group = heritage_group_middle_eastern
}
```

解释：

- 单个文化按原版结构基本只能有一个 `heritage`，不建议尝试让一个文化同时拥有 `heritage_han` 和非洲 heritage。
- 通过两个桥梁文化，国家层面同时拥有东亚汉文化、非洲 heritage group、中东 heritage group。
- `language_mandarin` 和 `tradition_sinosphere` 让桥梁文化保留“中华”味道；`heritage_group_african` / `heritage_group_middle_eastern` 负责本地接受度。
- 北非很多文化不是 `heritage_group_african`，而是 `heritage_group_middle_eastern`，所以单独加“西域中华”比只加“非洲中华”更完整。

旧方案备选：如果之后仍想严格满足“主流文化有且仅有汉”，就把 `cultures = { han african_han western_han }` 改回 `cultures = { han }`，并使用第 5 节的隐藏接受度修正。

## 2. 国号和旗帜

### 国号

新增本地化：

```yml
l_simp_chinese:
 MGN: "大明"
 MGN_ADJ: "大明"
 dyn_c_great_ming: "大明"
 dyn_c_great_ming_adj: "大明"
 dyn_c_ming_republic: "中华民国"
 dyn_c_ming_republic_adj: "中华民国"
 dyn_c_ming_federal_republic: "中华联邦共和国"
 dyn_c_ming_federal_republic_adj: "中华联邦共和国"
 dyn_c_ming_soviet_union: "中华苏维埃社会主义共和国联盟"
 dyn_c_ming_soviet_union_adj: "中华苏维埃社会主义共和国联盟"
 dyn_c_ming_fascist: "中华复兴国"
 dyn_c_ming_fascist_adj: "中华复兴国"
 dyn_c_ming_corporate_republic: "中华法团共和国"
 dyn_c_ming_corporate_republic_adj: "中华法团共和国"
 dyn_c_ming_corporate_monarchy: "大明法团国"
 dyn_c_ming_corporate_monarchy_adj: "大明法团国"
 dyn_c_ming_technate: "中华技政共和国"
 dyn_c_ming_technate_adj: "中华技政共和国"
 dyn_c_ming_theocracy: "中华礼教国"
 dyn_c_ming_theocracy_adj: "中华礼教国"
 dyn_c_ming_military_government: "中华护国政府"
 dyn_c_ming_military_government_adj: "中华护国政府"
 dyn_c_ming_single_party: "中华训政共和国"
 dyn_c_ming_single_party_adj: "中华训政共和国"
 dyn_c_ming_anarchist: "中华自由公社联盟"
 dyn_c_ming_anarchist_adj: "中华自由公社联盟"
```

新增动态国名，让君主制时显示“大明”，逻辑对应原版 `dyn_c_great_qing`：

```txt
MGN = {
    dynamic_country_name = {
        name = dyn_c_great_ming
        adjective = dyn_c_great_ming_adj
        is_main_tag_only = yes
        priority = 0
        trigger = { coa_def_monarchy_flag_trigger = yes }
    }
}
```

推荐动态国号路线：

- 君主制：`大明`。这是开局默认国号，配朱红金黄色龙旗，表达“海外另立天命”。
- 总统共和：`中华民国`。废除皇帝后，政权正统性从“大明皇统”转为“中华国统”，仍然宣称自己是中国正统。
- 议会共和：`中华联邦共和国`。适合统一非洲后的多区域、多文化政体，既有共和合法性，也能解释非洲各地块被整合后的地方自治。
- 委员会共和：`中华苏维埃社会主义共和国联盟`。`law_council_republic` 本来就是委员会/苏维埃式共和；统一非洲后用“共和国联盟”也能解释各大区域以加盟共和国/自治共和国形式被整合，比单一共和国更有跨洲帝国转型的味道。

扩展国号推荐：

- 法西斯/极端民族主义：`中华复兴国`。比“中华民族国”更有十九至二十世纪“民族复兴”政治语感，也不直接撞现实国号；适合 `coa_fascist_trigger = yes`。
- 法团国家：共和政体用 `中华法团共和国`；若仍保留君主制，则用 `大明法团国`。`law_corporate_state` 是权力结构法，不一定废君，所以分两套更稳。
- 技术官僚：`中华技政共和国`。比“技术官僚国”短，游戏界面里也更像正式国号。
- 神权/国教国家：`中华礼教国`。大明宗教是儒教时，用“礼教”比“圣教”更有东亚味道。
- 军政府/独裁政体：`中华护国政府`。适合作为军事独裁、紧急政府、训政前期的动态国名。
- 单党国家：`中华训政共和国`。比直接写“单党国”更有中国近代政治风味，也能覆盖非共产主义的一党专政。
- 无政府/公社路线：`中华自由公社联盟`。如果 `law_anarchy` 和 `law_council_republic` 同时存在，建议它优先于“中华苏维埃社会主义共和国联盟”。

不推荐把正式国号写成“非洲中华共和国”。“非洲”适合作为日志、事件或外号，例如“海外大明”“非洲天朝”；正式国号建议始终围绕“大明/中华”，这样和大清、中国统一战争目标的正统叙事更一致。

动态国名可继续扩展：

```txt
MGN = {
    dynamic_country_name = {
        name = dyn_c_great_ming
        adjective = dyn_c_great_ming_adj
        is_main_tag_only = yes
        priority = 100
        trigger = { coa_def_monarchy_flag_trigger = yes }
    }
    dynamic_country_name = {
        name = dyn_c_ming_soviet_union
        adjective = dyn_c_ming_soviet_union_adj
        is_main_tag_only = yes
        priority = 90
        trigger = {
            has_law_or_variant = law_type:law_council_republic
        }
    }
    dynamic_country_name = {
        name = dyn_c_ming_federal_republic
        adjective = dyn_c_ming_federal_republic_adj
        is_main_tag_only = yes
        priority = 80
        trigger = {
            has_law_or_variant = law_type:law_parliamentary_republic
        }
    }
    dynamic_country_name = {
        name = dyn_c_ming_republic
        adjective = dyn_c_ming_republic_adj
        is_main_tag_only = yes
        priority = 70
        trigger = {
            has_law_or_variant = law_type:law_presidential_republic
        }
    }
}
```

扩展动态国名实现时建议按优先级覆盖：

```txt
# 示例片段，实际可拆成多个 dynamic_country_name 块
# 高优先级：无政府、公社、神权、法西斯、技术官僚、法团
trigger = { has_law_or_variant = law_type:law_anarchy }                # dyn_c_ming_anarchist
trigger = { has_law_or_variant = law_type:law_theocracy }              # dyn_c_ming_theocracy
trigger = { coa_fascist_trigger = yes }                                # dyn_c_ming_fascist
trigger = { has_law_or_variant = law_type:law_technocracy }            # dyn_c_ming_technate
trigger = {
    has_law_or_variant = law_type:law_corporate_state
    has_law_or_variant = law_type:law_monarchy
}                                                                      # dyn_c_ming_corporate_monarchy
trigger = { has_law_or_variant = law_type:law_corporate_state }         # dyn_c_ming_corporate_republic
trigger = { has_law_or_variant = law_type:law_single_party_state }      # dyn_c_ming_single_party
```

注意：`law_corporate_state`、`law_technocracy`、`law_single_party_state` 这类通常不是“君主/共和”本身，而是权力分配或国家结构。实现时要给 `priority` 排序，避免“君主制大明”和“法团国家”互相覆盖得不合预期。

备选国号：

- 如果想更保守、少碰现实名称：`大明共和国`、`大明联邦共和国`、`大明人民国`。
- 如果想更强烈宣称全中国正统：`中华民国`、`中华共和国`、`中华人民共和国`。
- 如果想让委员会共和更短、更少苏联味：`中华苏维埃共和国`、`中华人民共和国` 或 `大明人民共和国`。
- 如果想保留“大明”招牌：总统共和也可用 `大明民国`，但中文观感略奇，沉浸感不如 `中华民国`。

### 旗帜

君主制旗帜推荐使用“大清龙旗的镜像式变体”：构图仍接近大清/中国龙旗，但改为朱红、金黄、少量橙白祥云的明式色彩。这样比完全同旗更有代入感，也能在中明对峙时一眼看出“同源争天命”。

共和/议会共和/委员会共和旗帜不再直接复用中国原版五色旗，而是统一使用朱红金黄体系，减少与大清/原版中国重复。

当前实现已新增大明专属 coat of arms：

- `MGN`：朱红底、金黄圆龙，用作默认旗帜。
- `MGN_absolute_monarchy`：朱红底、金黄中国龙和祥云，用作君主制主旗。
- `MGN_subject`：朱红底、金黄圆龙 canton，用作属国/宗主 canton 组合。
- `MGN_republic`：朱红底、中央金色日章和圆环，用作总统/议会共和。旧版左上色块实测容易显示成白块，已改为无 canton 的整面日章旗。
- `MGN_dictatorship`：黑边朱红金日，用作军政府、独裁、紧急政府等。
- `MGN_corporate`：黑金边、朱红底、金色环饰和日纹，用作法团国家/法西斯类政体。
- `MGN_theocracy`：朱红底、礼制边框、金龙和祥云，用作神权/礼教国。
- `MGN_communist`：朱红底金星，用作委员会共和/苏维埃路线。

旧技术方案是先让 `MGN` 旗帜定义引用大清/中国的 coat of arms，确认玩法能跑通；正式版再替换为自定义 `MGN_absolute_monarchy`、`MGN_republic`、`MGN_communist`：

```txt
MGN = {
    flag_definition = {
        coa = CHI
        subject_canton = CHI
        coa_with_overlord_canton = CHI_subject
        allow_overlord_canton = yes
        priority = 1
    }
    flag_definition = {
        coa = CHI_han_empire
        coa_with_overlord_canton = CHI_han_empire
        priority = 5
        trigger = { country_has_monarchy_law = yes }
    }
    flag_definition = {
        coa = CHI_republic
        subject_canton = CHI_republic
        allow_overlord_canton = yes
        priority = 10
        trigger = { coa_def_republic_flag_trigger = yes }
    }
    flag_definition = {
        coa = CHI_communist
        priority = 1500
        trigger = { coa_def_communist_flag_trigger = yes }
    }
}
```

如果开局只想和大清完全同旗，不触发汉帝国旗，则开局旗帜可以固定 `coa = CHI_absolute_monarchy` 或 `coa = CHI`。这点建议进游戏看一眼效果再定。

## 3. 开局法律和科技

复制大清 `chi - china.txt` 的技术、税率、市场设定和法律，但按当前实测结论做以下调整：

1. 不添加 `je_warlord_china`，避免大明拥有“脆弱的统一”。
2. 追加 `activate_law = law_type:law_slave_trade`，满足奴隶贸易要求。
3. 把大清的 `law_closed_borders` 改为 `law_no_migration_controls`，让中华圈人口可以向非洲大明迁徙。
4. 开局采用 `law_colonial_resettlement`，并确保拥有 `colonization` 科技。
5. 开局贸易政策改为 `law_mercantilism`，不再使用大清的 `law_canton_system`。
6. 开局海军模式改为 `law_professional_navy`，并确保拥有 `military_drill` 科技。
7. 首都和市场首都改为 `STATE_LOWER_EGYPT`。

建议历史文件：

```txt
COUNTRIES = {
    c:MGN ?= {
        effect_starting_technology_tier_4_tech = yes
        add_technology_researched = urban_planning
        add_technology_researched = sericulture
        add_technology_researched = academia
        add_technology_researched = law_enforcement
        add_technology_researched = colonization
        add_technology_researched = international_trade
        add_technology_researched = military_drill

        set_market_capital = STATE_LOWER_EGYPT

        activate_law = law_type:law_monarchy
        activate_law = law_type:law_autocracy
        activate_law = law_type:law_serfdom
        activate_law = law_type:law_land_based_taxation
        activate_law = law_type:law_appointed_bureaucrats
        activate_law = law_type:law_mgn_heavenly_subjecthood
        activate_law = law_type:law_traditionalism
        activate_law = law_type:law_censorship
        activate_law = law_type:law_no_migration_controls
        activate_law = law_type:law_colonial_resettlement
        activate_law = law_type:law_mercantilism
        activate_law = law_type:law_freedom_of_conscience
        activate_law = law_type:law_slave_trade
        activate_law = law_type:law_professional_navy

        set_tax_level = low
        add_modifier = {
            name = mgn_heavenly_court_in_africa
            days = 7300
            is_decaying = yes
        }
        add_modifier = {
            name = mgn_southern_court_administration
            days = 7300
            is_decaying = yes
        }
    }
}
```

注意：

- `law_slave_trade` 与 `law_cultural_exclusion`、`law_multicultural`、`law_affirmative_action` 原版互斥，所以不能靠 `law_cultural_exclusion` 来同时满足“奴隶贸易”和“非洲文化二等公民”。
- `law_colonial_resettlement` 需要 `colonization` 科技。大清起始科技若在当前版本已包含它，可以不重复添加；为了稳妥，建议大明历史文件显式 `add_technology_researched = colonization`。
- 大明已经拥有并整合全非洲，殖民安置主要是为了后续迁徙和设定味道，不是为了继续殖民非洲本身。

## 4. 非洲全境归属和整合

原版 `geographic_region_africa` 包含以下战略区：

- `region_nile_basin`
- `region_north_africa`
- `region_west_africa`
- `region_equatorial_africa`
- `region_southern_africa`
- `region_east_africa`

具体州清单来自 `common/strategic_regions/african_strategic_regions.txt`：

```txt
STATE_EGYPTIAN_DESERT STATE_MIDDLE_EGYPT STATE_UPPER_EGYPT STATE_LOWER_EGYPT STATE_SINAI STATE_DONGOLA STATE_DARFUR STATE_KORDOFAN STATE_EQUATORIA STATE_BLUE_NILE STATE_MATRUH
STATE_WEST_SAHARA STATE_SAHARA STATE_EAST_SAHARA STATE_MARRAKECH STATE_FEZ STATE_AL_RIF STATE_INNER_MOROCCO STATE_ORAN STATE_ALGIERS STATE_CONSTANTINE STATE_TUNISIA STATE_LIBYA STATE_LIBYAN_DESERT STATE_TRIPOLI
STATE_SENEGAL STATE_GUINEA STATE_SIERRA_LEONE STATE_LIBERIA STATE_WINDWARD_COAST STATE_IVORY_COAST STATE_GOLD_COAST STATE_VOLTA STATE_WESTERN_MALI STATE_EASTERN_MALI STATE_MAURITANIA STATE_TIMBUKTU STATE_INNER_MAURITANIA STATE_NIGERIA STATE_NIGER_DELTA STATE_YORUBA_STATES STATE_OUTER_HAUSALAND STATE_HAUSALAND STATE_EAST_HAUSALAND STATE_BORNU STATE_BENIN STATE_TOGO STATE_DAHOMEY STATE_NIGER
STATE_BAS_CONGO STATE_CONGO STATE_KASAI STATE_EQUATEUR STATE_CONGO_ORIENTALE STATE_UBANGI_SHARI STATE_NORTH_ANGOLA STATE_EAST_ANGOLA STATE_SOUTH_ANGOLA STATE_GABON STATE_SOUTH_CAMEROON STATE_KATANGA STATE_CHAD STATE_NORTH_CAMEROON STATE_WADDAI
STATE_NAMAQUALAND STATE_BOTSWANA STATE_NORTHERN_CAPE STATE_CAPE_COLONY STATE_EASTERN_CAPE STATE_VRYSTAAT STATE_TRANSVAAL STATE_ZULULAND STATE_HEREROLAND
STATE_ZANZIBAR STATE_LINDI STATE_MOCAMBIQUE STATE_TANGANYIKA STATE_SOUTH_MADAGASCAR STATE_NORTH_MADAGASCAR STATE_INDIAN_OCEAN_TERRITORY STATE_KAZEMBE STATE_ZAMBEZIA STATE_KENYA STATE_RIFT_VALLEY STATE_UGANDA STATE_ZAMBEZI STATE_ZAMBIA STATE_LOURENCO_MARQUES STATE_ERITREA STATE_GONDER STATE_AMHARA STATE_OROMIA STATE_SOMALILAND
```

实现方法：

1. 读取原版 `history/states/00_states.txt` 中每个非洲 `s:STATE_*` 块。
2. 对每个非洲州只保留一个 `create_state`：

```txt
s:STATE_LOWER_EGYPT = {
    create_state = {
        country = c:MGN
        owned_provinces = { ...该州全部陆地省份... }
        state_type = incorporated
    }
    # 保留原有 add_homeland / add_claim，除非后续想压制民族国家可释放性
}
```

3. 不再给原有非洲国家任何开局省份；没有领土的国家不会作为开局国家存在。
4. 保留非洲各文化 homeland，以保证人口、分离主义和文化接受度逻辑仍有地方感。

建议写一个生成脚本从 `map_data/state_regions/*.txt` 或原版 `history/states/00_states.txt` 提取全部 `provinces/owned_provinces`，批量生成上述块，避免手工漏省份。

## 5. 非洲文化达到二等公民

原版接受度阈值在 `script_values/event_values.txt`：

- `second_rate_citizen` 下限是 60。
- `full_acceptance` 下限是 80。

### 推荐方案：桥梁文化

使用 `han + african_han + western_han` 三主流文化后，非洲接受度会比“仅汉”自然得多：

- 撒哈拉以南非洲文化通常与 `african_han` 共享 `heritage_group_african`。
- 北非、埃及、马格里布、部分阿拉伯化区域通常与 `western_han` 共享 `heritage_group_middle_eastern`。
- `han` 继续保证中国统一玩法和正统中华身份。

但这不保证所有非洲文化都稳定达到二等公民。大清同款 `law_subjecthood` 对 homeland 文化给 `country_acceptance_homeland_add = 30`，共享 heritage group 的加成通常还不足以在所有情况下稳定达到 60；宗教接受度、具体文化 trait 和局部机制也可能影响结果。

因此推荐先使用桥梁文化，再保留一个很小的隐藏国家修正作为保险：

```txt
mgn_african_second_rate_framework = {
    icon = "gfx/interface/icons/event_icons/event_default.dds"
    country_acceptance_homeland_add = 15
}
```

这样做的好处是：

- 不把现有非洲文化直接设为主流文化。
- 不全局修改 `han` 或所有非洲文化。
- 数值修正比旧方案更小，主要解释仍来自“大明本地化统治阶层”的桥梁文化。
- 如果进游戏后已能自然达到二等公民，可以把该修正去掉。

### 旧方案：仅汉 + 隐藏修正

如果之后想回到最初的严格设定，即主流文化有且仅有 `han`，则使用旧方案：给大明开局一个隐藏国家修正 `mgn_african_second_rate_framework`，只补足 homeland 接受度，不把非洲文化设为主流文化：

```txt
mgn_african_second_rate_framework = {
    icon = "gfx/interface/icons/event_icons/event_default.dds"
    country_acceptance_homeland_add = 30
}
```

这样非洲 homeland 文化的文化接受度约为 `30 + 30 = 60`，正好到二等公民门槛；汉仍是唯一主流文化。若进游戏后因为宗教接受度拖低总接纳地位，可把数值提高到 `55` 或枚举非洲文化使用 `country_<culture>_cultural_acceptance_add = 60`。

替代方案：

- 改为 `law_cultural_exclusion`：非洲文化更容易被接纳，但会违反“与大清法律相同”和“奴隶贸易”互斥。
- 给所有非洲文化加 `heritage_han` 或新增共享 trait：不推荐，会污染全局文化系统。
- 自定义一个“大明臣民制”法律：最干净但工程量更大，也更容易和未来版本冲突。
- 给所有非洲文化和汉文化加共同 tradition/race trait：可行，但需要覆盖大量文化定义，并会全局影响这些文化在其他国家的接受度，兼容性差。

## 6. 脆弱的统一日志

不要在 `mgn - ming.txt` 里执行：

```txt
add_journal_entry = { type = je_warlord_china }
set_variable = { name = china_warlord_explosion value = 0 }
```

原版 `je_warlord_china` 是“脆弱的统一”核心。大明只要不添加该日志，即使主流文化是汉，也不会开局出现它。

为了保险，可增加一个覆盖/补丁版本，使该日志 `possible` 排除 `c:MGN`：

```txt
possible = {
    NOT = { c:MGN ?= THIS }
    # 原版条件...
}
```

但这需要覆盖整个原版日志定义，兼容性差。推荐先不覆盖，只靠“不添加日志”解决。

## 7. 统一中国战争目标

原版 `dp_unify_china` 已经允许：

- 发起者：有 `je_reunify_china`、是 `global_var:chinese_central_government`，或是 `c:CHI`。
- 目标：有 `je_reunify_china`、是中央政府，或主流文化含 `han/manchu`。

因为大明主流文化是 `han`，大清作为 `c:CHI` 可以对大明使用统一中国。反过来，大明默认不是 `c:CHI`，也未必有 `je_reunify_china`，所以需要补发起者条件：

```txt
dp_unify_china = {
    # 复制原版定义，只改 selectable_in_lens 和 possible 中的发起者 OR
    selectable_in_lens = {
        OR = {
            has_journal_entry = je_reunify_china
            global_var:chinese_central_government ?= THIS
            c:CHI ?= this
            c:MGN ?= this
        }
    }

    possible = {
        NOT = { is_country_type = decentralized }
        is_subject = no
        OR = {
            has_journal_entry = je_reunify_china
            global_var:chinese_central_government ?= THIS
            c:CHI ?= this
            c:MGN ?= this
        }
        # 目标条件沿用原版
    }
}
```

这会覆盖整个 `dp_unify_china`，需要跟版本更新保持同步。

## 8. 大清与大明互相要求朝贡/附庸

原版 `dp_make_tributary`、`dp_make_dominion` 等玩法通常受国家地位、国家类型、承认状态、是否可进攻等条件限制。需求是大清与大明之间“不论国家地位”都可以互相提出，而且最好能扩展到其他中华分裂国家。

### 8.1 推荐方案：新增一个专用“中华臣服”战争目标

推荐新增一个独立外交博弈/战争目标，例如：

- `dp_mgn_chinese_subjugation`
- `mgn_chinese_subjugation`
- 本地化显示为“要求臣服”或“要求中华臣服”

这个战争目标只在“大清 / 大明 / 其他中华分裂国家”之间出现，不改动全局 `dp_make_tributary`、`dp_make_dominion`，避免让英国、法国等国家获得额外漏洞。

核心做法：

1. 在 `common/war_goal_types/` 新增 `mgn_chinese_subjugation`。
2. 使用 `kind = custom`，不用固定的 `kind = make_tributary` 或 `kind = make_dominion`。
3. 在 `settings` 中保留臣属战争目标常用校验，例如 `turns_into_subject`、`conflicts_with_make_subject`、`validate_conflicts_make_subject`。
4. 在 `possible` 中限制双方必须属于“中华臣服圈”。
5. 在 `valid` 中只保留非常稳定的条件，不把国家地位、承认状态、排名写死进去。
6. 在 `on_enforced` 里动态决定结算为朝贡、附庸、傀儡或保护国。

原版 war goal 的 `kind` 是固定效果：`make_tributary` 只会做朝贡，`make_dominion` 只会做自治领/附属国类型；如果想“一个按钮，结算时根据国家地位动态变”，就应使用 `kind = custom` 并自己写 `on_enforced`。

参考骨架：

```txt
mgn_chinese_subjugation = {
    icon = "gfx/interface/icons/war_goals/make_tributary.dds"

    kind = custom

    settings = {
        require_target_be_part_of_war
        turns_into_subject
        can_add_for_other_country
        requires_interest

        conflicts_with_make_subject
        validate_conflicts_make_subject
    }

    execution_priority = 13
    contestion_type = control_target_country_capital
    target_type = country

    possible = {
        mgn_is_chinese_subjugation_country = yes
        scope:target_country = {
            mgn_is_chinese_subjugation_country = yes
            is_subject = no
            NOT = { is_country_type = decentralized }
        }
    }

    valid = {
        scope:target_country ?= {
            NOT = { is_country_type = decentralized }
        }
    }

    on_enforced = {
        if = {
            limit = {
                scope:target_country = {
                    is_country_type = unrecognized
                }
            }
            ROOT = {
                create_diplomatic_pact = {
                    country = scope:target_country
                    type = tributary
                }
            }
        }
        else_if = {
            limit = {
                scope:target_country = {
                    is_country_type = recognized
                }
            }
            ROOT = {
                create_diplomatic_pact = {
                    country = scope:target_country
                    type = puppet
                }
            }
        }
        else = {
            ROOT = {
                create_diplomatic_pact = {
                    country = scope:target_country
                    type = vassal
                }
            }
        }
    }
}
```

`create_diplomatic_pact` 的 `type` 使用外交行动 id，而不是 subject type id。原版已有 `type = tributary`、`type = dominion`、`type = protectorate`、`type = personal_union` 的写法；`vassal` 也存在对应外交行动，并映射到 `subject_type_vassal`。

推荐默认映射：

- 目标是 `unrecognized`：结算为 `tributary`，符合大清体系的“朝贡国”味道。
- 目标是 `recognized`：结算为 `puppet` 或 `dominion`。如果希望“附庸国”更硬，选 `puppet`；如果希望保留较高自治，选 `dominion`。
- 如果后续测试确认 `vassal` 可由战争目标结算直接创建，也可把中华圈专用附庸统一用 `vassal`。

为了限制适用范围，建议新增 scripted trigger：

```txt
mgn_is_chinese_subjugation_country = {
    OR = {
        c:CHI ?= THIS
        c:MGN ?= THIS
        has_journal_entry = je_reunify_china
        global_var:chinese_central_government ?= THIS
        country_has_primary_culture = cu:han
        country_has_primary_culture = cu:manchu
        country_has_primary_culture = cu:african_han
        country_has_primary_culture = cu:western_han
    }
}
```

这样可覆盖大清、大明、太平天国和多数汉/满主流文化的中国分裂国家。若想更保守，可以把触发器改成明确 tag 白名单，但维护成本更高。

### 8.2 避免国家地位变化导致战争目标丢失

如果把“朝贡/附庸”拆成两个原版式战争目标，那么目标从未承认变成已承认、或排名变化时，`possible/valid` 很容易让战争目标从外交博弈里失效。

所以推荐：

- `possible` 用来决定按钮是否出现，可以检查中华圈身份和“不是已有臣属”等基础条件。
- `valid` 只检查目标还存在、不是分权国家、没有变成同一国家这类稳定条件。
- 国家地位和承认状态只放在 `on_enforced` 里决定最终臣属类型。

这会比两个分离按钮更能满足“国家地位动态调整”的需求。

### 8.3 备选方案：复制原版朝贡/附庸外交博弈

旧方案仍保留为备选：复制 `dp_make_tributary`、`dp_make_dominion` 等外交博弈，新增大清/大明/中华分裂国家特例。

优点：

- 更接近原版行为。
- AI、恶名、机动点、战争目标文案更容易复用。

缺点：

- 至少要维护两个按钮。
- 很难做到“同一个战争目标根据国家地位动态变成朝贡或附庸”。
- 国家地位变化时更容易出现战争目标失效或不符合预期的问题。

因此首版建议优先做 `kind = custom` 的专用中华臣服战争目标；若测试发现 custom war goal 的 AI 或结算兼容性不足，再退回复制原版外交博弈的备选方案。

### 8.4 大明专用“开放中华迁徙”战争目标

新增一个大明专用战争目标，让大明可以对所有其他中华国家强制执行 `law_no_migration_controls`。这相当于温和版“政权更迭”：不改目标国家政府形态、不吞地、不变成臣属，只强迫对方开放人口流动。

推荐命名：

- 外交博弈：`dp_mgn_open_chinese_migration`
- 战争目标：`mgn_open_chinese_migration`
- 本地化：`开放中华迁徙` 或 `强制开放迁徙`

适用范围：

- 发起者必须是 `c:MGN`。
- 目标必须是其他中华国家：大清、太平天国、中国分裂国家，或前文 `mgn_is_chinese_subjugation_country` 触发器识别到的国家。
- 目标当前不能已经拥有 `law_no_migration_controls`。

外交博弈建议：

```txt
dp_mgn_open_chinese_migration = {
    war_goal = mgn_open_chinese_migration
    texture = "gfx/interface/icons/war_goals/regime_change.dds"

    possible = {
        c:MGN ?= THIS
        aggressive_diplomatic_plays_permitted = yes
        scope:target_country = {
            mgn_is_chinese_subjugation_country = yes
            NOT = { c:MGN ?= THIS }
            NOT = { is_country_type = decentralized }
            NOT = { has_law_or_variant = law_type:law_no_migration_controls }
        }
    }

    ai_acceptance_max = 100

    # 保持要求轻量，避免小目标被双方不断加码成全面战争。
    initiator_can_add_war_goals = no
    target_can_add_war_goals = no

    on_weekly_pulse = {}
    on_war_begins = {}
    on_war_end = {}
}
```

战争目标建议使用 `kind = custom`：

```txt
mgn_open_chinese_migration = {
    icon = "gfx/interface/icons/war_goals/regime_change.dds"

    kind = custom

    settings = {
        require_target_be_part_of_war
        requires_interest
    }

    execution_priority = 20

    # 比政权更迭更容易打成；不要求占领首都。
    contestion_type = control_any_target_country_state
    target_type = country

    possible = {
        c:MGN ?= THIS
        scope:target_country = {
            mgn_is_chinese_subjugation_country = yes
            NOT = { c:MGN ?= THIS }
            NOT = { has_law_or_variant = law_type:law_no_migration_controls }
        }
    }

    valid = {
        scope:target_country ?= {
            NOT = { is_country_type = decentralized }
            NOT = { has_law_or_variant = law_type:law_no_migration_controls }
        }
    }

    maneuvers = {
        value = 3
    }

    infamy = {
        value = 1
    }

    on_enforced = {
        scope:target_country = {
            activate_law = law_type:law_no_migration_controls
        }
    }

    ai = {
        is_significant_demand = no
    }
}
```

让对方更容易战前退让的关键点：

- `ai_acceptance_max = 100`：允许 AI 在条件合适时接受外交要求。
- `is_significant_demand = no`：让 AI 把它视为低烈度要求。
- `maneuvers = { value = 3 }`、`infamy = { value = 1 }`：成本和威胁感低于政权更迭。
- 该战争目标不使用 `validate_conflicts_war_goals_all`，允许叠加到“统一中国”“中华臣服”等更大目标上，作为低烈度附加要求。
- `contestion_type = control_any_target_country_state`：如果真的开战，不必攻占北京或目标首都，达成难度比 `control_target_country_capital` 低。

如果测试发现固定 `infamy = 1` 太低，可改成 `0.5-2` 的固定值；不建议使用人口缩放，否则对大清会因为人口巨大而变得不像“轻量开放迁徙”要求。

## 9. 势力与人物

不建议直接照抄原版大清的全部人物。道光、奕詝、耆英、林则徐等真人留在大清更好；如果原封不动复制到非洲大明，会让设定变成“大清分身”，削弱“大明另立天命”的代入感。

推荐做法是：

- 势力机制照抄或复用大清/中国特色。
- 势力名称改成“大明海外朝廷”风格。
- 人物使用半虚构历史人物，保留明廷官职、年号、地域身份和派系冲突。
- 少量人物使用 `african_han`、`western_han`，体现非洲本地精英已经进入大明体制。

### 9.1 利益集团名称与特质

原版大清的很多特色不是写在 `history/countries/chi - china.txt`，而是写在通用 `common/interest_groups/` 中，通过 `c:CHI` 或汉文化/儒教条件触发。大明使用新 tag `MGN` 后，需要补自己的名称和特质。

推荐利益集团：

| 原版 IG | 大明名称建议 | 推荐机制 |
| --- | --- | --- |
| `ig_landowners` | `士绅官僚` 或 `海外士绅` | 复用大清 `ig_scholar_officials` 路线：移除 `ideology_paternalistic`，加入 `ideology_scholar_paternalistic`。 |
| `ig_devout` | `儒学士` | 大明国教为儒教时，原版会自动倾向 `ig_confucian` 逻辑；可直接沿用儒学意识形态。 |
| `ig_intelligentsia` | `海外文人` | 复用中国文人 `ig_literati` 的命名逻辑，并保留大清特质 `social_criticism / avant_garde / restoration`。 |
| `ig_armed_forces` | `神机营` 或 `天朝新军` | 复用大清军队三特质：`newly_created_army`、`self_strengthening`、`parochial_leadership`。非常适合非洲大明“版图巨大、军制新造、地方军头很多”的开局。 |
| `ig_petty_bourgeoisie` | `会馆商民` | 不必强改意识形态，主要用名称表现沿海商埠、华人会馆和转运商人。 |
| `ig_industrialists` | `市舶商帮` | 开局较弱；后续工业化时代表开罗、桑给巴尔、开普等港口资本。 |
| `ig_rural_folk` | `里甲乡民` | 代表被编入大明户籍体系的本地农民和乡约组织。 |
| `ig_trade_unions` | `工匠行会` | 早期比“工会”更有 1836 年味道，后期可随社会主义改名。 |

首版建议只写名称和少量特质，不新建完整 IG 类型。直接新建 IG 会牵动党派、事件、意识形态权重，成本高且容易和原版更新冲突。

示意脚本可放在大明开局历史文件里：

```txt
c:MGN ?= {
    ig:ig_landowners ?= {
        set_interest_group_name = ig_mgn_scholar_officials
        remove_ideology = ideology_paternalistic
        add_ideology = ideology_scholar_paternalistic
        add_ruling_interest_group = yes
    }
    ig:ig_devout ?= {
        set_interest_group_name = ig_mgn_confucian_scholars
        remove_ideology = ideology_pious
        remove_ideology = ideology_moralist
        add_ideology = ideology_confucian
        add_ruling_interest_group = yes
    }
    ig:ig_armed_forces ?= {
        set_interest_group_name = ig_mgn_divine_engine_camp
        set_ig_trait = ig_trait:ig_trait_newly_created_army
        set_ig_trait = ig_trait:ig_trait_self_strengthening
        set_ig_trait = ig_trait:ig_trait_parochial_leadership
        add_ruling_interest_group = yes
    }
    ig:ig_intelligentsia ?= {
        set_interest_group_name = ig_mgn_overseas_literati
        remove_ideology = ideology_anti_clerical
        set_ig_trait = ig_trait:ig_trait_social_criticism
        set_ig_trait = ig_trait:ig_trait_avant_garde
        set_ig_trait = ig_trait:ig_trait_restoration
    }
}
```

如果想减少与原版通用 IG 文件的冲突，优先把这些写入 `history/countries/mgn - ming.txt`。只有当开局历史执行顺序导致 `on_enable` 覆盖它们时，再考虑复制并 patch 通用 `interest_groups` 条件。

### 9.2 开局人物建议

推荐做 8-10 个开局人物。人物越多越有味道，但首版不宜过多，否则维护本地化和头像 DNA 会变成负担。

建议人物班底：

| 角色 | 名称建议 | 文化 | IG | 设定功能 |
| --- | --- | --- | --- | --- |
| 皇帝 | `绍明帝 朱氏` | `han` | `ig_landowners` | 开局君主，传统主义，代表海外明统。 |
| 皇储 | `承烈 朱氏` | `han` | `ig_landowners` | 年幼继承人，保留王朝延续感。 |
| 首辅/大学士 | `李景和` | `han` | `ig_landowners` | 士绅官僚领袖，支持专制和任命官僚。 |
| 儒学领袖 | `陈守仁` | `han` | `ig_devout` | 儒学士领袖，反对激进改革，支持宗法秩序。 |
| 神机营提督 | `张镇海` | `han` | `ig_armed_forces` | 军队领袖/将军，主张自强和扩军。 |
| 海关/商帮人物 | `沈万泽` | `han` 或 `western_han` | `ig_industrialists` | 市舶商帮领袖，推动港口、造船、铁路。 |
| 会馆商民领袖 | `黄开埠` | `han` | `ig_petty_bourgeoisie` | 城市中产与税关网络代表。 |
| 海外文人 | `顾观澜` | `han` | `ig_intelligentsia` | 改革派或温和派，提供废奴/开国门剧情钩子。 |
| 归化地方领袖 | `马哈茂德·郑` | `western_han` | `ig_rural_folk` 或 `ig_landowners` | 北非本地精英进入明制，解释“西域中华”。 |
| 南洲地方领袖 | `恩科西·李` | `african_han` | `ig_rural_folk` 或 `ig_armed_forces` | 撒哈拉以南本地精英，解释“非洲中华”。 |

这里的名字只是占位。正式实现时可用更像 Vic3 的罗马化键名，例如 `Shaoming`、`Zhu`、`Jinghe`、`Li`，再在本地化里显示中文。

### 9.3 是否使用真实历史人物

建议分三层：

1. 大清真人不复制到大明。保留大清独立性，也避免“大明皇帝怎么是爱新觉罗”的违和。
2. 非洲原有国家的真实人物可以少量改造为 `african_han` / `western_han` 角色，但不要全量搬运。比如把个别北非、埃塞、桑给巴尔、南非人物设为归化地方领袖或将领。
3. 大明核心朝廷人物用半虚构。名字、官职、年号有历史味即可，不必强行对应真实明朝宗室。

首版推荐只做半虚构人物，等国家、文化、战争目标都稳定后，再追加“归化地方领袖”人物包。

### 9.4 开局权力结构

开局政府建议：

- `ig_landowners`：主导政府，代表士绅官僚和皇权基础。
- `ig_devout`：入政府，代表儒学正统。
- `ig_armed_forces`：入政府或接近入政府，代表征服非洲后形成的新军体系。

在野势力建议：

- `ig_intelligentsia`：改革派，有废奴、开国门、宪政潜力。
- `ig_industrialists` / `ig_petty_bourgeoisie`：港口和商帮，随着工业化抬头。
- `ig_rural_folk`：庞大但政治组织弱，适合承载地方不满和改革压力。
- `ig_trade_unions`：开局弱，工业化后再出现存在感。

这样开局会有“大清式保守结构”，但不是照抄大清；它多了一层非洲统治、商埠网络和地方归化精英的张力。

## 10. 建筑、军队和开局体验

如果只改州归属，非洲原有建筑会保留在各州，但所有权和国家引用可能仍指原国家或建筑国家字段。建议同步处理：

1. `common/history/buildings/03_north_africa.txt`
2. `common/history/buildings/04_subsaharan_africa.txt`
3. `common/history/military_formations/03_military_formations_north_africa.txt`
4. `common/history/military_formations/07_military_formations_subsaharan_africa.txt`

推荐方案：

- 建筑：保留原建筑分布，把 `country = "c:XXX"` 改为 `country = "c:MGN"`，避免建筑归属异常。
- 军队：不要把所有非洲国家军队简单合并，否则开局部队可能离谱。建议给大明固定一组“中国式但规模折中”的部队，北非/西非/南非各几个军区，海军弱一些。
- 人物：按第 9 节做半虚构海外明廷班底；首版不直接移植大清人物，非洲本地人物可留作后续人物包。

## 11. 测试清单

进游戏 1836 开局检查：

- 国家选择界面显示“大明”，旗帜与大清近似/一致。
- 大明拥有所有 `geographic_region_africa` 陆地州。
- 大明首都和市场首都都是 `STATE_LOWER_EGYPT`。
- 下埃及首都城市 hub 显示为“应天府”，港口 hub 显示为“靖海港”。
- 首都州可建造“南都紫禁城”，其效果应等同北京紫禁城；开局不直接建成。
- 非洲没有原有开局国家，包括集中化和非集中化国家。
- 大明所有非洲州都是 incorporated。
- 初版路线：大明主流文化为汉、非洲中华、西域中华；“主流文化只有汉”的旧方案只作为备选记录，不纳入初版验收。
- 法律大体与大清一致，但奴隶制为 `law_slave_trade`，移民法为 `law_no_migration_controls`，殖民法为 `law_colonial_resettlement`，贸易政策为 `law_mercantilism`，海军模式为 `law_professional_navy`。
- 大明开局有 20 年衰减的“南都行台”强力行政力加成，初始行政力加成约 `+1250%`。
- “天朝在非洲”不再削行政力，而是提供建设效率、权威、机构成本、税收能力等统治摩擦。
- 大明没有 `je_warlord_china` / “脆弱的统一”。
- 大明开局利益集团显示为士绅官僚、儒学士、神机营、海外文人等自定义名称；皇帝和主要 IG 领袖不是大清原版人物。
- 大清能对大明使用“统一中国”；大明能对大清和中国分裂国家使用“统一中国”。
- 大清、大明和中华分裂国家之间能发起专用“中华臣服”外交博弈；结算时能按目标国家地位变成朝贡、附庸、傀儡或自治领。
- 大明能对大清和其他中华分裂国家使用“开放中华迁徙”外交博弈；该战争目标可叠加到其他战争目标上，目标退让或战败后变为 `law_no_migration_controls`。
- “中华臣服”恶名不应过低；初版建议固定为 `8`。
- 开局公民权法律为大明专用“天朝万民”；后续可改革到大明专用“华夷一统”。两者均不与奴隶制互斥，前者偏臣民制度并加同化，后者偏文化多元并加同化、允许弘扬国家价值法令。
- 非洲主流人口的文化接纳状态至少达到“二等公民”；若宗教导致总接纳偏低，调高隐藏修正。
- 开局不额外添加汉文化移民人口，先测试统一非洲、整合、法律和文化接受度本身的强度。

## 待定事项

- 是否给大明添加少量汉文化移民人口：首版先不做。等实测强度后再决定是否在开普、下埃及、桑给巴尔、广州式商埠等地添加少量汉文化官僚、军人、商人或工匠人口。
- 如果后续要加汉文化人口，建议只作为点状移民社群存在，不把非洲本地人口整体改汉。这样既能保留“主流文化汉”的设定，也不会清空非洲本地文化，后续仍有民族主义、分离主义和“非酋体验”。

## 第一轮实测后的确定调整

本节记录第一轮进游戏测试后的调整，视为当前实现初版的一部分。

### A. 首都、命名和奇观

- 首都和市场首都从 `STATE_CAPE_COLONY` 改为 `STATE_LOWER_EGYPT`，理由是开普首都利益扩散过慢，影响大明与大清/中华国家互动。
- 大明拥有下埃及时，下埃及城市 hub 使用专属名“应天府”，港口 hub 使用“靖海港”。实现上优先在 `history/countries/mgn - ming.txt` 中用 `set_hub_name` 设置；若测试发现历史效果不稳定，再改为国家/文化条件动态地名。
- 新增 `building_mgn_forbidden_city`，本地化名“南都紫禁城”。它应在大明首都州可建造，图标、生产方式组和效果复用原版 `building_forbidden_city`，但不要复用原版建筑键，避免与北京紫禁城的 `unique = yes` 互斥或覆盖原版。
- 初版不再开局直接放置“南都紫禁城”，只作为首都可建造奇观。这样既保留目标感，也避免开局额外白送权威/正统性/威望。

### B. 开局法律

在大清法律底盘上追加/替换以下法律：

- 贸易政策：`law_mercantilism`。
- 海军模式：`law_professional_navy`。
- 仍保留：`law_slave_trade`、`law_no_migration_controls`、`law_colonial_resettlement`。
- 确保对应科技：`international_trade`、`military_drill`、`colonization`。

### C. 行政力与开局修正

统一非洲后行政力缺口会直接阻断玩法，因此初版需要强力但会衰减的补偿：

- 新增正面修正 `mgn_southern_court_administration`，本地化“南都行台”。
- 效果：`country_bureaucracy_mult = 12.5`，即 `+1250%` 行政力。
- 持续时间：20 年，`is_decaying = yes`。
- 叙事理由：大明在非洲建立临时军府、行台、黄册户籍和士绅承包行政体系，能在开局强行支撑跨大陆统治；随着制度常态化和地方利益固化，临时效率自然消退。

原“天朝在非洲”负面修正不再削行政力，改为统治摩擦：

- 去掉 `country_bureaucracy_mult` 负值。
- 初版建议加入/保留：建设效率约 `-10%`，权威约 `-15%`，机构成本约 `+25%`，税收能力小幅下降。
- 这样仍有压迫感，但不会因行政力崩盘导致不能玩。

### D. 大明公民权双变体

新增两条大明专用公民权法律，形成“帝国臣民秩序 -> 现代共同体”的改革路线。

`law_mgn_heavenly_subjecthood`，本地化“天朝万民”：

- 所属法律组：`lawgroup_citizenship`。
- `parent = law_subjecthood`，类似 `law_canton_system` 继承父法律意识形态态度。
- 开局采用。
- 定位：臣民制度的天朝/儒家变体，适合君主制、神权、酋邦、殖民行政等前现代统治原则。
- 不与 `law_slave_trade` 互斥。
- 除同化项外，数值尽量贴近原版 `law_subjecthood`。
- 将原版 `state_assimilation_mult = -0.25` 改为同化加成，建议 `state_assimilation_mult = 0.15` 到 `0.25`。
- 保留等级化秩序、政治力量、工资、政府职位等惩罚，表达“万民皆臣”不是现代平权。

`law_mgn_huayi_unity`，本地化“华夷一统”：

- 所属法律组：`lawgroup_citizenship`。
- `parent = law_multicultural`，作为文化多元的天朝/国家共同体变体。
- 作为后续改革目标，不开局采用。
- 需要 `human_rights` 科技，和普通文化多元保持同一科技门槛。
- 定位：把“天下一家”的帝国口号现代化为跨族群国家共同体。
- 不与 `law_slave_trade` 互斥。实现时注意：若引擎把 `parent = law_multicultural` 视为普通文化多元的 variant 并触发奴隶贸易互斥，则需要同步新增大明奴隶贸易变体或退回不设 `parent` 的兼容写法。
- 接受度效果尽量接近 `law_multicultural`。
- 额外加入同化加成，建议 `state_assimilation_mult = 0.25` 到 `0.50`。
- 允许使用“弘扬国家价值”法令。原版 `decree_promote_national_values` 只禁止 `law_multicultural`，不禁止新法律；若测试中 `parent = law_multicultural` 被识别为 variant 并导致法令不可用，再覆盖/补充法令触发条件。

意识形态适配：

- 不全局改原版 `law_multicultural` 或 `law_subjecthood`，只让部分大明专用意识形态对新法律中立或支持。
- 推荐：儒学士/士绅官僚支持或轻微支持“天朝万民”；知识分子、实业家、市舶商帮类支持“华夷一统”；军队中立；地主不强烈反对。
- 保守、沙文、族群民族主义类意识形态对“华夷一统”最多 `disapprove`，避免 `strongly_disapprove` 直接把改革锁死。

### E. 战争目标平衡

- “开放中华迁徙”战争目标应允许叠加到其他战争目标上。实现上去掉 `validate_conflicts_war_goals_all`，保留基本合法性检查，避免它只能单独开博弈导致目标不愿退让。
- “中华臣服”恶名从 `2` 上调。首版建议固定 `8`，比正常附庸/朝贡更便宜，但不再接近免费。

### F. 动态国名实测修正

若测试中发现改变政体后国家仍显示基础本地化名“大明”，优先检查 `common/dynamic_country_names/00_mgn_dynamic_country_names.txt`：

- 不再给 `MGN` 动态国名块使用 `is_main_tag_only = yes`。这是原版成国/主 tag 场景常用限制，对自定义开局 tag 没必要，可能让动态国名不命中。
- 法律类触发统一写在 `scope:actor ?= { ... }` 下，和原版动态国名系统传入当前国家的方式一致。
- 君主制“大明”不再依赖旗帜触发器，直接检查 `scope:actor ?= { country_has_monarchy_law = yes }`，避免国名逻辑被旗帜逻辑牵连。
- 法西斯、军政府这类已经有原版 `coa_def_*` 封装触发器的政体，使用 `coa_def_fascist_flag_trigger`、`coa_def_military_junta_flag_trigger`。这些封装触发器内部会切到 `scope:actor`，比直接调用国家 scope 的 `coa_fascist_trigger` / `coa_military_trigger` 更稳。
- 已补上“中华护国政府”的军政府动态国名触发，避免本地化存在但永远不会显示。

## 其他建议详细方案

本节保留旧方案和二期建议，主要用于以后回滚或扩展。当前实现初版以“第一轮实测后的确定调整”为准。

旧版首版建议曾只做三件事：

1. 加一个会随时间衰减的轻度国家修正“天朝在非洲”，用来抵消“全非洲已整合”带来的过强开局。
2. 固定首都/市场首都为开普殖民地，并准备下埃及叙事备选。
3. 严格保留非洲 homeland 和原有人口文化，不把本地文化洗成汉。

“海外大明”日志建议作为二期功能。日志会牵涉事件、奖励、AI 权重和本地化，首版先不做更利于排错。

### 12.1 “天朝在非洲”开局修正

目标：大明开局拥有并整合整个非洲，如果不加约束，行政、财政和资源规模可能过强。这个修正不应把玩家压死，只制造“远离中原、统治过宽、制度磨合”的感觉，并随时间自然消退。

旧版推荐数值，已被第一轮实测调整取代：

```txt
mgn_heavenly_court_in_africa = {
    country_bureaucracy_mult = -0.10
    country_authority_mult = -0.05
    country_legitimacy_base_add = -5
    state_radicals_from_political_movements_mult = 0.05
}
```

说明：

- `country_bureaucracy_mult = -0.10`：最重要。统一非洲后行政压力应该明显存在，但 -10% 仍可通过政府行政机构补救。
- `country_authority_mult = -0.05`：表现海外朝廷对地方的控制成本，不要再高，否则和大清式专制开局叠加后会太难受。
- `country_legitimacy_base_add = -5`：轻微削弱皇统正当性，表达“海外另立天命”的争议。
- `state_radicals_from_political_movements_mult = 0.05`：让改革/废奴/民族问题更容易有政治波澜，但幅度很小。

历史文件里给 `MGN` 开局添加 20 年衰减修正：

```txt
c:MGN = {
    add_modifier = {
        name = mgn_heavenly_court_in_africa
        days = 7300 # 20 years
        is_decaying = yes
    }
}
```

调参预案：

- 推荐首版使用衰减版，而不是永久修正。这样大明前期需要处理行政和正统性压力，中期自然稳定，不会变成永远背着一个惩罚玩。
- 如果开局太强：把官僚惩罚调到 `-0.15`，或把正统性惩罚调到 `-10`。
- 如果开局太痛苦：删除激进派修正，只保留官僚和正统性惩罚。
- 如果 20 年太短：改成 `days = 10950`，约 30 年；如果只是想要短期开局磨合，则改成 `days = 3650`，约 10 年。
- 不建议首版加基础设施惩罚。非洲本身州多、港口和市场接入已经需要整理，再全局削基础设施会让体验变成修铁路模拟。

### 12.2 首都与地方命名方案

旧版首都默认，已被第一轮实测调整取代：

```txt
capital = STATE_CAPE_COLONY
set_market_capital = STATE_CAPE_COLONY
```

推荐本地化名：

- 开普殖民地：`南都` 或 `开平府`。`南都`简单稳，`开平府`更像明代府名。
- 开普敦城市名：`好望府` 或 `好望京`。`好望府`更自然，`好望京`更有架空味。
- 德兰士瓦：可以在事件/日志里称为`金山矿区`，不必真的改州名。
- 下埃及备选：若改回 `STATE_LOWER_EGYPT`，州名可称 `西京`、`埃及应天府` 或 `尼罗京`。

推荐取舍：

- 想玩得舒服：开普为首都，德兰士瓦和北开普做矿业核心，下埃及做苏伊士门户。
- 想玩叙事：下埃及为首都，开普做南洋式海军/贸易基地。
- 想更“非酋”：桑给巴尔或尼日尔三角洲可以做首都，但疟疾和基础设施压力会明显增加。

### 12.3 保留非洲 homeland 和本地文化

首版原则：

- 不删除原版非洲 homeland。
- 不把非洲原有人口改成 `han`、`african_han` 或 `western_han`。
- 不给非洲文化批量添加中华 trait。
- 大明的“中华化”先通过主流桥梁文化、法律、人物和国号表现，而不是直接改人口。

这样做的好处：

- 保留地方民族主义、分离主义和政治运动空间。
- 避免文化接受度过高导致统一非洲过于平滑。
- 后续可以自然加入“归化地方领袖”“地方自治”“废奴后的身份重组”等事件。

实现提醒：

- `history/states` 里改 owner/incorporation 时，尽量原样保留 `add_homeland = cu:...`。
- `history/pops` 暂时只改国家归属和建筑归属，不批量改 pop culture。
- 若新建 `african_han` / `western_han`，它们是主流桥梁文化，不等于把非洲人口替换成这些文化。

### 12.4 二期日志：“海外大明”

首版先不做；若第一轮测试稳定，推荐二期加入一个轻量 journal entry。

设计目标：给玩家一个“把海外朝廷制度化”的中期目标，用来提前移除或削弱“天朝在非洲”衰减修正，而不是开局白送强度。即使不做日志，修正也会在约 20 年内自行消退；做日志后，玩家可以通过改革和建设提前完成整合。

建议完成条件三选二或四选三：

- 不是 `law_slave_trade`，即废除奴隶贸易。
- 官僚盈余大于 0 或政府行政机构达到指定数量。
- 铁路科技已研究，或若干关键州铁路等级达到要求。
- 首都州、下埃及、德兰士瓦、尼日尔三角洲、刚果等关键州市场接入达到高水平。
- 与大清或任一中华分裂国家达成一次胜利、臣服或统一相关目标。

建议奖励：

```txt
on_complete = {
    remove_modifier = mgn_heavenly_court_in_africa
    add_modifier = {
        name = mgn_overseas_mandate_consolidated
        days = long_modifier_time
    }
}
```

奖励修正建议很克制：

```txt
mgn_overseas_mandate_consolidated = {
    country_bureaucracy_mult = 0.05
    country_legitimacy_base_add = 5
}
```

不建议日志奖励直接给移民吸引力、科技扩散或大量威望。大明已经有整合非洲的巨大底盘，奖励只需要让玩家觉得“朝廷理顺了”，不需要变成超级国家按钮。

### 12.5 二期事件与人物包

如果后续想增加代入感，可以做一个小事件包，但不建议首版塞进去。

推荐方向：

- “归化地方领袖”：从非洲本地精英中生成 `african_han` 或 `western_han` 政治人物，进入军队、文人或商帮势力。
- “废奴风波”：废除奴隶贸易时，让士绅官僚/商帮不满，文人和工会支持。
- “南都营造”：首都州建设政府行政机构、大学、港口后，给短期正统性或官僚奖励。
- “苏伊士门户”：控制并建设下埃及时，给贸易/海军风味事件。

这些内容等基础国家、文化、战争目标跑通后再加，会比首版同时堆上去稳定得多。
