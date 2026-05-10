# DeepSeek 虚拟开发团队 for Claude Code

> 一个融合多模型的六层 AI 开发团队。全中文交流，思维链透明。

## 闪电安装（零操作）

**把下面这行地址发给 Claude Code，然后说"帮我安装这个团队"，剩下的 AI 全自动搞定：**

```
https://github.com/2951617655-dotcom/deepseek-team
```

Claude Code 会自动执行：
1. `git clone` 仓库
2. 运行 `install.ps1`（Windows）或 `install.sh`（Linux/Mac）
3. 安装完成后，编辑 `~/.claude/settings.json` 填入你的 API Key
4. 启动 Claude Code，说一句"你好指挥官"激活团队

> 已有配置不会被覆盖。安装脚本自动备份旧文件。

---

## 架构

```
User
 │
 ▼
┌──────────────────────────────────────────┐
│           调度官（Boss）                   │
│           v4-pro · 总指挥                 │
│     理解→决策→大脑分析→派发→终审          │
└──┬───────┬────────┬────────┬────────────┘
   │       │        │        │
   ▼       ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────────────┐ ┌──────────────┐
│ 项目  │ │大脑  │ │审核官│ │调试工程师     │ │ 视觉审查官    │
│负责人 │ │v4-pro│ │v4-flash│ │ v4-pro        │ │vision.js+    │
│v4-pro│ │ 分析  │ │ 质检  │ │ 定位+最小修复 │ │百炼API 识图  │
│ 军师  │ └──┬───┘ └──────┘ └──────────────┘ └──────────────┘
└──────┘    │
        ▼
   ┌──────┐  ┌──────────────┐
   │ 码农 │  │ 测试工程师    │
   │v4-flash│ │ v4-pro        │
   │ 双手  │  │ 功能验证      │
   └──────┘  └──────────────┘
```

| 层 | 角色 | 模型 | 供应商 | 职责 |
|----|------|------|--------|------|
| 顶层 | 调度官 | v4-pro | DeepSeek | 分流判断、战略决策、spawn大脑(pro)分析代码、派发任务、质量终审 |
| 专属 | **码农大脑** | v4-pro | DeepSeek | 调度官在派码农前 spawn，读代码→分析逻辑→找错误→输出精确 Edit 指令清单 |
| 中层 | 项目负责人 | v4-pro | DeepSeek | 需求细化、中文技术规格书输出、P3综合报告、澄清应答 |
| 中层 | 审核官 | v4-flash | DeepSeek | 代码质量检查（可并行），只看不改 |
| 底层 | 码农（双手） | v4-flash | DeepSeek | 接收大脑 Edit 指令 → 逐条执行 → 自检 → 报告。不自行分析代码 |
| 底层 | 调试工程师 | v4-pro | DeepSeek | 复杂 bug 根因定位、最小修复方案、安全/性能扫描 |
| 底层 | 测试工程师 | v4-pro | DeepSeek | 功能正确性验证，TDD/事后补测，单元/集成/E2E/性能，覆盖率报告 |
| 专属 | **视觉审查官** | qwen3.5-omni-plus | 阿里云百炼 (vision.js CLI) | 截图/UI/架构图/PDF 分析（CLI 识图） |

## 特性

- **分体式码农** — 调度官 spawn 大脑(pro)分析代码找错误，码农(flash)只负责逐条执行 Edit。pro 想、flash 做，消灭嵌套 Agent 不可用的硬限制
- **全中文交流** — 团队内部通信、用户交互、代码注释全部中文
- **思维链透明** — 每个 Agent 的推理过程对用户可见，交流不黑盒
- **七层团队** — 调度官 + 码农大脑 + 项目负责人 + 码农 + 审核官 + 调试工程师 + 视觉审查官 + 测试工程师，职责清晰
- **并行质检** — P2 质检阶段审核官、调试工程师、视觉审查官、测试工程师可同时启动
- **自定义角色** — 开发者可注册自定义角色，工作流适配更多场景
- **结构化任务单** — Markdown 任务单 + JSON 信封 + DAG 编排(depends_on)，消除代理间信息衰减
- **澄清协议** — 子代理信息不足时主动发起澄清（≤2轮），拒绝硬猜
- **多模态视觉** — 视觉审查官通过 vision.js CLI 调用百炼 API (qwen3.5-omni-plus) 识图，DeepSeek 看不见图也能分析截图
- **消息分流** — 简单问答直接回复，代码任务启动团队，不互相阻塞

## 快速开始

### 前置条件

- **Claude Code**：需已安装并配置好 DeepSeek API
- DeepSeek API Key
- 视觉审查官：依赖 [vision.js](https://github.com/asuojun/claude-vision-skill) CLI 脚本，需配置百炼 API Key（详见安装后说明）

### 安装

见顶部「闪电安装」——把仓库地址发给 Claude Code，一切自动完成。

如果偏好手动安装，克隆后运行 `install.ps1`（Windows）或 `install.sh`（Linux/Mac）即可。

安装后编辑 `~/.claude/settings.json` 填入 API Key，然后启动 Claude Code，说一句"你好指挥官"。

### 启动

```bash
claude
```

首次启动后，确保 `vision.js` 已配置百炼 API Key（脚本中 `DASHSCOPE_API_KEY` 变量）。视觉审查官收到图片时会自动调用 `node vision.js` 识图。

### 使用

```
你：帮我看看这张截图 D:\bug.png
调度官：[分流判断] 涉及图片 → 全团队模式 → 派视觉审查官
视觉审查官：[解析任务单 → Bash 调用 vision.js 识图 → 获取文字描述] → 输出中文视觉报告
调度官：[交付用户]

你：帮我加一个用户登录功能
调度官：[分流判断] 代码修改 → 全团队模式 → 派项目负责人
项目负责人：[P0] → 出规格书 + 附带结构化任务单
调度官：[P1 大脑分析] → spawn 大脑(pro) 读代码、分析逻辑、输出 Edit 指令清单
调度官：[P1 编码] → 派码农(flash)，任务单附带大脑指令
码农：[接收大脑指令 → 逐条 Edit → 自检 → 输出完成报告]
调度官：[P2 并行质检] → 审核官 + 调试工程师 + 视觉审查官 + 测试工程师 同时启动
审核官：   [对照任务单约束逐项核对] → 审查报告
调试工程师：[安全/性能扫描] → 扫描报告
视觉审查官：[UI一致性检查] → 视觉报告
测试工程师：[功能验证 + 覆盖率] → 测试报告
调度官：[P3] → 回调项目负责人综合各方报告
调度官：[P4] → 终审 → 交付用户
```

## 目录结构

```
deepseek-team/
├── README.md
├── SKILL.md                  # CC 自动发现：安装 skill
├── install.ps1               # Windows 一键安装脚本
├── install.sh               # Linux/macOS 一键安装脚本
├── settings.example.json    # API Key 配置模板（占位符）
├── CLAUDE.md.example       # 调度官行为配置（含核心铁律、并行工作流、自定义角色、结构化任务单、澄清协议）
├── CHANGELOG.md            # 完整更新日志
├── 推广文档.md              # 项目介绍与设计理念
└── agents/                 # 7 个 Agent 定义 + 1 个格式规范
    ├── project-lead-agent.md      # 项目负责人（含P3综合+澄清应答）
    ├── coder-agent.md             # 码农·双手（接收大脑指令，逐条Edit执行）
    ├── code-reviewer-agent.md     # 审核官（支持并行质检）
    ├── debugger-agent.md          # 调试工程师（含安全/性能扫描+调试澄清）
    ├── visual-inspector.md        # 视觉审查官（多模态）
    ├── task-schema.md             # 结构化任务单格式规范
    └── custom/tester.md           # 测试工程师（TDD/事后补测，覆盖率报告）
```

## 语言锚定技术

本项目的核心创新——基于 [fkyah3/opencode-yg](https://github.com/fkyah3/opencode-yg) 的系统实验：

| 层级 | 方法 | 效果 |
|------|------|------|
| 思维模式指令 | prompt 首行："请用中文语言思维方式来完成所有任务" | 90%+，零衰减 |
| 环境对齐 | 所有 prompt/工具描述/注释翻译为中文 | 70-90%，基底 |
| 锚定输出 | 首次输出必须是中文总结 | 补充加固 |

完整研究见：[语言锚定 V2 对照实验](https://github.com/fkyah3/opencode-yg)

## 相关项目

- [fkyah3/opencode-yg](https://github.com/fkyah3/opencode-yg) — 语言锚定研究，中文 AI Agent 方法论
- [asuojun/claude-vision-skill](https://github.com/asuojun/claude-vision-skill) — vision.js CLI 识图脚本，视觉审查官的核心依赖
- [toby1123yjh/claude-code-cgg](https://github.com/toby1123yjh/claude-code-cgg) — CGG 多模型协作框架（早期版本依赖，现已移除）
- [cc-workspace](https://github.com/VincentVanN/cc-workspace) — 多工作区编排参考

## 关于作者

在校大学生课余维护，更新随学期节奏波动。欢迎提 Issue 和意见。

## 许可

禁止商用。个人学习、研究、非商业用途自由使用。转载请注明出处。
