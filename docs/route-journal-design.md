# “两个中华”日志链可执行计划

本文记录“大明在非洲”二期日志链的调查结论与实施计划。目标是用日志按钮引导玩家在多条路线中自主选择，而不是用被动触发器自动改变国家结构。

## 设计定稿

日志链按职责拆分：

1. 外交导航日志：`je_mgn_two_chinas`，本地化名“两个中华”。它显示大明与大清的关系局势、路线条件、移民要求、和平统一与武力路线。
2. 中央重建日志：`je_mgn_rebuild_state_ming` / `je_mgn_rebuild_state_qing`，本地化名均为“重建国家”，只承载迁都与东北、西北版籍整理。
3. 域外治理日志：`je_mgn_administer_four_quarters`，本地化名“经略四方”，由大明、大清胜利方共用，集中承载八类特许公司。
4. 臣服方日志：`je_mgn_bitter_peace`，本地化名“苦涩的和平”，给臣服一方保留要求独立入口。

“两个中华”“重建国家”“经略四方”均默认置顶；三者分别承担外交、中央重建、公司治理，避免单一日志同时堆叠十余个按钮。

路线按钮优先级：

- 玩家引导选项优先做成 `scripted_button`。
- 不做“条件满足即自动弹出吞并/统一/迁都事件”。
- 纯新闻型事件、短期 buff、无外交/领土/国家结构变更的提示，可以被动触发。
- AI 也通过按钮 `ai_chance` 使用内容，不绕过按钮写隐藏被动效果。

## 当前修订记录

针对最新实测问题，当前实现作以下调整：

- “海内一统”不再作为 `je_mgn_two_chinas` 的玩家按钮出现。日志在创建时与每周脉冲中自动检查 `mgn_ming_can_claim_reconquest_complete` / `mgn_qing_can_claim_conquest_complete`；对方国家不存在后自动进入对应“重建国家”日志并弹出新闻事件。
- “提议兄弟皇谊”的接受事件改为调用统一的 `mgn_make_brotherly_subject`，按宗主国/目标国地位创建朝贡或保护国关系，避免大明/大清两边事件分支维护出错。
- “兄弟皇谊”战争目标 `mgn_brotherly_vassalization` 改为原生 `kind = make_tributary`，并保留 0 恶名与专用本地化；专用 war goal 不套用原版普通附庸外交的目标等级验证，避免大明/大清这种大国因等级过高不能被路线战争压服。这样战败、让步、议和结算走游戏内置臣属结算，而不是 custom war goal 事后手写 pact。
- 移民政策战争目标改为移民制度版“要求政权更迭”：使用政权更迭图标、要求控制目标首都，并按发起方现行法律拆成“要求弛禁迁徙”“要求厘定迁徙章程”“要求闭关封境”。按钮只保留在“两个中华”；AI 目标方默认接受，玩家拒绝则触发双方互相要求采用各自移民政策的事件博弈。接受后双方获得 60 个月停战协议。
- 吞并或臣服都会使领导方进入对应“重建国家”日志；若一方脱离臣服或重新独立存在，则通过日志完成回调或专用独立战争目标为双方重启“两个中华”日志。再次统一/臣服后可重新进入重建国家或苦涩和平日志。
- 移民政策与和平统一按钮不再重复挂入“重建国家”；相关外交操作统一留在“两个中华”。若对方已经是臣属，和平统一仍额外要求臣属方累计臣服满五年。
- 臣服方获得“苦涩的和平”日志，可在双方无战争、无外交博弈、无停战协议时要求独立。AI 臣服方不会主动点击；AI 宗主方接受概率沿用普通外交博弈式独立要求。
- 八类特许公司从“重建国家”拆入共用的“经略四方”日志：内地经略公司、东藩榷务公司、扶桑榷务公司、西伯利亚榷务公司、中亚榷务公司、南洋经略公司、兰芳榷务公司、非洲榷务公司。日志不设置完成条件，成立公司也不写“已完成”变量；公司被吞并或不再存活后，可以重新设立。
- 废案记录：未采用“开疆扩土”作为日志名，因为现有按钮只重组已经控制的领土，不提供宣称、殖民或征服机制；未继续把公司、迁徙与和平统一按钮塞在“重建国家”，因为职责混杂且按钮过多；未让“经略四方”默认取消置顶，按用户选择三个主日志均默认置顶。
- 玩家文本复审后，日志、战争目标、按钮、条件提示与事件统一使用“朝廷、名分、章程、关津、版籍”等世界观词汇；纯机制信息仍保留在 tooltip，但避免“目标国家”“正在处理”“十个州”等容易让玩家跳出叙事的表述。公司叙事统一写明汉家官商与地方桥梁文化共同经营，和实际主流文化顺序一致。
- 设立特许公司的领土条件改为：本国、非公司附庸或附庸的附庸控制目标区域任意州即可。按钮 tooltip 只显示短自定义条件，具体州列表和附庸链检查放入隐藏触发器；按钮执行效果用 `hidden_effect` 隐藏批量 `set_state_owner` / `set_state_type` 列表，只显示一条短结果说明。划地效果遍历本国与 `every_subject_or_below`，从非公司附庸链中划出目标州；若某个被划地附庸因此灭国，其直接臣属会先转给宗主，避免附庸的附庸独立。
- `MCC` 旗帜补上殖民政府与主要政体的高优先级定义，并将专属优先级提升到原版 `DEFAULT` 通用特许公司旗帜之上，避免回落到绿色默认/随机图案；特许公司章旗优先级最高。
- 非洲政府基础旗帜的大象改为黑金配色，并新增 `MCC_colonial` 黑边朱底版本，提高小尺寸图标下的对比度。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 均有非臣服状态动态国号和 `*_free` 旗帜。特许公司臣属仍使用 `*_chartered` 章旗；脱离臣服后改用自由态国号与独立旗帜。
- 中华属特许公司不能成立中国：mod 以同名覆盖 `common/country_formation/00_formable_countries.txt` 的方式修改 `CHI` 成国定义，使用 `mgn_is_chinese_chartered_company` 触发器拦截 `MCC/MDC/MKC/MLF/MSB/MCA/MJP/MSE` 及带公司法律/中华主流文化的 company 国家，避免公司在扩张后自动成立中国。

## 原版调查结论

调查基于本机 Victoria 3 原版目录；具体路径由仓库根目录 `.env.local` 中的 `VICTORIA3_GAME_ROOT` 提供。

### 大清/北洋判定

相关原版文件：

- `common/journal_entries/00_warlord_china.txt`
- `events/warlord_china_events.txt`
- `common/dynamic_country_names/00_dynamic_country_names.txt`
- `common/on_actions/00_code_on_actions.txt`
- `common/journal_entries/00_reunify_china.txt`
- `common/diplomatic_plays/00_diplomatic_plays.txt`

结论：

- `je_warlord_china` 失败时触发 `warlord_china_events.100`。
- 该事件设置 `set_global_variable = china_shatters`。
- 该事件把被选中的军阀 `change_tag = BEI`，并设置 `global_var:chinese_central_government = c:BEI`。
- 原版北洋动态国名 `dyn_c_beiyang_government` 的核心条件是 `has_global_variable = china_shatters` 且 `global_var:chinese_central_government ?= THIS`，首都在北京/直隶。
- 原版大清动态国名 `dyn_c_great_qing` 要求 `coa_def_monarchy_flag_trigger = yes` 且主流文化含 `cu:manchu`。
- 原版统一中国外交博弈把 `c:CHI`、`global_var:chinese_central_government`、`je_reunify_china` 都视作中国统一参与者。

因此，本日志链不能用 `exists = c:CHI` 作为“大清仍存在”的唯一条件。应使用一个专用触发器判断“大清对应方”：

```txt
mgn_qing_counterpart_exists = {
	exists = c:CHI
	NOT = { has_global_variable = china_shatters }
	c:CHI ?= {
		is_country_alive = yes
		NOT = { has_variable = warlord_state }
	}
	trigger_if = {
		limit = { exists = global_var:chinese_central_government }
		global_var:chinese_central_government ?= c:CHI
	}
}
```

说明：

- `NOT has_global_variable = china_shatters` 是最强排除条件，能把北洋/军阀时代排除。
- `global_var:chinese_central_government ?= c:CHI` 是兼容原版中国统一系统的正统中央政府判定。
- `非军阀 + 中央政府变量仍指向 CHI` 是“大清/亚洲中国仍为有效对手，而非北洋/军阀”的保险。
- 不要求 `cu:manchu` 为主流文化，否则大清共和化、社会君主制化或移除满文化主流后，“两个中华”、兄弟皇谊与和平统一会错误失效。
- 不要求 `country_has_monarchy_law = yes`，否则共和/法团和平统一会与“双方同体制”条件互相冲突。
- 如果测试发现开局或部分旧档没有 `chinese_central_government` 变量，`trigger_if` 会避免误判。

### 日志按钮语法

原版日志条目通过以下方式挂按钮：

```txt
je_x = {
	scripted_button = button_x
}
```

按钮定义位于 `common/scripted_buttons`，格式为：

```txt
button_x = {
	name = "button_x"
	desc = "button_x_desc"
	visible = { always = yes }
	possible = { ... }
	effect = { ... }
	ai_chance = { base = 0 }
}
```

本链条应新增：

- `common/journal_entries/00_mgn_route_journal_entries.txt`
- `common/scripted_buttons/00_mgn_route_buttons.txt`

### 可用触发器/效果

已确认可用写法：

- 停战：`has_truce_with = c:TAG` 或 `has_truce_with = scope:target`
- 战争：`has_war_with = c:TAG`
- 关系：`relations:root >= relations_threshold:amicable`
- 国际地位：`country_rank = rank_value:...`，以及比较 `country_rank > scope:target.country_rank`
- 吞并：`annex = c:TAG`
- 迁都：`set_capital = STATE_...`
- 市场首都：`set_market_capital = STATE_...`
- 改主流文化：`add_primary_culture = cu:...` / `remove_primary_culture = cu:...`
- 建立特许公司关系：`create_diplomatic_pact = { country = c:TAG type = chartered_company }`
- 转移州：`set_state_owner = scope:...`
- 州整合状态：`set_state_type = incorporated` / `set_state_type = unincorporated`

## 路线结构

### 当前实施修订

以下规则覆盖本节早期草案中的“夺取首都后宣告”设计：

- `mgn_qing_counterpart_exists` 不要求 `cu:manchu` 为主流文化，也不要求君主制；只要求 `c:CHI` 存在且存活、未触发 `china_shatters`、不是军阀状态，并在原版中央政府变量存在时仍指向 `c:CHI`。
- 大明反攻大陆与大清武力统一都拆成两步：优势一方先点击日志按钮发起两中华统一战争；当对方国家已不存在时，“两个中华”日志自动触发“海内一统”，进入对应版本的“重建国家”日志。
- 战争/提议类按钮要求 `c:MGN` 与 `c:CHI` 均 `is_at_war = no` 且 `is_active_in_diplomatic_play = no`；任一方已在战争或外交博弈中时禁用。
- 军事统一使用 `dp_mgn_two_chinas_unification`。该外交博弈不显示在 lens 中，只由日志按钮/事件触发；初始战争目标不加恶名；发起方和目标方都会获得吞并对方的“统一中华”战争目标。
- 大明开战按钮为 `button_mgn_launch_ming_reconquest`，要求大明国际地位高于大清、双方无战争、无停战协议。
- 大清开战按钮为 `button_mgn_launch_qing_conquest`，要求大清国际地位高于大明、双方无战争、无停战协议。
- “海内一统”不再挂为按钮；`mgn_ming_can_claim_reconquest_complete` / `mgn_qing_can_claim_conquest_complete` 满足时由日志 `immediate` 或 `on_weekly_pulse` 自动打开对应版本“重建国家”。
- “兄弟皇谊”不再是事后承认既有臣属关系，而是优势一方向对方发送事件提议附庸化。双方均需为 `law_monarchy`、`law_theocracy`、`law_social_monarchy` 之一，不要求同政体。
- 兄弟皇谊目标方 AI 默认接受并成为朝贡国/附庸国；玩家可拒绝并触发 `dp_mgn_brotherly_subjugation`，双方均获得 `mgn_brotherly_vassalization` 战争目标，胜利后强制目标成为朝贡国/附庸国。
- 移民政策要求由国际地位更高一方或双方臣属关系中的领导方点击对应按钮提出：无移民控制显示 `button_mgn_request_open_migration`，移民管制显示 `button_mgn_request_regulated_migration`，关闭边境显示 `button_mgn_request_closed_migration`。要求双方无战争、无外交博弈、无停战协议且移民政策不同。目标方 AI 默认接受，玩家可拒绝并触发对应事件专用博弈，双方均获得符合各自移民政策的战争目标；接受后创建双方停战协议。

### 1. 独立自主

定位：默认状态路线。

显示条件：

- `MGN` 存在。
- `mgn_qing_counterpart_exists = yes`。
- 双方没有战争。
- 双方不是彼此臣属。

按钮设计：

- 可选按钮：`button_mgn_acknowledge_independent_course`
- 作用：只设 flag 或给小型 5 年修正，不锁路线。
- 推荐首版不做奖励按钮，只在日志描述中显示“当前局势：两国并存”。

### 2. 大明反攻大陆

定位：大明吞并或实质控制大清，获得中国正统。

触发：`mgn_ming_can_claim_reconquest_complete`

可见条件：

- `c:MGN ?= THIS`
- 没有 `mgn_rebuild_state_started`
- 大清对应方不存在。

建议首版完成条件：

```txt
mgn_ming_can_claim_reconquest_complete = {
	c:MGN ?= THIS
	NOT = { has_variable = mgn_rebuild_state_started }
	NOT = { mgn_qing_counterpart_exists = yes }
}
```

自动效果：

```txt
set_variable = mgn_rebuild_state_started
add_modifier = {
	name = mgn_chinese_unification_integration_drive
	years = 10
}
add_journal_entry = { type = je_mgn_rebuild_state_ming }
trigger_event = { id = mgn_route_events.10 popup = yes }
```

说明：

- 反攻大陆的主动开战由 `button_mgn_launch_ming_reconquest` 处理。
- “海内一统/重建国家”入口由 `je_mgn_two_chinas` 自动检测触发，不再作为手动按钮和其他外交按钮并列。

### 3. 大清武力统一

定位：大清作为优势一方主动发起统一战争；非洲大明不存在后进入重建国家。

触发：`mgn_qing_can_claim_conquest_complete`

可见条件：

- `c:CHI ?= THIS`
- 没有 `mgn_rebuild_state_started`
- 大明不存在。

建议首版完成条件：

```txt
mgn_qing_can_claim_conquest_complete = {
	c:CHI ?= THIS
	NOT = { has_variable = mgn_rebuild_state_started }
	NOT = {
		c:MGN ?= {
			is_country_alive = yes
		}
	}
	NOT = { has_global_variable = china_shatters }
}
```

自动效果：

```txt
set_variable = mgn_rebuild_state_started
add_modifier = {
	name = mgn_chinese_unification_integration_drive
	years = 10
}
add_journal_entry = { type = je_mgn_rebuild_state_qing }
trigger_event = { id = mgn_route_events.20 popup = yes }
```

说明：

- 武力统一的主动开战由 `button_mgn_launch_qing_conquest` 处理。
- “海内一统/重建国家”入口由 `je_mgn_two_chinas` 自动检测触发，不再作为手动按钮和其他外交按钮并列。
- 若实际州 key 不匹配，以 `common/history/states/00_states.txt` 和原版 state region 为准微调。

### 4. 兄弟皇谊

定位：大明和大清并存，但一方成为另一方朝贡国/附庸国。

按钮：`button_mgn_recognize_brotherly_hierarchy`

可见条件：

- `MGN` 与大清对应方都存在。
- 一方是另一方臣属。
- 尚未设置 `mgn_brotherly_hierarchy_acknowledged`。

建议触发器：

```txt
mgn_has_brotherly_hierarchy = {
	mgn_qing_counterpart_exists = yes
	exists = c:MGN
	OR = {
		c:MGN ?= { is_subject_of = c:CHI }
		c:CHI ?= { is_subject_of = c:MGN }
	}
}
```

按钮效果：

- 设置 `mgn_brotherly_hierarchy_acknowledged`。
- 给宗主国一个轻量威望/影响力修正。
- 给臣属国一个轻量正统性或关系修正。
- 不添加“重建国家”，因为双方仍并存。

### 5. 和平统一

定位：双方共和/法团政体趋同后，由国际地位更高的一方主动发起合流。

按钮：`button_mgn_launch_peaceful_unification`

必要条件：

- `MGN` 与大清对应方都存在。
- 双方没有战争。
- 双方没有停战协议。
- 双方关系达到友善：`relations >= relations_threshold:amicable`。
- 双方政体同属总统共和、议会共和、委员会共和、法团国家之一。
- 发起方国际地位高于目标方。

建议触发器：

```txt
mgn_has_no_truce_between_two_chinas = {
	OR = {
		AND = {
			c:MGN ?= THIS
			exists = c:CHI
			NOT = { has_truce_with = c:CHI }
			c:CHI ?= { NOT = { has_truce_with = ROOT } }
		}
		AND = {
			c:CHI ?= THIS
			exists = c:MGN
			NOT = { has_truce_with = c:MGN }
			c:MGN ?= { NOT = { has_truce_with = ROOT } }
		}
	}
}

mgn_has_amicable_two_chinas_relations = {
	OR = {
		AND = {
			c:MGN ?= THIS
			c:CHI ?= { relations:root >= relations_threshold:amicable }
		}
		AND = {
			c:CHI ?= THIS
			c:MGN ?= { relations:root >= relations_threshold:amicable }
		}
	}
}
```

政体趋同建议不要写成一个“同为共和”粗判断，而是四个类别：

```txt
mgn_government_category_presidential_republic = {
	has_law_or_variant = law_type:law_presidential_republic
}

mgn_government_category_parliamentary_republic = {
	has_law_or_variant = law_type:law_parliamentary_republic
}

mgn_government_category_council_republic = {
	has_law_or_variant = law_type:law_council_republic
}

mgn_government_category_corporate_state = {
	has_law_or_variant = law_type:law_corporate_state
	NOT = { country_has_monarchy_law = yes }
}
```

双方同类：

```txt
mgn_has_same_unifiable_government_as_target = {
	OR = {
		AND = {
			mgn_government_category_presidential_republic = yes
			scope:target_country = { mgn_government_category_presidential_republic = yes }
		}
		AND = {
			mgn_government_category_parliamentary_republic = yes
			scope:target_country = { mgn_government_category_parliamentary_republic = yes }
		}
		AND = {
			mgn_government_category_council_republic = yes
			scope:target_country = { mgn_government_category_council_republic = yes }
		}
		AND = {
			mgn_government_category_corporate_state = yes
			scope:target_country = { mgn_government_category_corporate_state = yes }
		}
	}
}
```

国际地位：

```txt
mgn_has_higher_rank_than_target = {
	country_rank > scope:target_country.country_rank
}
```

实现提醒：

- 原版脚本中存在 `country_rank > $TARGET$.country_rank` 用法，但测试时要确认比较方向确实代表“地位更高”。若方向反了，改成分档 trigger。
- 友善关系和停战协议都放在按钮 `possible`，不是事件触发器。

按钮效果：

```txt
if = {
	limit = { c:MGN ?= THIS }
	c:CHI ?= { trigger_event = { id = mgn_route_events.100 popup = yes } }
}
else_if = {
	limit = { c:CHI ?= THIS }
	c:MGN ?= { trigger_event = { id = mgn_route_events.101 popup = yes } }
}
```

和平统一事件选项：

- 同意：发起方 `annex = ROOT` 或目标方被发起方吞并，之后发起方添加对应重建日志。
- 拒绝：由发起方创建统一外交博弈。已确认原版按钮中存在 `create_diplomatic_play = { name = ... type = ... target_country = ... }` 写法，可优先使用。

拒绝后开战草案：

```txt
scope:unification_initiator = {
	create_diplomatic_play = {
		name = mgn_peaceful_unification_rejected
		type = dp_mgn_two_chinas_unification
		target_country = ROOT
		add_war_goal = { holder = ROOT target_country = scope:unification_initiator type = annex_country }
	}
}
```

AI 权重：

- 目标方 AI 同意 `ai_chance = { base = 100 }`。
- 玩家目标方保留拒绝选项。
- AI 发起方按钮可给低频权重，例如双方同类政体、友善、无停战且无战争时 `base = 10`，避免 AI 每周乱点。

## 重建国家日志

### 大明版 `je_mgn_rebuild_state_ming`

挂载按钮：

- `button_mgn_move_capital_beijing`
- `button_mgn_move_capital_nanjing`
- `button_mgn_move_capital_yingtian`
- `button_mgn_restore_northeastern_border`
- `button_mgn_restore_northwestern_border`

北京与南京迁都按钮在大明进入重建阶段后始终显示；未完整拥有相应州时由 `possible` 使按钮灰显，而不是从日志隐藏。北京迁都按钮：

```txt
visible = {
	c:MGN ?= THIS
	has_variable = mgn_rebuild_state_started
	NOT = { has_variable = mgn_capital_moved_to_china }
}
possible = { owns_entire_state_region = STATE_BEIJING }
effect = {
	set_capital = STATE_BEIJING
	set_market_capital = STATE_BEIJING
	set_variable = mgn_capital_moved_to_china
	trigger_event = { id = mgn_route_events.30 popup = yes }
}
```

南京迁都按钮同理，使用 `STATE_NANJING`；迁都后不自动落成南京紫禁城，只解锁玩家在南京自建 `building_mgn_nanjing_forbidden_city` 的条件。应天府迁都按钮使用 `STATE_LOWER_EGYPT`，表示朝廷正式以北非埃及应天府为新的中原。

“恢复东北边界”与“恢复西北边界”只处理本国附庸层级持有的土地，不从独立国家或其他宗主国手中无条件夺地。接收方固定按大清 `CHI` 存续 → 内地经略公司 `MDC` 存续 → 大明 `MGN` 直辖的顺序选择。东北恢复外满洲与阿穆尔；西北恢复阿尔泰、图瓦、准噶尔、天山、七河、库伦、乌里雅苏台，并对分州的吉尔吉斯采用原版 1836 大清 `owned_provinces` 清单逐省转移，因此仍保留与浩罕相同的开局分界。

### 大清版 `je_mgn_rebuild_state_qing`

挂载按钮：

- `button_mgn_restore_northeastern_border`
- `button_mgn_restore_northwestern_border`

大清版不移除大清主流文化，不迁都。

两个重建日志均不设置完成条件并默认置顶。其每周脉冲还会为升级前已经进入重建阶段的旧存档补挂“经略四方”。

## 经略四方日志

`je_mgn_administer_four_quarters` 由大明、大清胜利方共用，在进入重建阶段时与对应“重建国家”同时添加，并默认置顶。按钮按地理叙事顺序排列：

- `button_mgn_establish_mainland_company`
- `button_mgn_establish_korean_company`
- `button_mgn_establish_japanese_company`
- `button_mgn_establish_siberian_company`
- `button_mgn_establish_central_asian_company`
- `button_mgn_establish_southeast_asian_company`
- `button_mgn_establish_lanfang_company`
- `button_mgn_establish_african_company_ming`
- `button_mgn_establish_african_company_qing`

最后两个非洲按钮同时挂载，但各自的 `visible` 限定为大明或大清，因此玩家实际只会看到一个。所有公司按钮要求已经进入重建阶段、对应公司当前不存活、首都不在对应区域，并且本国、非公司附庸或附庸的附庸控制对应区域任意州。按钮 effect 只显示短 `custom_tooltip`，真正的创建、划地、整合与事件触发放入 `hidden_effect`，避免 tooltip 展开长州列表。西伯利亚范围排除图瓦；扶桑范围排除琉球；南洋范围排除归兰芳公司的婆罗洲。

“经略四方”不设置完成条件。公司被吞并或不再存活后，原按钮会重新可用。

### 臣服方 `je_mgn_bitter_peace`

挂载按钮：

- `button_mgn_request_independence`

按钮条件：

- 当前国家是另一个中华国家的臣属。
- 双方均无战争、无外交博弈、无停战协议。

按钮效果：

```txt
create_diplomatic_play = {
	name = mgn_independence_demand
	type = dp_mgn_two_chinas_independence
	target_country = <另一个中华国家>
}
```

AI 臣服方 `ai_chance = 0`，不会主动点击。该外交博弈使用专用 `mgn_two_chinas_independence` 战争目标，底层 `kind = independence`，成功后为双方重启“两个中华”日志。

## 特许公司实施方案

当前实现的特许公司 tag 以 `MCC` 为非洲公司，其他区域公司另列如下。本地化名按宗主国与臣属状态动态显示：

- 大明宗主且为特许公司附庸：`大明非洲榷务公司`
- 大清宗主且为特许公司附庸：`大清非洲榷务公司`
- 大明/大清宗主但不是特许公司附庸：`大明非洲都护府` / `大清非洲都护府`
- 独立后按政体切换：君主制 `非洲中华王国`，总统共和 `非洲中华共和国`，议会共和 `非洲中华联邦共和国`，委员会共和 `非洲中华公社联盟`，法团 `非洲榷务共和国`，技政 `非洲中华技政共和国`，神权 `非洲礼教国`，一党制 `非洲中华训政共和国`，无政府 `非洲中华自由公社联盟`。

已检查：`MCC` 未在本 mod 或当前原版 `common/country_definitions` / `common/dynamic_country_names` 中占用。

区域公司 tag：

- `MDC`：内地经略公司，覆盖大清开局领土范围、库页岛、琉球，以及西藏阿里/拉萨/喜马拉雅/东喜马拉雅；主流文化为汉；首都偏好北京。琉球在公司设立时默认随该范围划入。
- `MKC`：东藩榷务公司，覆盖开局朝鲜、沙里院、两湖/关北等朝鲜目标州；主流文化依次为汉、海东中华；首都偏好汉城。
- `MLF`：兰芳榷务公司，覆盖北婆罗洲、东婆罗洲、西婆罗洲；主流文化依次为汉、南洋中华；首都偏好西婆罗洲。
- `MSB`：西伯利亚榷务公司，覆盖除图瓦外的游戏内西伯利亚地理区域，并显式包含外满洲、阿穆尔、库页岛、鄂霍茨克、楚科奇、勘察加；主流文化依次为汉、朔方中华；国教儒家；首都偏好伊尔库茨克。
- `MCA`：中亚榷务公司，覆盖现实中亚五国范围，包含梅尔夫；主流文化依次为汉、天山中华；国教儒家；首都偏好梅尔夫。
- `MJP`：扶桑榷务公司，覆盖原版 1.13 的北海道、东北、关东、东海、北信越、大阪、京都、中国、四国、九州十州，不含琉球；主流文化依次为汉、扶桑中华；首都优先关东、其次大阪。
- `MSE`：南洋经略公司，覆盖缅甸六州、暹罗/老挝/柬埔寨五州、越南三州及马来亚，共十五州；主流文化依次为汉、交南中华；首都优先曼谷、其次北圻、再次马来亚。

命名原则：

- “内地经略公司”强调统一后对旧大陆腹地的行政、粮饷与商税重整，不把内地简单称为殖民地。
- “东藩榷务公司”保留朝贡/藩部语感，突出关税、矿务、港口与交通经营。
- “兰芳榷务公司”借南洋兰芳与会馆/公议传统，突出港务、锡矿、商路与华人公司政权。
- “西伯利亚榷务公司”偏向北境、寒海口岸、皮货与矿山经营。
- “中亚榷务公司”偏向绿洲、商道、水渠、矿山与边疆榷税。
- “扶桑榷务公司”以传统地理名区分于直接复刻日本民族国家，突出日语本地制度与中华特许章程的结合。
- “南洋经略公司”统筹大陆东南亚与马来半岛；桥梁文化称“交南中华”，避免与兰芳的“南洋中华”重名。

新增两公司废案记录：

- 日本公司不直接采用 `japanese` 为主流文化；这会把日本民族国家身份直接等同于公司共同体。早期“只使用单一 `fusang_han`、不附加 `han`”方案也已废弃；现行统一规则要求所有特许公司以汉为第一主流文化，再加入地方桥梁文化。
- 日本公司不纳入琉球。琉球保留在内地经略范围，以维持其处于中华朝贡体系与日本列岛之间的特殊地位；让两家公司共享琉球范围会制造成立顺序冲突。
- 东南亚公司不直接采用 `vietnamese/thai/burmese/khmer/lao/malay` 主流文化清单，也不复用兰芳的 `nanyang_han`。前者会让主流文化变成人口来源枚举，后者会抹平大陆经略体系与婆罗洲公司社会的区别。
- “中南半岛榷务公司”过于现代地理学，“交南榷务公司”又容易被理解为仅限越南；最终国家名采用覆盖面清楚的“南洋经略公司”，文化名采用更具世界观风味的“交南中华”。
- 交南中华未采用官话、泰语或马来语。官话会把它写成海外汉人，泰语与马来语又难解释越南儒学官僚传统；最终采用越语作为制度语言，并以东南亚 heritage group 覆盖更广的地方根基。
- 未直接引用原版 `region_indochina` 作为公司范围；显式州清单避免游戏更新改变战略区域时悄然扩大或缩小法定边界。

设立原则：

- 公司成立时应拥有转移过来的全部可用目标区域地块，并且全部设为已整合，即 `set_state_type = incorporated`。
- 可用地块包括本国直接拥有的州，以及非公司附庸或附庸的附庸拥有的州；公司臣属持有的州不会被其他公司再次划走。
- 建立公司前会先转移目标区域非公司附庸的直接臣属给宗主，避免该附庸被公司吃掉后其下级附庸独立。
- 公司成立后通过 `on_monthly_pulse_country` 与 `on_state_owner_change` 调用 `mgn_integrate_company_target_states`，后续打下并交给该公司的目标区域州也会自动变为已整合。
- 非洲公司在首都位于非洲时禁用；其余七家公司同理按各自法定区域排除。
- 公司初始必须采用 `law_mgn_heavenly_subjecthood`（天朝万民）。
- 各公司初始采用 `law_extraction_economy`（盘剥经济制度）；西伯利亚与中亚公司额外固定为国教制。
- 除特许公司/殖民公司专属法律外，公司其他法律应继承宗主国当前法律，而不是固定回到大明开局法律。
- 如果宗主国法律与特许公司专属法律冲突，以特许公司专属法律优先覆盖；首版至少固定覆盖公民权与经济制度。
- 所有中华属特许公司创建时设置 `mgn_company_cannot_form_china` 变量；同时 `CHI` 成国定义在 `00_formable_countries.txt` 同名覆盖文件中调用 `mgn_is_chinese_chartered_company`，从成国界面层面阻止它们成立中国。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 在非臣服状态下使用独立动态国号与 `*_free` 旗帜：内地经略国、东藩经略国、兰芳公议国、北庭经略国、西域经略国、扶桑经略国、南洋经略国。

需要新增/扩展：

- `common/country_definitions/00_mgn_countries.txt`
- `common/dynamic_country_names/00_mgn_dynamic_country_names.txt`
- `common/flag_definitions/00_mgn_flag_definitions.txt`
- `common/coat_of_arms/coat_of_arms/00_mgn_coat_of_arms.txt`
- `localization/simp_chinese/mgn_l_simp_chinese.yml`
- `localization/english/mgn_l_english.yml`

国家定义建议：

```txt
MCC = {
	color = { 150 75 40 }
	country_type = company
	tier = kingdom
	cultures = { han african_han western_han }
	religion = confucian
	capital = STATE_LOWER_EGYPT
}

MDC = {
	country_type = company
	tier = kingdom
	cultures = { han }
	religion = confucian
	capital = STATE_BEIJING
}

MKC = {
	country_type = company
	tier = kingdom
	cultures = { han haedong_han }
	religion = confucian
	capital = STATE_SEOUL
}

MLF = {
	country_type = company
	tier = kingdom
	cultures = { han nanyang_han }
	religion = confucian
	capital = STATE_WEST_BORNEO
}

MSB = {
	country_type = company
	tier = kingdom
	cultures = { han shuofang_han }
	religion = confucian
	capital = STATE_IRKUTSK
}

MCA = {
	country_type = company
	tier = kingdom
	cultures = { han tianshan_han }
	religion = confucian
	capital = STATE_MERZ
}

MJP = {
	country_type = company
	tier = kingdom
	cultures = { han fusang_han }
	religion = mahayana
	capital = STATE_KANTO
}

MSE = {
	country_type = company
	tier = kingdom
	cultures = { han jiaonan_han }
	religion = mahayana
	capital = STATE_BANGKOK
}
```

核心 scripted effect：

```txt
mgn_create_african_chartered_company = {
	if = {
		limit = {
			any_scope_state = {
				owner = ROOT
				state_region = s:STATE_LOWER_EGYPT
			}
		}
		random_scope_state = {
			limit = {
				owner = ROOT
				state_region = s:STATE_LOWER_EGYPT
			}
			save_scope_as = mgn_african_company_capital
		}
	}
	else = {
		random_scope_state = {
			limit = {
				owner = ROOT
				is_in_geographic_region = geographic_region_africa
			}
			save_scope_as = mgn_african_company_capital
		}
	}

	if = {
		limit = { NOT = { exists = c:MCC } }
		create_country = {
			tag = MCC
			origin = ROOT
			state = scope:mgn_african_company_capital
			on_created = {
				activate_law = law_type:law_mgn_heavenly_subjecthood
				add_primary_culture = cu:han
				add_primary_culture = cu:african_han
				add_primary_culture = cu:western_han
			}
		}
	}

	create_diplomatic_pact = {
		country = c:MCC
		type = chartered_company
	}

	every_scope_state = {
		limit = {
			owner = ROOT
			is_in_geographic_region = geographic_region_africa
		}
		set_state_owner = c:MCC
		set_state_type = incorporated
	}

	c:MCC ?= {
		mgn_inherit_overlord_laws_except_company_specific = { OVERLORD = ROOT }
		activate_law = law_type:law_mgn_heavenly_subjecthood
		activate_law = law_type:law_extraction_economy
	}
}
```

实现风险：

- 不再硬写 `create_country state = s:STATE_LOWER_EGYPT.region_state:ROOT`。当前实现会优先在宗主国拥有的下埃及/应天府保存 `scope:mgn_african_company_capital`；若宗主国未拥有下埃及，则从宗主国实际拥有的非洲州中随机选择，以该州创建 `MCC`，再把宗主国拥有的全部非洲州转给 `MCC` 并整合；这能兼顾应天府首都偏好和下埃及作用域/所有权边界下的释放稳定性。
- `MCC` 使用 `country_type = company`，以满足 `subject_type_chartered_company` 的有效附属国类型要求；mod 覆盖 `subject_type_chartered_company`，只额外允许 `unrecognized` 宗主国和未认可宗主等级，以便大明/大清能建立特许公司级别附庸关系；创建后强制 `law_colonial_administration`、`law_mgn_heavenly_subjecthood` 与 `law_extraction_economy`。
- 动态国名使用更中华化的“非洲榷务公司”；但只有 `subject_type_chartered_company` 时才显示特许公司国号。若 `MCC` 后续变为非特许附庸，则改称“非洲都护府”；若独立，则按政体切换为上述独立国号。
- 特许公司旗帜使用黑底金边、金环、商船与小型龙纹，表达“公司经营 + 天朝授权”；非特许/独立基础旗帜使用朱红底、金环、非洲象与小型龙纹，避免和大明本土龙旗混同。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA` 的特许公司臣属旗帜使用 `*_chartered`；独立后触发 `is_subject = no` 的 `*_free` 旗帜。内地经略公司章旗与自由旗都使用黑色圆形/花环边界，解决金色圆界与金龙重叠导致的小图标低对比问题。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA` 的非臣服动态国号分别为“内地经略国”“东藩经略国”“兰芳公议国”“北庭经略国”“西域经略国”；若是非特许臣属则仍使用“经略府/都护府”式名称。
- 原版 `CHI` 成国定义位于 `common/country_formation/00_formable_countries.txt`，单独新增 `99_mgn_country_formation.txt` 不会覆盖原版 `CHI`。当前实现改为在 mod 中提供同名 `00_formable_countries.txt` 覆盖文件，只在 `CHI` 段新增 `mgn_chinese_chartered_company_cannot_form_china_tt` / `mgn_is_chinese_chartered_company` 限制。
- 大明/大清完成统一并打开“重建国家”日志时，获得 10 年 `mgn_chinese_unification_integration_drive`：`state_incorporation_speed_mult = 0.25`。这是统一后的行政整合红利，不直接改变州状态。
- 若 `create_country` 后再 `set_state_owner` 大量州导致市场/建筑/军队异常，第一版可只转移州，不转移军队，实测后再补军队处理。
- `law_mgn_heavenly_subjecthood` 与 `law_mgn_huayi_unity` 的 `is_visible` 已扩展到全部八个公司 tag。
- “继承宗主国法律但排除公司专属法律”需要写成显式 scripted effect。不要尝试自动遍历所有 law group；Victoria 3 脚本通常更适合逐法律组判断宗主国当前法律并 `activate_law`。
- `is_in_geographic_region = geographic_region_africa` 在原版事件和日志中可用于州/国家相关 scope；正式写 effect 时仍要用游戏日志验证 scope 是否落在 `state` 上。

## 文件实施顺序

### 第 1 步：触发器

编辑 `common/scripted_triggers/00_mgn_scripted_triggers.txt`，新增：

- `mgn_qing_counterpart_exists`
- `mgn_two_chinas_exist`
- `mgn_two_chinas_not_at_war`
- `mgn_two_chinas_no_truce`
- `mgn_has_brotherly_hierarchy`
- `mgn_government_category_presidential_republic`
- `mgn_government_category_parliamentary_republic`
- `mgn_government_category_council_republic`
- `mgn_government_category_corporate_state`
- `mgn_has_same_unifiable_government_as_target`
- `mgn_has_higher_rank_than_target`
- `mgn_ming_can_claim_reconquest_complete`
- `mgn_qing_can_claim_conquest_complete`
- `mgn_can_establish_african_company`
- `mgn_can_establish_mainland_company`
- `mgn_can_establish_korean_company`
- `mgn_can_establish_siberian_company`
- `mgn_can_establish_central_asian_company`

验收：

- 脆弱统一前，`c:CHI` 被识别为大清对应方。
- 触发 `china_shatters` 后，`c:CHI` 不再被识别为大清对应方。

### 第 2 步：脚本效果

新增 `common/scripted_effects/00_mgn_route_effects.txt`：

- `mgn_start_ming_rebuild_state`
- `mgn_start_qing_rebuild_state`
- `mgn_annex_two_chinas_target`
- `mgn_create_african_chartered_company`
- `mgn_create_mainland_chartered_company`
- `mgn_create_korean_chartered_company`
- `mgn_create_siberian_chartered_company`
- `mgn_create_central_asian_chartered_company`
- `mgn_move_capital_to_beijing`
- `mgn_move_capital_to_nanjing`
- `mgn_finish_mainland_company`
- `mgn_finish_korean_company`
- `mgn_finish_siberian_company`
- `mgn_finish_central_asian_company`
- `mgn_finish_ming_rebuild_state`
- `mgn_finish_qing_rebuild_state`
- `mgn_inherit_overlord_laws_except_company_specific`

验收：

- 每个 effect 可被事件或按钮单独调用。
- 领土/文化变更集中在 effects，按钮只调用 effects。

### 第 3 步：日志条目

新增 `common/journal_entries/00_mgn_route_journal_entries.txt`：

- `je_mgn_two_chinas`
- `je_mgn_rebuild_state_ming`
- `je_mgn_rebuild_state_qing`
- `je_mgn_bitter_peace`

`je_mgn_two_chinas` 挂载按钮：

- `button_mgn_request_open_migration`
- `button_mgn_request_regulated_migration`
- `button_mgn_request_closed_migration`
- `button_mgn_recognize_brotherly_hierarchy`
- `button_mgn_launch_peaceful_unification`
- `button_mgn_launch_ming_reconquest`
- `button_mgn_launch_qing_conquest`

`je_mgn_two_chinas` 自动检测：

- `mgn_ming_can_claim_reconquest_complete`
- `mgn_qing_can_claim_conquest_complete`

`je_mgn_rebuild_state_ming` 挂载按钮：

- `button_mgn_request_open_migration`
- `button_mgn_request_regulated_migration`
- `button_mgn_request_closed_migration`
- `button_mgn_launch_peaceful_unification`
- `button_mgn_move_capital_beijing`
- `button_mgn_move_capital_nanjing`
- `button_mgn_establish_african_company_ming`
- `button_mgn_establish_mainland_company`
- `button_mgn_establish_korean_company`
- `button_mgn_establish_siberian_company`
- `button_mgn_establish_central_asian_company`

`je_mgn_rebuild_state_qing` 挂载按钮：

- `button_mgn_request_open_migration`
- `button_mgn_request_regulated_migration`
- `button_mgn_request_closed_migration`
- `button_mgn_launch_peaceful_unification`
- `button_mgn_establish_african_company_qing`
- `button_mgn_establish_mainland_company`
- `button_mgn_establish_korean_company`
- `button_mgn_establish_siberian_company`
- `button_mgn_establish_central_asian_company`

`je_mgn_bitter_peace` 挂载按钮：

- `button_mgn_request_independence`

验收：

- “两个中华”开局可见。
- 重建日志在吞并、臣服或和平统一后出现；若双方重新独立并存，则切回“两个中华”。
- 日志没有自动吞并或自动迁都。

### 第 4 步：按钮

新增 `common/scripted_buttons/00_mgn_route_buttons.txt`。

按钮必须遵守：

- `visible` 控制什么时候显示。
- `possible` 放硬条件和 tooltip 条件。
- `effect` 只调用 scripted effects 或触发事件。
- `ai_chance` 对路线结局按钮默认 0；和平统一 AI 发起可给低权重；AI 目标方同意在事件里处理。

验收：

- 条件不满足时按钮显示灰掉或不显示，不会悄悄执行。
- 有停战协议时和平统一、移民政策要求、要求独立按钮不可点击。

### 第 5 步：事件

新增 `events/mgn_route_events.txt`：

- `mgn_route_events.10`：大明宣告反攻大陆完成。
- `mgn_route_events.20`：大清宣告武力统一完成。
- `mgn_route_events.30`：大明迁都北京/南京，可拆成 30/31。
- `mgn_route_events.40`：大明设立非洲特许公司。
- `mgn_route_events.50`：大清设立非洲特许公司。
- `mgn_route_events.100`：大清收到大明和平统一提议。
- `mgn_route_events.101`：大明收到大清和平统一提议。
- `mgn_route_events.120`：大清收到大明修改边境移民政策要求。
- `mgn_route_events.121`：大明收到大清修改边境移民政策要求。
- `mgn_route_events.130`：臣服方收到“苦涩的和平”提示。
- `mgn_route_events.140`：设立内地经略公司。
- `mgn_route_events.141`：设立东藩榷务公司。
- `mgn_route_events.142`：设立西伯利亚榷务公司。
- `mgn_route_events.143`：设立中亚榷务公司。
- `mgn_route_events.144`：设立兰芳榷务公司。

事件美术资源要求：

- 每个路线事件都必须设置有效的 `icon = "gfx/interface/icons/event_icons/..."`，只使用当前原版实际存在的图标，例如 `waving_flag.dds`、`event_scales.dds`、`event_trade.dds`、`event_industry.dds`。
- 不使用不存在的短名图标，如 `government.dds`、`industry.dds`、`diplomat.dds`，否则会回落到默认圆脸占位图。
- 每个弹出事件都应设置 `event_image = { video = "..." }`，复用原版 `gfx/event_pictures/*.bk2` 的无扩展名资源。迁都/统一类偏城市、朝廷或统治者画面；外交类偏谈判/迁徙；特许公司类偏建设、合同、商路与边疆经营。
- 国家修正与限时修正应在 `common/static_modifiers/00_mgn_modifiers.txt` 中设置有效的 `gfx/interface/icons/timed_modifier_icons/*.dds`，例如文书、旗帜、齿轮类图标；不要让修正使用默认占位图。

和平统一事件必须：

- 玩家目标方可同意或拒绝。
- AI 目标方 100% 同意。
- 拒绝后不直接绕过停战保护；事件出现前按钮已要求无停战，拒绝后可以开战或给发起方临时宣战按钮。

### 第 6 步：特许公司国家

新增 `MCC`、`MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 国家、旗帜、动态名、本地化。

同步调整：

- `law_mgn_heavenly_subjecthood` 的 `is_visible` 扩展到全部八个公司 tag。
- `law_mgn_huayi_unity` 的 `is_visible` 扩展到全部八个公司 tag。
- 明确 `MCC` 初始/覆盖法律：公民权固定为“天朝万民”，经济制度固定为 `law_extraction_economy`，其他法律继承宗主国。
- 明确 `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 初始/覆盖法律：公民权固定为“天朝万民”，经济制度固定为 `law_extraction_economy`，其他法律继承宗主国；`MSB`、`MCA` 额外固定国教制。
- 新增统一胜利方专属经济制度变体：`law_mgn_overseas_cooperative_ownership`，中文名“人民资本合作制”。该法律前序与原版合作社所有制一致，但额外限定只有大明/大清胜利者本体可制定；大明与仍为有效中华竞争者的大清从开局即可看见该法律，胜负未定时灰显，便于玩家提前预览。国内等同合作社所有制，海外投资不启用原版合作社所有制的 `country_foreign_collectivization_bool`。公司不自动继承该变体；若宗主采用该变体，公司法律继承映射为普通合作社所有制。为修复法律详情中缺少原版合作社所有制“解锁新法律/生产方式、禁用生产方式”的问题，需同步覆盖相关反向引用：无政府制、集体化农业、城市中心艺术赞助和公司总部所有权生产方式都把该变体加入对应 `unlocking_laws` 或 `disallowing_laws`。无政府制与集体化农业使用完整同名原版文件覆盖；另建重复法律对象的旧方案已废弃。命名备选曾包括“特色合作社所有制”“社会主义市场合作制”“有特色的合作社所有制”“一国两制所有制”“内公外私”等，最终采用“人民资本合作制”以保留现代制度梗和所有权机制暗示。
- 政体彩蛋已实现 `law_mgn_revolutionary_committees`（革命委员会制）：委员会共和国下的大明、大清或合法中华中央政府可制定；它解锁工厂委员会、计划经济和仅在法律生效时显示的“批斗”人物互动，并保持“中华苏维埃社会主义共和国联盟”国号。工厂委员会与计划经济依赖当前 1.13 完整同名法律文件覆盖，游戏更新后须重新比对。完整数值、概率和维护路径见 `docs/implementation-map.md`；设计取舍与废案见 `docs/design-plan.md` 的“革命委员会制彩蛋”。
- 数值采用“有味道版”推荐：保留合作社主体数值，额外加入 `country_free_charters_add = 2`、`state_capitalists_investment_pool_efficiency_mult = 0.25`、`country_loan_interest_rate_mult = -0.10`。这比只加一枚免费公司特许更能体现“人民资本”，但比完整自由放任缝合温和；废案为 `country_loan_interest_rate_mult = -0.25`、`country_force_privatization_bool = yes`、`country_forbid_monopoly_bool = yes`，理由是强度过高且强制私有化会冲淡国内合作化叙事。未来若需削弱，优先回退贷款利率优惠，再把免费特许降回 1；若需强化，可先考虑把贷款利率调到 `-0.15`，不要直接加入强制私有化。

验收：

- `MCC` 能成立。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 能成立。
- `MCC` 能使用大明公民权变体。
- 新增公司均能使用大明公民权变体。
- `MCC` 成为 `chartered_company`。
- 新增公司均成为 `chartered_company`。
- `MCC` 拥有的全非洲地块均为已整合。
- 新增公司拥有的目标区域地块均为已整合。
- `MCC` 成立后拥有“天朝万民”和 `law_extraction_economy`。
- 新增公司成立后拥有“天朝万民”和 `law_extraction_economy`；`MSB`、`MCA` 采用国教制。
- `MCC` 除特许公司专属覆盖项外，其他法律与宗主国一致。
- 大明版设立公司后，大明只保留 `han` 主流文化。
- 中华属特许公司在拥有足够中华文化本土后仍不能成立 `CHI`。
- `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 脱离臣服后切换到自由态动态国号与 `*_free` 旗帜。

### 第 7 步：本地化

扩展 `localization/simp_chinese/mgn_l_simp_chinese.yml` 与 `localization/english/mgn_l_english.yml`，至少包含：

- “两个中华”“重建国家”“经略四方”“苦涩的和平”日志标题、描述与原因。
- 所有按钮名、按钮描述、按钮效果描述。
- 和平统一事件标题、描述、选项。
- 重建国家事件标题、描述、选项。
- 关键 tooltip：大清仍存在、北洋已取代大清、双方有停战协议、关系未达友善、政体未趋同、国际地位不足、移民政策已经一致。

英文本地化与中文同步维护，避免脚本 key 在英文环境下裸露。

## 测试矩阵

最低测试集：

1. 1836 开局，大明可见“两个中华”，大清仍被识别为对应方。
2. 触发或模拟 `china_shatters` 后，“两个中华”不再把北洋/军阀中央政府当作大清。
3. 大明拥有北京、南京、直隶后，反攻大陆按钮可用，并添加大明版“重建国家”。
4. 大清拥有下埃及、尼日尔三角洲、开普、刚果后，武力统一按钮可用，并添加大清版“重建国家”。
5. 一方臣属另一方时，领导方同时保留“两个中华”并进入“重建国家”“经略四方”，三个日志均默认置顶；臣服方进入“苦涩的和平”。
6. 双方总统共和、友善、无战争、无停战、发起方国际地位更高时，和平统一按钮可用；若目标方为臣属，则需累计臣服满五年。
7. 双方有停战协议时，和平统一按钮不可用。
8. 玩家作为目标方时，可拒绝和平统一并进入战争路径。
9. AI 作为目标方时，默认同意和平统一。
10. 大明/大清一方国际地位更高且移民政策不同时，可以要求对方采用本国移民政策。
11. AI 作为目标方时，默认同意修改边境移民政策。
12. 玩家拒绝修改边境移民政策时，双方进入事件专用博弈，并各自获得要求对方采用本国移民政策的战争目标。
13. 修改边境移民政策被接受后，双方获得停战协议。
14. 臣服方“苦涩的和平”日志显示要求独立按钮；AI 臣服方不会主动点击，玩家点击后走专用独立外交博弈。
15. “重建国家”只显示迁都和边界整理按钮；“经略四方”按内地、东藩、扶桑、西伯利亚、中亚、南洋、兰芳、非洲顺序显示公司按钮。
16. 首都不在非洲，且直接或通过非公司臣属控制任意非洲州时，非洲公司按钮可用；首都在非洲时不可用。
17. 首都不在内地公司区域，且直接或通过非公司臣属控制任意目标州时，内地经略公司按钮可用；首都在内地时不可用。
18. 从旧版本载入已经拥有“重建国家”的存档时，每周脉冲能补挂“经略四方”；若领导方的“两个中华”旧日志已经结束，也能重新补挂。
19. 大明进入“重建国家”后，北京与南京迁都按钮始终显示；未完整拥有目标州时按钮灰显且不可点击。
20. 恢复东北或西北边界时，接收方严格按存续大清、内地经略公司、大明本体的顺序选择。
21. 东海、北信越、京都与其余日本本土州均带有扶桑中华 homeland，并能随扶桑榷务公司按钮正确划转。
22. 琉球不进入扶桑范围；设立内地经略公司时默认划入该公司。
23. 八家公司国家定义和创建 effect 均以汉为第一主流文化，再列地方桥梁文化。
    已存在于旧存档的公司会在首次月度维护时执行一次文化顺序规范化，避免只修新建公司。
24. 首都不在朝鲜公司区域，且直接或通过非公司臣属控制任意目标州时，东藩榷务公司按钮可用。
25. 首都不在兰芳公司区域，且本国、非公司附庸或附庸的附庸控制北/东/西婆罗洲任意目标州时，兰芳榷务公司按钮可用。
26. 首都不在西伯利亚公司区域，且本国、非公司附庸或附庸的附庸控制除图瓦外任意目标州时，西伯利亚榷务公司按钮可用。
27. 首都不在中亚公司区域，且本国、非公司附庸或附庸的附庸控制任意目标州时，中亚榷务公司按钮可用。
28. 首都不在日本本土，且本国、非公司附庸或附庸的附庸控制北海道至九州任意目标州时，扶桑榷务公司按钮可用；琉球不计入。
29. 首都不在南洋经略范围，且本国、非公司附庸或附庸的附庸控制缅甸、暹罗、老挝、柬埔寨、越南或马来亚任意目标州时，南洋经略公司按钮可用；婆罗洲不计入。
30. 设立 `MCC` 后，非洲州转移给公司，公司成为特许公司附庸。
31. 设立 `MDC` 后，大清开局领土范围外加西藏、库页岛、琉球、吉尔吉斯、伊犁、图瓦中的可用州转移给公司，公司成为特许公司附庸。
32. 设立 `MKC` 后，朝鲜目标州转移给公司，公司成为特许公司附庸。
33. 设立 `MLF` 后，北婆罗洲、东婆罗洲、西婆罗洲目标州转移给公司，公司成为特许公司附庸。
34. 设立 `MSB` 后，除图瓦外的西伯利亚目标州转移给公司，公司成为特许公司附庸；图瓦仍归内地经略公司范围。
35. 设立 `MCA` 后，中亚目标州转移给公司，公司成为特许公司附庸。
36. 设立 `MJP` 后，日本本土十州中的可用目标州转移给公司，东海、北信越、京都均包含在内；琉球不转移。
37. 设立 `MSE` 后，大陆东南亚与马来亚十五州中的可用目标州转移给公司，婆罗洲不转移。
38. 大明版设立非洲公司后，大明移除 `african_han` 与 `western_han`，只保留 `han`。
39. 大清版设立公司后，大清主流文化不被修改。
40. 各公司拥有的目标地块均为已整合；公司后续获得目标区域州时，该州会自动整合。
41. 若在附庸领土上设立公司并导致该附庸灭国，其附庸的附庸会转给宗主，不会独立。
42. 各公司初始采用“天朝万民”和 `law_extraction_economy`；`MSB`、`MCA` 额外采用国教制。
43. 各公司除公司专属法律覆盖外，其他法律继承宗主国。
44. `MDC` 或其他中华属特许公司即使拥有足够中国本土和汉/满等主流文化，也不能成立 `CHI`。
45. 路线日志、弹出事件和国家修正在 UI 中不显示默认圆脸占位图；所有 `event_icons`、`event_image video` 与 `timed_modifier_icons` 均能在原版资源目录中找到。
46. `MDC`、`MKC`、`MLF`、`MSB`、`MCA`、`MJP`、`MSE` 脱离臣服后使用自由态动态国号和 `*_free` 旗帜；臣服特许公司状态仍使用 `*_chartered`。

## 待实测问题

- `country_rank > scope:target_country.country_rank` 的方向是否确实代表“发起方国际地位更高”。若测试发现相反，改用分档 trigger。
- `create_country` 创建 `MCC` 后立刻批量 `set_state_owner` 是否稳定。
- `law_extraction_economy` 是否就是中文“盘剥经济制度”的当前版本 key；当前原版 `common/laws/00_economic_system.txt` 中已找到该法律，但本地化名需在实现前再确认。
- 逐法律组继承宗主国法律的 effect 工作量较大，首版可先覆盖主要法律组，再补齐边缘 law group。
- 和平统一拒绝后从事件创建 `dp_mgn_two_chinas_unification` 外交博弈是否稳定；该博弈已关闭初始战争目标恶名，并通过 `add_war_goal` 给目标方也添加统一战争目标。
- `common/country_formation/00_formable_countries.txt` 采用同名覆盖原版文件；后续游戏版本更新该文件时，需要同步原版新增/调整的其他 formable 条目，避免覆盖旧版本内容。
- 各 `*_free` 旗帜为脚本纹章组合，仍需在实际地图小图标、外交面板和国家列表三个尺寸下观察可读性。
