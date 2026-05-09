# DeepSeek 虚拟开发团队 for Claude Code

> 一个融合多模型的五层 AI 开发团队。调度官统筹全局（DeepSeek），视觉审查官看图（千问/Claude/GPT 任选），项目负责人细化需求，码农写代码，审核官检查质量，调试工程师定位 bug。全中文交流，思维链透明。

## 架构

```
User
 │
 ▼
┌──────────────────────────────────────────┐
│           调度官（Boss）                   │
│           v4-pro · 大脑                   │
│     理解 → 决策 → 派发 → 终审             │
└──┬───────┬────────┬────────┬────────────┘
   │       │        │        │
   ▼       ▼        ▼        ▼
┌──────┐ ┌──────┐ ┌──────┐ ┌──────────────┐
│ 项目  │ │ 码农 │ │审核官│ │ 调试工程师    │
│负责人 │ │v4-flash│ │v4-flash│ │ v4-pro       │
│v4-pro│ │ 双手  │ │ 质检  │ │ 定位+最小修复 │
│ 军师  │ └──────┘ └──────┘ └──────────────┘
└──────┘
                    ┌──────────────┐
                    │  视觉审查官   │
                    │ 千问/GPT/    │
                    │ Claude/Gemini│
                    │ 多模态眼睛    │
                    └──────────────┘
```

| 层 | 角色 | 模型 | 供应商 | 职责 |
|----|------|------|--------|------|
| 顶层 | 调度官 | v4-pro | DeepSeek | 全局上下文理解、战略决策、质量终审、澄清消息循环路由 |
| 中层 | 项目负责人 | v4-pro | DeepSeek | 需求细化、中文技术规格书输出、P3综合报告、澄清应答 |
| 中层 | 审核官 | v4-flash | DeepSeek | 代码质量检查（可并行），只看不改 |
| 底层 | 码农 | v4-flash | DeepSeek | 接收任务单 → 编码 → 自测 → 澄清请求 → 完成报告 |
| 底层 | 调试工程师 | v4-pro | DeepSeek | 复杂 bug 根因定位、最小修复方案、安全/性能扫描 |
| 专属 | **视觉审查官** | 千问/GPT/Claude/Gemini | 用户自选 | 截图/UI/架构图/PDF 分析 |

## 特性

- **全中文交流** — 团队内部通信、用户交互、代码注释全部中文
- **思维链透明** — 每个 Agent 的推理过程对用户可见，交流不黑盒
- **六层团队** — 调度官 + 项目负责人 + 码农 + 审核官 + 调试工程师 + 视觉审查官，职责清晰
- **并行质检** — P2 质检阶段审核官、调试工程师、视觉审查官可同时启动，减少串行等待
- **自定义角色** — 开发者可注册自定义角色（产品经理、安全审计员等），工作流适配更多场景
- **结构化任务单** — 代理间用 Markdown 任务单（技术上下文+交付物+约束验收+澄清记录）替代纯文本，消除信息衰减
- **澄清协议** — 子代理发现信息不足时主动发起澄清请求（≤2轮），拒绝硬猜产生不可用代码
- **多模态视觉** — 视觉审查官独立走多模态模型，DeepSeek 看不见图也能分析截图
- **消息分流** — 简单问答直接回复，代码任务启动团队，不互相阻塞
- **模型分离** — v4-pro 负责"想"，v4-flash 负责"做"，多模态模型负责"看"

## 快速开始

### 前提

- **Claude Code CGG**（必须）：`npm install -g claude-code-cgg`
- DeepSeek API（或其他 Anthropic 兼容端点）
- 一个多模态 API Key（视觉审查官需要）：支持阿里百炼千问 / OpenAI GPT / Anthropic Claude / Google Gemini

### 安装

**方式一：一键安装（推荐）**

```bash
# Windows PowerShell
git clone https://github.com/2951617655-dotcom/deepseek-team.git
cd deepseek-team
powershell -ExecutionPolicy Bypass -File install.ps1

# Linux / macOS / Git Bash
git clone https://github.com/2951617655-dotcom/deepseek-team.git
cd deepseek-team
bash install.sh
```

脚本自动完成：创建目录 → 备份旧文件 → 安装 6 个 Agent + 调度官规则 → 放置 API 配置模板。已有配置文件不会被覆盖。

**方式二：让 Claude Code 自己装**

把仓库克隆下来，然后在 Claude Code 里说：

> "帮我把 deepseek-team 装一下，install.ps1 在仓库根目录"

Claude Code 会自动读取并执行安装脚本，全程不用你动手。

**安装后只需做一件事**：编辑 `~/.claude/settings.json`，填入你的 API Key。然后 `cgg` 启动。

### 启动

```bash
cgg    # 注意：是 cgg，不是 claude
```

首次启动后，调度官会自动询问你的多模态 API 配置（Key、模型名）。提供后自动写入配置，后续无需重复。

### 使用

```
你：帮我看看这张截图 D:\bug.png
调度官：[分流判断] 涉及图片 → 全团队模式 → 派视觉审查官
视觉审查官：[解析任务单 → 自动获取截图路径] → 输出中文视觉报告
调度官：[交付用户]

你：帮我加一个用户登录功能
调度官：[分流判断] 代码修改 → 全团队模式 → 派项目负责人
项目负责人：[P0] → 出规格书 + 附带结构化任务单
调度官：[P1] → 派码农（附任务单）
码农：[解析任务单 → 编码 → 自检 → 输出完成报告]
调度官：[P2 并行质检] → 审核官 + 调试工程师 + 视觉审查官 同时启动
审核官：   [对照任务单约束逐项核对] → 审查报告
调试工程师：[安全/性能扫描] → 扫描报告
视觉审查官：[UI一致性检查] → 视觉报告
调度官：[P3] → 回调项目负责人综合各方报告
调度官：[P4] → 终审 → 交付用户
```

## 目录结构

```
deepseek-team/
├── README.md
├── install.ps1              # Windows 一键安装脚本
├── install.sh               # Linux/macOS 一键安装脚本
├── settings.example.json    # API Key 配置模板（占位符）
├── CLAUDE.md.example       # 调度官行为配置（含核心铁律、并行工作流、自定义角色、结构化任务单、澄清协议）
├── CHANGELOG.md            # 完整更新日志
├── 推广文档.md              # 项目介绍与设计理念
└── agents/                 # 6 个 Agent 定义 + 1 个格式规范
    ├── boss-agent.md              # 调度官
    ├── project-lead-agent.md      # 项目负责人（含P3综合+澄清应答）
    ├── code-reviewer-agent.md     # 审核官（支持并行质检）
    ├── coder-agent.md             # 码农（含任务单解析+澄清请求+完成报告）
    ├── debugger-agent.md          # 调试工程师（含安全/性能扫描+调试澄清）
    ├── visual-inspector.md        # 视觉审查官（多模态）
    └── task-schema.md             # 结构化任务单格式规范（新增）
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
- [toby1123yjh/claude-code-cgg](https://github.com/toby1123yjh/claude-code-cgg) — CGG 多模型协作框架
- [cc-workspace](https://github.com/VincentVanN/cc-workspace) — 多工作区编排参考

## 关于作者

在校大学生课余维护，更新随学期节奏波动。欢迎提 Issue 和意见。

## 许可

禁止商用。个人学习、研究、非商业用途自由使用。转载请注明出处。
