# 非洲大明：Ming in Africa

一个《Victoria 3》架空历史 mod：大明在非洲延续国祚，并从尼罗河畔重新争夺中华正统。

当前版本为 **0.1.3**，支持《Victoria 3》**1.13.x**。实际可加载文件位于 `mod/ming_in_africa`。

**[Steam 创意工坊订阅](https://steamcommunity.com/sharedfiles/filedetails/?id=3764465525)** · **[GitHub Releases 手动下载](https://github.com/wmc54321/vic3-ming-in-africa/releases)**

## 主要内容

- 1836 年从下埃及应天府开局的非洲大明。
- 大清开局直接管辖西藏，但拉萨、阿里及东喜马拉雅原西藏部分保持未整合。
- 以战争、臣属关系或政治趋同处理明清并立。
- 迁都、重建国家和收复中华故土的日志链。
- 面向非洲、亚洲腹地与海外领土的中华属特许公司。
- 专属文化、法律、战争目标、建筑、旗帜与中英文本地化。

## 兼容性

- 支持游戏版本：`1.13.*`
- DLC：没有强制 DLC 要求。
- 本 mod 替换 `common/history/states`，通常不兼容其他修改 1836 年州所有权、开局国土或州历史的 mod。
- 本 mod 同名覆盖劳工组织、经济制度、土地改革和权力分配法律文件，以补全自定义法律的原版解锁链；可能与其他修改这些原版法律文件的 mod 冲突。
- 与“大洋国—汉洲联省共和国”的兼容性已经完成技术调查，但当前尚未实现；未来可选择通过独立兼容补丁支持，现阶段不要把两个本体直接共载视为受支持组合。
- 建议新开一局，并在报告问题前用只启用本 mod 的播放集复现。

## 安装

Steam 用户建议直接从 [Steam 创意工坊](https://steamcommunity.com/sharedfiles/filedetails/?id=3764465525) 订阅。手动安装包可从 [GitHub Releases](https://github.com/wmc54321/vic3-ming-in-africa/releases) 下载；将其中的 `ming_in_africa` 文件夹和 `ming_in_africa.mod` 放入《Victoria 3》用户 mod 目录，再在 Paradox Launcher 中启用。

从源码开发时，请复制 `.env.example` 为 `.env.local`，设置 `VICTORIA3_GAME_ROOT`，并运行 `tools/generate_initial_mod.ps1`。本机游戏路径不会写入公开文件。

## 文档入口

- `docs/agent-handoff.md`：新 agent/session 优先阅读的上手索引。
- `docs/implementation-map.md`：当前已实现内容与文件分布。
- `docs/design-plan.md`：总体设计记录与历史方案。
- `docs/route-journal-design.md`：两个中华与重建国家日志链设计。
- `docs/dayang-hanzhou-compatibility-plan.md`：汉洲联省兼容性调查及未来可选实施计划；当前未实现。
- `docs/publishing.md`：GitHub Release 与 Steam 创意工坊发布流程。
- `docs/workshop-description.md`：可直接整理到工坊页面的中英文文案。

## 许可证与声明

本项目作者原创部分采用 [MIT License](LICENSE)。原版游戏数据、Paradox Interactive 的商标和其他第三方内容不在该授权范围内，详见 [NOTICE.md](NOTICE.md)。

本项目是非官方玩家作品，与 Paradox Interactive AB 无隶属、赞助或认可关系。《Victoria 3》及相关商标和原版游戏内容归其各自权利人所有。

本 mod 纯属架空历史与游戏机制创作。作品中的国家、政权、文化、族群、人物、制度与事件均服务于虚构叙事及玩法设计，不影射或评价现实中的国家、民族、族裔、文化、政治组织或个人，也不表达、支持或鼓励任何形式的种族优越论、种族主义、民族仇恨或歧视。

This mod is a work of alternate-history fiction and game design. Its countries, regimes, cultures, peoples, characters, institutions, and events exist solely for fictional narrative and gameplay. They are not intended to represent or judge any real nation, ethnicity, culture, political organization, or individual, nor to express, endorse, or encourage racial supremacy, racism, ethnic hatred, or discrimination of any kind.
