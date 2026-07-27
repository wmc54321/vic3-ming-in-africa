# 大明在非洲 Mod 方案草案

## 目标

给《维多利亚 3》做一个开局剧本式 mod：非洲大陆统一为一个新国家“大明”，首版主流文化采用 `han african_han western_han`，法律大体沿用大清但保留奴隶贸易、无移民控制和殖民安置；原有非洲国家开局不应存在；大明和大清、其他中国分裂国家之间应能互相打“统一中国”，且大清与大明之间无视国家地位限制，互相可用要求成为朝贡国/附庸国类战争目标。中华国家还应能使用移民政策类战争目标，按发起方现行移民法要求目标弛禁迁徙、厘定迁徙章程或闭关封境。

本方案基于本机 Victoria 3 原版文件调研；具体安装路径写入仓库根目录的 `.env.local`，由 `VICTORIA3_GAME_ROOT` 提供。关键原版文件包括：

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
- 两种桥梁文化在各自覆盖区也是本土文化：生成工具为撒哈拉以南各州添加“非洲中华”本土，为北非与中东各州添加“西域中华”本土。这样当地长期形成的中华人口不会承受非本土人口的疟疾死亡率；普通汉文化仍保持非本土，后来迁入的内地移民不会获得同样的环境适应。

旧方案“主流文化仅 `han`，通过隐藏接受度修正让非洲文化达到二等公民”仍保留在本文后文作为备选方案。新推荐方案更有设定解释力，也减少全局改写所有非洲文化的需要；代价是它不再满足最初“主流文化有且仅有汉”的严格条件。

## 初版实现范围

初版以以下选择为准，后文所有“备选”“待定”“二期”内容暂不实现：

- 国家 tag 固定为 `MGN`，不复用 `CHI`。
- 主流文化固定为 `han african_han western_han`，不采用“仅汉 + 隐藏接受度修正”的旧方案。
- 首都和市场首都固定为 `STATE_LOWER_EGYPT`。第一轮实测确认开普首都导致利益扩散过慢；开普保留为备选方案。
- 首都 hub 使用大明专属名称：城市“应天府”，港口“靖海港”。
- 开局法律采用大清法律底盘，但改为 `law_slave_trade`、`law_no_migration_controls`、`law_colonial_resettlement`、`law_mercantilism`、`law_professional_navy`，并确保 `colonization`、`international_trade`、`military_drill` 科技。
- 开局不改非洲本地 pop culture，不删除非洲 homeland；只添加一层稀薄的中华行政与礼仪人口：有政府行政机构的州为 100 名汉文化官僚和 500 名当地中华官僚，无政府行政机构的州为 100 名汉文化教士和 500 名当地中华教士。下埃及作为南都例外，添加 1000 名汉、3000 名西域中华和 1000 名非洲中华官僚。全非洲约六万人并非都被解释为最初流亡者的纯血后代：汉文化代表仍登记为内地籍、维持朝廷语言和宗族身份的核心家族，非洲中华与西域中华则包括两百年间经通婚、收徒、地方招募和身份吸纳形成的本地共同体。
- 添加 20 年衰减的“天朝在非洲”修正，但移除其中行政力惩罚，改为建设效率、权威、机构成本/税收能力等统治摩擦惩罚。
- 添加 20 年衰减的强力行政正面修正“南都行台”，开局提供 `+1000%` 行政力，保证统一非洲后可玩。
- 新增下埃及可建造的大明版紫禁城奇观“应天府紫禁城”，图标、生产方式和效果复用北京紫禁城；统一后迁都南京时另有“南京紫禁城”可由玩家自行建造。
- 新增两条大明专用公民权变体法律：开局采用“天朝万民”（`law_subjecthood` 变体，等级化帝国臣民秩序，额外加同化）；后续可改革为“华夷一统”（`law_multicultural` 变体，文化多元式接受度，额外加同化，并允许使用“弘扬国家价值”法令）。
- 不添加“海外大明”日志，不添加二期事件包。
- 国号/旗帜先实现动态国名和可用旗帜；默认、君主制、普通共和、军政府/独裁、法团/法西斯、神权、委员会共和和属国 canton 均已使用大明专属朱红金黄体系旗帜。
- 非洲州、建筑、军队归属优先保证 1836 开局无错误；数值平衡留到第一轮实测后调整。
- 埃及是非洲开局国家，但原版还持有黎凡特领土；初版将埃及在非洲外的残余领土和建筑归属转给奥斯曼，避免 `EGY` 作为开局国家残留。
- 移民政策战争目标允许叠加到其他外交博弈/战争目标上；它类似移民制度版“要求政权更迭”，战败方采用战争目标持有方对应的移民政策。
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

- `descriptor.mod`：使用 `replace_path = "common/history/states"`。不替换整个 military formations 目录，以免破坏其他国家跨地区编制。
- `common/history/states`：使用 `replace_path = "common/history/states"`，复制原版唯一的 `00_states.txt`，再改非洲州归属、整合和 homeland 保留状态。这是兼容性较差但最稳的做法，避免同一 state region 重复定义。
- `common/history/buildings`：先只复制并改 `03_north_africa.txt`、`04_subsaharan_africa.txt`，把非洲建筑所有权改为 `c:MGN`。不要一开始 replace 整个 buildings 目录，否则要同步复制所有地区建筑文件。
- `common/history/buildings/08_middle_east.txt`：只把原本属于 `EGY` 的黎凡特建筑归属改为 `TUR`，配合州归属转移，避免埃及残留。
- `common/history/military_formations`：保留大明专用 `03` 与空白 `07`，不完整替换世界军队目录。非洲原版兵营随建筑所有权归并而保留，形成392营非正规步兵；当前接受引擎将其汇总为默认“大明第1陆军”，由玩家按需手动拆分，不删除这些州级军事建筑。
- `common/history/buildings` 仍不替换整个目录；若以后确认建筑历史发生重复，再单独评估，避免无必要扩大兼容面。

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
trigger = { has_law = law_type:law_single_party_state }                 # dyn_c_ming_single_party；革命委员会变体保留委员会共和国号
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
7. 显式拥有 `line_infantry` 科技，使现有线列步兵可以正常扩编，也让玩家能够按军费与军工承受能力逐步整训地方军；不额外赠送 `mandatory_service`、`napoleonic_warfare`，也不自动把全部非正规步兵升级。
8. 首都和市场首都改为 `STATE_LOWER_EGYPT`。

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
        add_technology_researched = line_infantry

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
- `line_infantry` 与开局部队保持一致：大明已有 22 营线列步兵，同时保留 44 营非正规步兵。科技代表应天府、尼罗河与开普等中央精锐已经掌握线列操典，不代表全非洲驻军已经完成近代化；混编结构把后续换装成本和小武器供应留给玩家处理。
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

### 8.4 移民政策战争目标

新增一个中华国家间可用的移民制度版“要求政权更迭”战争目标。它不改目标国家政府形态、不吞地、不变成臣属，只强迫目标国家采用战争目标持有国当前的移民政策，即在 `law_no_migration_controls`、`law_migration_controls`、`law_closed_borders` 之间对齐。

推荐命名：

- 外交博弈：`dp_mgn_open_chinese_migration` / `dp_mgn_regulate_chinese_migration` / `dp_mgn_close_chinese_migration`
- 战争目标：`mgn_open_chinese_migration` / `mgn_regulate_chinese_migration` / `mgn_close_chinese_migration`
- 本地化：`要求弛禁迁徙`、`要求厘定迁徙章程`、`要求闭关封境`

适用范围：

- 发起者必须是中华国家。
- 目标必须是其他中华国家：大清、大明、太平天国、中国分裂国家，或前文 `mgn_is_chinese_country` 触发器识别到的国家。
- 目标当前移民政策必须不同于发起者。
- 大明/大清事件组另有事件专用博弈 `dp_mgn_two_chinas_open_migration` / `dp_mgn_two_chinas_regulated_migration` / `dp_mgn_two_chinas_closed_migration`，用于玩家拒绝要求后给双方添加符合各自移民政策的战争目标，且初始战争目标不产生恶名。

外交博弈建议：

```txt
dp_mgn_open_chinese_migration = {
    war_goal = mgn_open_chinese_migration
    texture = "gfx/interface/icons/war_goals/regime_change.dds"

    possible = {
        mgn_is_chinese_country = yes
        aggressive_diplomatic_plays_permitted = yes
        scope:target_country = {
            mgn_is_chinese_country = yes
            NOT = { this = root }
            NOT = { is_country_type = decentralized }
            NOT = { mgn_has_same_migration_law_as = { COUNTRY = ROOT } }
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
        can_add_for_other_country
        requires_interest
    }

    execution_priority = 20

    # 类似要求政权更迭，要求控制目标首都。
    contestion_type = control_target_country_capital
    target_type = country

    possible = {
        mgn_is_chinese_country = yes
        has_law_or_variant = law_type:law_no_migration_controls # 另两类战争目标分别检查 law_migration_controls / law_closed_borders
        scope:target_country = {
            mgn_is_chinese_country = yes
            NOT = { this = root }
            NOT = { mgn_has_same_migration_law_as = { COUNTRY = ROOT } }
        }
    }

    valid = {
        scope:target_country ?= {
            NOT = { is_country_type = decentralized }
            NOT = { mgn_has_same_migration_law_as = { COUNTRY = ROOT } }
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
            activate_law = law_type:law_no_migration_controls # 另两类战争目标分别激活 law_migration_controls / law_closed_borders
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
- `maneuvers = { value = 3 }`、`infamy = { value = 1 }`：公开外交博弈仍保持低烈度；大清/大明事件拒绝后的事件专用博弈则不收初始战争目标恶名。
- 该战争目标不使用 `validate_conflicts_war_goals_all`，允许叠加到“统一中国”“中华臣服”等更大目标上，作为低烈度附加要求。
- `contestion_type = control_target_country_capital`：与“要求政权更迭”相同，真正开战后需要压服目标首都。

如果测试发现公开外交博弈的固定 `infamy = 1` 太低，可改成 `0.5-2` 的固定值；不建议使用人口缩放，否则对大清会因为人口巨大而变得不像“移民政策对齐”要求。

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
- 军制：开局显式解锁 `line_infantry`，但维持 22 营线列步兵、44 营非正规步兵的中央精锐与地方军镇混编；不自动全面换装，也不连带解锁 `mandatory_service` 或 `napoleonic_warfare`。
- 人物：按第 9 节做半虚构海外明廷班底；首版不直接移植大清人物，非洲本地人物可留作后续人物包。

## 11. 测试清单

进游戏 1836 开局检查：

- 国家选择界面显示“大明”，旗帜与大清近似/一致。
- 大明拥有所有 `geographic_region_africa` 陆地州。
- 大明首都和市场首都都是 `STATE_LOWER_EGYPT`。
- 下埃及首都城市 hub 显示为“应天府”，港口 hub 显示为“靖海港”。
- 下埃及首都可建造“应天府紫禁城”，其效果应等同北京紫禁城；开局不直接建成。若后续迁都南京，南京可建造“南京紫禁城”，但不自动落成。
- 非洲没有原有开局国家，包括集中化和非集中化国家。
- 大明所有非洲州都是 incorporated。
- 初版路线：大明主流文化为汉、非洲中华、西域中华；“主流文化只有汉”的旧方案只作为备选记录，不纳入初版验收。
- 法律大体与大清一致，但奴隶制为 `law_slave_trade`，移民法为 `law_no_migration_controls`，殖民法为 `law_colonial_resettlement`，贸易政策为 `law_mercantilism`，海军模式为 `law_professional_navy`。
- 大明已研究 `line_infantry`，现有 22 营线列步兵可正常扩编，其他 44 营步兵仍为非正规步兵且不会在开局自动升级。
- 非洲原版兵营随建筑所有权归并而保留，形成392营非正规步兵；另有手写的四支驻军、合计74营，实机总计466营。当前保留默认“大明第1陆军”，玩家可开局手动拆分。
- 大明开局有 20 年衰减的“南都行台”强力行政力加成，初始行政力加成 `+1000%`。
- “天朝在非洲”不再削行政力，而是提供建设效率、权威、机构成本、税收能力等统治摩擦。
- 大明没有 `je_warlord_china` / “脆弱的统一”。
- 大明开局利益集团显示为士绅官僚、儒学士、神机营、海外文人等自定义名称；皇帝和主要 IG 领袖不是大清原版人物。
- 大清能对大明使用“统一中国”；大明能对大清和中国分裂国家使用“统一中国”。
- 大清、大明和中华分裂国家之间能发起专用“中华臣服”外交博弈；结算时能按目标国家地位变成朝贡、附庸、傀儡或自治领。
- 中华国家能使用移民政策外交博弈；该战争目标可叠加到其他战争目标上，目标退让或战败后采用战争目标持有国对应的移民政策。
- “中华臣服”恶名不应过低；初版建议固定为 `8`。
- 开局公民权法律为大明专用“天朝万民”；后续可改革到大明专用“华夷一统”。两者均不与奴隶制互斥，前者偏臣民制度并加同化，后者偏文化多元并加同化、允许弘扬国家价值法令。
- 非洲主流人口的文化接纳状态至少达到“二等公民”；若宗教导致总接纳偏低，调高隐藏修正。
- 开局只添加象征性的中华行政与礼仪人口，不把它们设计成足以改变非洲人口结构的移民社群。

## 待定事项

### 392营开局军团排查记录（2026-07-26）

- 实机确认：军事面板中的392不是征召容量，而是拥有约392K人力的常备非正规步兵；加上四支手写驻军74营，国家总兵力为466营。
- 根因：非洲建筑历史统一改为大明所有权时，原版 `building_barrack` 也被保留；引擎将这些未显式编组的营自动汇总进默认军团。
- 已否决“强制职业军队即可消除392营”的判断。实机在职业军队已经生效时仍显示同一支392营军团，说明军队法律不是成因。
- 已否决完整替换 `common/history/military_formations` 目录。该做法需要复制并维护全世界原版编制，兼容成本高，而且不能解决由州兵营自动生成的部队。
- 已否决从生成器删除全部非洲兵营。虽然能消除默认军团，但会同时删除392营及其州级军事基础，与保留既有非洲军力、避免大改土地数据的方向冲突。
- 已检查当前可见的历史/脚本用法，只确认了创建军团和创建战斗单位，没有找到可靠的“把引擎已生成单位转移到另一军团”效果。若未来要求自动拆分，应先做小型实机原型，证明能按原州兵营一一重建且总数仍为392，再考虑纳入正式生成器。
- 最终决定：保留392营及默认军团，允许玩家手动拆分；保留 `line_infantry` 科技，不强制职业军队，不连带赠送其他军事科技。

- 中华人口采用按行政覆盖区分职业的统一规则，不另按开普、桑给巴尔或商埠逐一配置移民人口。
- 如果后续要加汉文化人口，建议只作为点状移民社群存在，不把非洲本地人口整体改汉。这样既能保留“主流文化汉”的设定，也不会清空非洲本地文化，后续仍有民族主义、分离主义和“非酋体验”。

## 第一轮实测后的确定调整

本节记录第一轮进游戏测试后的调整，视为当前实现初版的一部分。

### A. 首都、命名和奇观

- 首都和市场首都从 `STATE_CAPE_COLONY` 改为 `STATE_LOWER_EGYPT`，理由是开普首都利益扩散过慢，影响大明与大清/中华国家互动。
- 大明拥有下埃及时，下埃及城市 hub 使用专属名“应天府”，港口 hub 使用“靖海港”。实现上优先在 `history/countries/mgn - ming.txt` 中用 `set_hub_name` 设置；若测试发现历史效果不稳定，再改为国家/文化条件动态地名。
- 新增 `building_mgn_forbidden_city`，本地化名“应天府紫禁城”。它限定在大明首都为下埃及/应天府时可建造，图标、生产方式组和效果复用原版 `building_forbidden_city`，但不要复用原版建筑键，避免与北京紫禁城的 `unique = yes` 互斥或覆盖原版。
- 新增 `building_mgn_nanjing_forbidden_city`，本地化名“南京紫禁城”。它限定在大明首都为南京时可建造，不随迁都自动落成，必须由玩家自行建设。
- 初版不再开局直接放置“应天府紫禁城”，只作为首都可建造奇观。这样既保留目标感，也避免开局额外白送权威/正统性/威望。

### B. 开局法律

在大清法律底盘上追加/替换以下法律：

- 贸易政策：`law_mercantilism`。
- 海军模式：`law_professional_navy`。
- 仍保留：`law_slave_trade`、`law_no_migration_controls`、`law_colonial_resettlement`。
- 确保对应科技：`international_trade`、`military_drill`、`colonization`。

### C. 行政力与开局修正

统一非洲后行政力缺口会直接阻断玩法，因此初版需要强力但会衰减的补偿：

- 新增正面修正 `mgn_southern_court_administration`，本地化“南都行台”。
- 效果：`country_bureaucracy_mult = 10`，即 `+1000%` 行政力。
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

- 移民政策战争目标应允许叠加到其他战争目标上。实现上去掉 `validate_conflicts_war_goals_all`，保留基本合法性检查，避免它只能单独开博弈导致目标不愿退让。
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
    country_legitimacy_base_add = -10
    state_radicals_from_political_movements_mult = 0.05
}
```

说明：

- `country_bureaucracy_mult = -0.10`：最重要。统一非洲后行政压力应该明显存在，但 -10% 仍可通过政府行政机构补救。
- `country_authority_mult = -0.05`：表现海外朝廷对地方的控制成本，不要再高，否则和大清式专制开局叠加后会太难受。
- `country_legitimacy_base_add = -10`：开局显著削弱皇统正当性，表达“海外另立天命”的争议；该惩罚在 20 年内线性衰减，长期平均约为 `-5`。
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

#### 12.4.1 二期日志子 plan：中明路线与重建国家

新增独立设计文档 `docs/route-journal-design.md`，记录“大明/大清路线导航 + 统一后国家治理”日志链。当前主界面拆成默认置顶的“两个中华”“重建国家”“经略四方”三个职责面板：

- 路线导航包含独立自主、大明反攻大陆、大清武力统一、兄弟皇谊、和平统一五条方向；反攻大陆/武力统一是主动开战路线，不是夺取首都后的“宣告”按钮。
- 大明版“重建国家”只包含北京、南京、下埃及/应天府三都迁都与东北、西北版籍整理；大清版只包含两项边疆版籍整理。
- 共用“经略四方”集中承载八类特许公司按钮，并保持常驻，以便公司灭亡后重新设立。
- 反攻大陆/武力统一路线要求发起方国际地位更高、双方无战争且无停战协议；点击后发起专用两中华统一战争，双方初始都有吞并对方的统一战争目标且不加恶名；当对方国家不存在后，再触发对应版本“海内一统/重建国家”。
- 兄弟皇谊路线要求双方均为君主制、神权制或社会君主制之一，不要求相同政体；由国际地位更高一方点击日志按钮向对方提议附庸化，AI 默认接受，玩家可拒绝并触发附庸战争。
- 战争/提议类按钮要求双方均不在战争中且不在外交博弈中；若双方已经直接存在臣属关系，禁用兄弟皇谊提议。
- 移民政策要求发起方国际地位更高、双方无战争且无外交博弈、无停战协议、移民政策不同；按发起方法律显示为“要求弛禁迁徙”“要求厘定迁徙章程”或“要求闭关封境”。AI 目标国默认接受并采用发起方移民政策，玩家拒绝时触发双方互相要求采用各自移民政策的战争。
- 和平统一路线要求双方政体同属总统共和、议会共和、委员会共和或法团国家，关系达到友善，且双方没有停战协议；由国际地位更高一方点击日志按钮发起，AI 目标国默认同意，玩家目标国可拒绝并触发双方均有统一战争目标的战争。
- 玩家引导选项优先做成日志按钮/决议按钮，不做被动触发；纯新闻型事件或小 buff 可以例外。
- 已调查原版“脆弱的统一”：`je_warlord_china` 失败后触发 `warlord_china_events.100`，设置 `china_shatters`，并把 `global_var:chinese_central_government` 改到 `c:BEI`；北洋动态国名也依赖 `china_shatters` 与中央政府变量。因此 `mgn_qing_counterpart_exists` 要求 `c:CHI` 存在、未 `china_shatters`、非军阀，并优先检查中央政府变量仍指向 `c:CHI`；不要要求君主制或满文化主流，否则会阻断共和/法团/移除满文化后的路线日志。
- 非洲特许公司成立时首都优先选择宗主国拥有的下埃及/应天府；若不可用，再从宗主国实际拥有的非洲州中选择首都，不硬写下埃及作用域；`MCC` 使用 `country_type = company` 以匹配 `subject_type_chartered_company`，并覆盖原版该 subject type 以允许未认可大明/大清作为宗主；成立后拥有宗主国持有的全非洲州且全部已整合；初始固定采用殖民政府、 “天朝万民”和 `law_extraction_economy`（盘剥经济制度），除特许公司专属覆盖法律外，其他法律继承宗主国当前法律；特许公司国号采用“大明/大清非洲榷务公司”，非特许附庸改称“非洲都护府”，独立后按政体切换国号；旗帜区分特许公司章旗与独立/普通附庸旗；统一胜利方进入“重建国家”时获得 10 年 `mgn_chinese_unification_integration_drive`，提供 `state_incorporation_speed_mult = 0.25`。
- 当前实装修订：`MCC` 已补殖民政府/主要政体旗帜覆盖，并把专属优先级提高到原版 `DEFAULT` 通用特许公司旗帜之上；基础象旗改为高对比黑金大象；“兄弟皇谊”接受事件调用统一臣属 effect，战争目标改用原生 `kind = make_tributary` 结算，并放宽普通附庸外交的目标等级验证；移民政策战争目标改为移民制度版“要求政权更迭”，按发起方法律拆成弛禁迁徙、厘定迁徙章程、闭关封境三类；“海内一统”从日志按钮移除，改为日志创建/每周自动检查触发；统一后界面拆为外交“两个中华”、中央整顿“重建国家”、公司治理“经略四方”，三个日志均默认置顶；西伯利亚公司范围明确排除图瓦，扶桑排除琉球，南洋排除婆罗洲；路线事件已统一补充有效原版 `event_icons` 与 `event_image` 背景，国家修正已补充有效 `timed_modifier_icons`，避免默认占位圆脸；并通过同名覆盖 `00_formable_countries.txt` 防止中华属特许公司成立中国。
- 日志拆分废案：未采用“开疆扩土”，因为公司按钮重组的是既有控制区，并不直接开战或授予宣称；未保留旧版把外交、迁都、边界和八家公司全部塞入“重建国家”的布局；也未采用“经略四方”不默认置顶的减负方案，最终按界面一致性让三个主日志全部默认置顶。
- 特许公司文化采用“汉文化第一顺位 + 本地化中华桥梁文化”路线：所有公司以汉为第一主流文化；非洲公司另有非洲中华、西域中华，东藩另有海东中华，兰芳另有南洋中华，西伯利亚另有朔方中华，中亚另有天山中华，扶桑另有扶桑中华，南洋经略另有交南中华。扶桑中华采用日语与东亚 heritage group，交南中华采用越语与东南亚 heritage group。各文化 homeland 与相应公司脚本定义的法定地理范围同步，由生成器读取 `mgn_state_is_*_company_region` 触发器生成；它表达长期文化根基，不随即时国境、公司灭亡或重建而撤销。原版 1.13 新拆出的东海、北信越、京都已加入扶桑范围；琉球继续排除于扶桑之外，并在内地经略公司设立时默认划入该公司。
- 文化废案记录：未直接把朝鲜、达雅克、俄罗斯、布里亚特、哈萨克、乌兹别克等现有文化设为公司主流，以免把当地民族国家身份等同于公司统治共同体；未保留东藩固定满文化及西伯利亚/中亚的泛用满文化，因为宗主官僚来源不等于当地核心文化；未采用兰芳“汉、客家、粤”并列和中亚“汉、西域中华、满”并列，以免主流文化表只是移民来源清单；也未采用按公司实际持有州动态增删 homeland 的方案，因为 homeland 是持久文化地理，随战争反复消失既不自然，也会造成存档状态和重建结果不稳定。
- 开局中华人口废案记录：未采用所有州都生成官僚的方案，因为没有政府行政机构的州缺少相应行政岗位，也会夸大朝廷的实际覆盖；未采用把无行政机构州的 600 人设为普通人口或农民的方案，最终以教士概括寺观、祠堂、私塾、经师和谱牒保管者形成的礼仪网络；普通州曾先后拟放 1 名和 10 名汉文化人口、100 名当地中华人口，但这些极小人口过于容易在开局消失，也不足以表现延续两百年的稳定共同体，最终定为 100 名汉文化人口和 500 名当地中华人口；未采用“约六万人全是最初一千名流亡者自然繁衍的纯血后代”这一解释，因为人口增长幅度和地方文化分化更适合由通婚、收徒、地方招募及身份吸纳共同说明；也未采用只在下埃及、开普、桑给巴尔等少数中心配置移民社群的方案。
- 扶桑/南洋废案记录：扶桑未直接采用日本文化，早期“不附加汉文化”的方案已被统一的“汉为第一主流文化”规则取代；琉球未划入日本范围。南洋未罗列越、泰、缅、柬、老、马来主流文化，也未复用兰芳的南洋中华。国家名未采用容易被误解为仅限越南的“交南公司”，文化语言未采用把本地共同体写成海外汉人的官话；详细理由与州范围记于 `docs/route-journal-design.md`。
- 统一胜利方新增经济制度变体 `law_mgn_overseas_cooperative_ownership`，中文名定为“人民资本合作制”：前序与原版 `law_cooperative_ownership` 保持一致（无科技前提；要求委员会共和国或法团国家；排斥农奴制与妇女下田），但额外要求大明/大清胜利者本体才能制定。大明与仍为有效中华竞争者的大清从开局即可在法律界面看到该制度，以便预览和规划；胜负未定时仅灰显。国内效果等同合作社所有制，移除原版 `country_foreign_collectivization_bool`，使海外投资不被合作社化。公司不自动继承该变体，宗主采用该变体时公司继承普通 `law_cooperative_ownership`。为让 UI 与实际规则完整等同普通合作社所有制，额外覆盖原版反向引用：无政府制、集体化农业、城市中心艺术赞助和公司总部所有权生产方式均加入该变体法律。无政府制和集体化农业采用完整同名原版法律文件覆盖，分别只改目标 `unlocking_laws`；早期另建重复法律对象并添加 `can_enact` 的方案因实机仍读取原版定义而废弃。备选名记录：“特色合作社所有制”“人民资本合作制”“社会主义市场合作制”“有特色的合作社所有制”“一国两制所有制”“内公外私”“内公外商”“海内合作制”“外洋通商合作制”；最终选择“人民资本合作制”，因为它兼具末期现代政治经济学感、梗味和机制暗示。

#### 革命委员会制彩蛋

当前方案：

- `law_mgn_revolutionary_committees`（革命委员会制）是委员会共和国专用的权力分配变体，只向大明、大清或当前合法中华中央政府开放；军阀、附属国、特许公司和仅因汉文化主流而命中的其他国家均排除。不要求先赢得两中华斗争，避免把政体彩蛋拖到游戏末期。
- 数值完整保留原版一党制的 `+250` 权威、选票合法性、意识形态一致性、投票基数、执政集团吸引力和唯一合法党行为；另加政府规模合法性 `+2`，工会与军队政治力量各 `+15%`，表现干部、群众和军队代表的“三结合”。
- 革命委员会虽继承一党制机制，但不命中“中华训政共和国”动态国名；委员会共和继续使用“中华苏维埃社会主义共和国联盟”。
- 法律介绍写明两项特殊解锁：可以制定工厂委员会，并可对本国人物使用“批斗”。工厂委员会的实际条件是“国家处于革命中，或者已经实行革命委员会制”。革命委员会还应像其一党制母法一样解锁计划经济。由于数据库级 `unlocking_laws` 不自动承认自定义母法变体，当前 1.13 的 `common/laws/00_labour_associations.txt` 与 `common/laws/00_economic_system.txt` 均采用完整同名覆盖，分别只改工厂委员会目标块与计划经济解锁列表；支持版本变化时必须重新对照。
- “批斗”仅在革命委员会制生效后显示，不花权威，采用全国共用 18 个月冷却，AI 不使用，并允许针对国家领袖。普通人物结果为 50% 打倒退隐、25% 隔离流亡、25% 在批斗中死亡；国家领袖为 50% 打倒退隐、20% 死亡、30% “炮打最高负责人”后退隐。每次都会弹出结果事件，目标必然退出政治舞台。

废案与取舍：

- 不采用持续派性进度、专属日志和周期性全国灾害，以免彩蛋盖过大明与大清的主线。
- 不削减常驻权威或合法性，不收取单次批斗的权威力成本，也不沿用秘密警察的五年冷却；这些方案会削弱专属法律或不符合公开群众行动的表现。
- 不把批斗写成百分之百处决，不向所有汉文化主流国家开放，不自动制定工厂委员会，也不新增专属动态国号。
- 早期备选名“三结合委员会制”“天下公议制”保留为废案；最终采用历史指向最明确、玩家最容易理解的“革命委员会制”。
- 人民资本合作制数值采用“有味道版”：在合作社所有制国内集体化、店主/农民投资效率、公司劳工分红基础上，加入较克制的自由放任元素：免费公司特许 `country_free_charters_add = 2`、资本家投资池效率 `state_capitalists_investment_pool_efficiency_mult = 0.25`、贷款利率 `country_loan_interest_rate_mult = -0.10`。这样表达“国内合作化 + 人民资本市场 + 外洋特许公司”，但不照搬自由放任的 `-0.25` 贷款利率，也不加入 `country_force_privatization_bool` / `country_forbid_monopoly_bool`，避免成为同时吃满合作社社会化红利和自由放任私人扩张红利的终局神法。废案记录：最低风险版仅把免费特许从 1 提到 2；完整自由放任缝合版（+2 特许、资本家 +25%、贷款 -25%、强制私有化、禁止垄断）因过强且与合作制语义冲突而放弃。
- 具体实施 plan 已在 `docs/route-journal-design.md` 细化为触发器、脚本效果、日志条目、按钮、事件、特许公司国家、本地化和测试矩阵七步。
- 该日志链暂列二期内容，不纳入首版实现范围。

### 12.5 二期事件与人物包

如果后续想增加代入感，可以做一个小事件包，但不建议首版塞进去。

推荐方向：

- “归化地方领袖”：从非洲本地精英中生成 `african_han` 或 `western_han` 政治人物，进入军队、文人或商帮势力。
- “废奴风波”：废除奴隶贸易时，让士绅官僚/商帮不满，文人和工会支持。
- “南都营造”：首都州建设政府行政机构、大学、港口后，给短期正统性或官僚奖励。
- “苏伊士门户”：控制并建设下埃及时，给贸易/海军风味事件。

这些内容等基础国家、文化、战争目标跑通后再加，会比首版同时堆上去稳定得多。
