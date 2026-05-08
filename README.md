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
| 顶层 | 调度官 | v4-pro | DeepSeek | 全局上下文理解、战略决策、质量终审 |
| 中层 | 项目负责人 | v4-pro | DeepSeek | 需求细化、中文技术规格书输出 |
| 中层 | 审核官 | v4-flash | DeepSeek | 代码质量检查，只看不改 |
| 底层 | 码农 | v4-flash | DeepSeek | 接收规格书 → 编码 → 自测 → 报告 |
| 底层 | 调试工程师 | v4-pro | DeepSeek | 复杂 bug 根因定位、最小修复方案 |
| 专属 | **视觉审查官** | 千问/GPT/Claude/Gemini | 用户自选 | 截图/UI/架构图/PDF 分析 |

## 特性

- **全中文交流** — 团队内部通信、用户交互、代码注释全部中文
- **思维链透明** — 每个 Agent 的推理过程对用户可见，交流不黑盒
- **五层团队** — 调度官 + 项目负责人 + 码农 + 审核官 + 调试工程师，职责清晰
- **多模态视觉** — 视觉审查官独立走多模态模型，DeepSeek 看不见图也能分析截图
- **消息分流** — 简单问答直接回复，代码任务启动团队，不互相阻塞
- **模型分离** — v4-pro 负责"想"，v4-flash 负责"做"，多模态模型负责"看"

## 快速开始

### 前提

- **Claude Code CGG**（必须）：`npm install -g claude-code-cgg`
- DeepSeek API（或其他 Anthropic 兼容端点）
- 一个多模态 API Key（视觉审查官需要）：支持阿里百炼千问 / OpenAI GPT / Anthropic Claude / Google Gemini

### 安装

```bash
# 1. 克隆仓库
git clone https://github.com/2951617655-dotcom/deepseek-team.git

# 2. 部署子代理（5 个）
cp deepseek-team/agents/project-lead-agent.md ~/.claude/agents/
cp deepseek-team/agents/coder-agent.md ~/.claude/agents/
cp deepseek-team/agents/code-reviewer-agent.md ~/.claude/agents/
cp deepseek-team/agents/debugger-agent.md ~/.claude/agents/
cp deepseek-team/agents/visual-inspector.md ~/.claude/agents/

# 3. 配置 API Key
cp deepseek-team/settings.example.json ~/.claude/settings.json
# 编辑 ~/.claude/settings.json，填入你的 DeepSeek 和多模态 API Key

# 4. 加载调度官行为
# 将 CLAUDE.md.example 的内容合并到你项目的 CLAUDE.md
# 或放在 ~/CLAUDE.md 作为全局默认
```

### 启动

```bash
cgg    # 注意：是 cgg，不是 claude
```

首次启动后，调度官会自动询问你的多模态 API 配置（Key、模型名）。提供后自动写入配置，后续无需重复。

### 使用

```
你：帮我看看这张截图 D:\bug.png
调度官：[分流判断] 涉及图片 → 全团队模式 → 派视觉审查官
视觉审查官：[分析截图] → 输出中文视觉报告
调度官：[交付用户]

你：帮我加一个用户登录功能
调度官：[分流判断] 代码修改 → 全团队模式
    → 派项目负责人 → 出规格书
    → 派码农 → 编码自测
    → 派审核官 → 审查
    → 终审 → 交付用户
```

## 目录结构

```
deepseek-team/
├── README.md
├── settings.example.json   # API Key 配置模板（占位符）
├── CLAUDE.md.example       # 调度官行为配置示例
├── 推广文档.md              # 项目介绍与设计理念
└── agents/                 # 5 个 Agent 定义
    ├── boss-agent.md              # 调度官
    ├── project-lead-agent.md      # 项目负责人
    ├── code-reviewer-agent.md     # 审核官
    ├── coder-agent.md             # 码农
    ├── debugger-agent.md          # 调试工程师
    └── visual-inspector.md        # 视觉审查官（多模态）
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
