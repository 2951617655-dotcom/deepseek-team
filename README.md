# DeepSeek 虚拟开发团队 for Claude Code

> 一个运行在 DeepSeek 模型上的四层 AI 开发团队。调度官统筹全局，项目负责人细化需求，码农写代码，审核官检查质量。全中文交流，思维链透明。

## 架构

```
User
 │
 ▼
┌─────────────────────────────────┐
│         调度官（Boss）            │
│         v4-pro · 大脑            │
│   理解 → 决策 → 派发 → 终审      │
└──┬──────────┬──────────┬───────┘
   │          │          │
   ▼          ▼          ▼
┌──────┐ ┌──────┐ ┌──────────┐
│ 项目  │ │ 码农 │ │ 审核官   │
│负责人 │ │v4-flash│ │v4-flash │
│v4-pro│ │ 双手  │ │ 质检     │
│ 军师  │ └──────┘ └──────────┘
└──────┘
```

| 层 | 角色 | 模型 | 职责 |
|----|------|------|------|
| 顶层 | 调度官 | v4-pro | 全局上下文理解、战略决策、质量终审 |
| 中层 | 项目负责人 | v4-pro | 需求细化、中文技术规格书输出 |
| 中层 | 审核官 | v4-flash | 代码质量检查，只看不改 |
| 底层 | 码农 | v4-flash | 接收规格书 → 编码 → 自测 → 报告 |

## 特性

- **全中文交流** — 团队内部通信、用户交互、代码注释全部中文
- **思维链透明** — 每个 Agent 的推理过程对用户可见，交流不黑盒
- **三层语言锚定** — 思维模式指令 + 中文环境基底 + 锚定输出，确保 DeepSeek 全程中文推理
- **DeepSeek 深度优化** — 精简 prompt、去除冗余英文示例、中文 Bash 描述防思维切换
- **模型分离** — v4-pro 负责"想"（调度官/负责人），v4-flash 负责"做"（码农/审核官）

## 快速开始

### 前提

- Claude Code 已配置 DeepSeek API（`ANTHROPIC_BASE_URL` 指向 DeepSeek）
- 模型映射：sonnet → v4-pro，haiku → v4-flash

### 安装

```bash
# 1. 克隆仓库
git clone https://github.com/你的用户名/deepseek-team.git

# 2. 部署子代理（3 个）
cp deepseek-team/agents/project-lead.md ~/.claude/agents/
cp deepseek-team/agents/coder.md ~/.claude/agents/
cp deepseek-team/agents/code-reviewer.md ~/.claude/agents/

# 3. 加载调度官行为
# 将 CLAUDE.md.example 的内容合并到你项目的 CLAUDE.md
# 或放在 ~/CLAUDE.md 作为全局默认
```

### 使用

重启 Claude Code，调度官自动激活。正常对话即可：

```
你：帮我加一个用户登录功能
调度官：[判定] 需求模糊 → 派项目负责人
项目负责人：[摸底代码] → [追问确认] → [输出 3 个任务的中文规格书]
调度官：[审核规格书] → 派码农执行任务 1
码农：[编码] → [自测] → [中文完成报告]
调度官：[派审核官审查]
审核官：[检查代码] → [中文审查报告：通过/驳回]
调度官：[终审通过] → [交付用户]
```

## 语言锚定技术

本项目的核心创新——基于 [fkyah3/opencode-yg](https://github.com/fkyah3/opencode-yg) 的系统实验：

| 层级 | 方法 | 效果 |
|------|------|------|
| 思维模式指令 | prompt 首行："请用中文语言思维方式来完成所有任务" | 90%+，零衰减 |
| 环境对齐 | 所有 prompt/工具描述/注释翻译为中文 | 70-90%，基底 |
| 锚定输出 | 首次输出必须是中文总结 | 补充加固 |

完整研究见：[语言锚定 V2 对照实验](https://github.com/fkyah3/opencode-yg)

## 目录结构

```
deepseek-team/
├── README.md
├── CLAUDE.md.example     # 调度官行为配置示例
└── agents/               # 4 个 Agent 定义
    ├── boss-agent.md           # 调度官
    ├── project-lead-agent.md   # 项目负责人
    ├── code-reviewer-agent.md  # 审核官
    └── coder-agent.md          # 码农
```

## 相关项目

- [fkyah3/opencode-yg](https://github.com/fkyah3/opencode-yg) — 语言锚定研究，中文 AI Agent 方法论
- [cc-workspace](https://github.com/VincentVanN/cc-workspace) — 多工作区编排参考
- [everything-claude-code](https://github.com/affaan-m/everything-claude-code) — Agent 零件库参考

## 许可

MIT
