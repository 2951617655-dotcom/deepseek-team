# DeepSeekTeam 使用指南

五分钟搭建你的虚拟开发团队——一个调度官 + 五个专业子代理，在 Claude Code 里跑起来。

---

## 1. 这是什么

DeepSeekTeam 是一套 Claude Code 代理配置文件，把"一个人用 AI 写代码"变成"一个团队协作写代码"：

- **你** → 产品经理/指挥官，提需求、做决策
- **调度官**（CLAUE.md）→ 自动接需求、分流、派活、终审
- **五个子代理** → 各司其职，并行干活

不需要额外服务、不需要数据库、不需要 API 封装层。就是一組 Markdown 配置文件 + 一个 npm 包。

---

## 2. 前提条件

| 依赖 | 用途 | 检查命令 |
|------|------|----------|
| Node.js ≥ 18 | 运行 npm | `node --version` |
| npm | 安装 `claude-code-cgg` | `npm --version` |
| Git | 版本管理（可选但推荐） | `git --version` |
| DeepSeek API Key | 团队核心驱动力 | 准备好 `sk-...` |
| 多模态 API Key | 视觉审查官看图（可选） | 千问/OpenAI 兼容 Key |

---

## 3. 一分钟部署

### Windows（任选一种终端）

**Git Bash：**
```bash
cd ~/.claude
bash install.sh
```

**PowerShell：**
```powershell
cd ~/.claude
powershell -ExecutionPolicy Bypass -File install.ps1
```

脚本会引导你做六件事：检查环境 → 复制代理配置 → 输入 API Key → 生成运行配置 → 初始化 git → 自检。

结束后重启终端，输入 `cgg` 启动团队。

---

## 4. 第一次对话

```
cgg
```

进入 Claude Code 后，试试这几句：

| 你说 | 团队反应 |
|------|----------|
| `你好` | 调度官直接回复，不启动子代理 |
| `帮我写一个计算器` | 启动项目负责人出规格书 → 你确认 → 码农写代码 → 审核官审查 → 调度官终审交付 |
| `这段代码有什么问题` | 调度官自行判断：简单就自己读文件回答，复杂就派审核官 |
| `帮我看看这张截图` | 派视觉审查官分析 |
| `有个 bug，日志在 xxx.log` | 派调试工程师定位根因 → 出修复报告 |

---

## 5. 团队成员速查

| 角色 | 一句话 | 擅长 |
|------|--------|------|
| **调度官** | 你自己对话的那个 | 理解需求、分流派活、质量终审 |
| **项目负责人** | 军师 | 需求分析、任务拆解、出中文规格书——不写代码 |
| **码农** | 主力输出 | 拿规格书写代码、自测、报告——不改测试文件 |
| **代码审核官** | 质检员 | 查代码质量/安全/规范——只看不改 |
| **调试工程师** | 侦探 | 复杂 bug 定位、根因分析、最小修复 |
| **视觉审查官** | 眼睛 | 看图/截图/PDF/UI——纯视觉分析 |

---

## 6. 工作流全景

```
你说 "帮我做一个登录页面"
         │
         ▼
    调度官 分流判断
    （直接回答？启动团队？模糊则问你）
         │
         ▼
    项目负责人 出规格书
    "需要3个文件：login.html / auth.js / style.css"
         │
    ◀── 你确认/调整
         │
         ▼
    码农 写代码（可多个并行）
         │
         ▼
    代码审核官 审查
    "致命1个：密码明文存localStorage"
         │
         ▼
    码农 修（或调度官驳回重做）
         │
         ▼
    调度官 终审 → 交付给你
```

---

## 7. 调度官的智能之处

### 自动分流
你说的话调度官会先分类——闲聊知识问答直接秒回，写代码改 bug 才启动团队。

### 犹豫时问你
调度官拿不准该派谁时，会给你 A/B 选项：
> "你是想做 A（启动项目负责人写规格书）还是 B（直接派码农试试）？"

你的选择会被记录到决策案例库，越用越准。

### 跨会话记忆
同一个项目目录下，调度官会自动读写 `PROJECT_MEMORY.md`。下次打开接着上次做，不丢上下文。

---

## 8. 目录结构

```
~/.claude/
├── settings.json              # 运行配置（API 端点、模型名）
├── settings.local.json        # 权限白名单
├── CLAUDE.md                  # 调度官规则（本地副本）
├── .gitignore                 # 密钥排除
├── install.sh                 # Bash 部署脚本
├── install.ps1                # PowerShell 部署脚本
├── USAGE.md                   # 本文件
├── agents/
│   ├── project-lead.md        # 项目负责人
│   ├── coder.md               # 码农
│   ├── debugger.md            # 调试工程师
│   ├── code-reviewer.md       # 代码审核官
│   └── visual-inspector.md    # 视觉审查官
└── .git/                      # 本地版本管理

~/CLAUDE.md                    # 调度官规则（全局入口）
```

---

## 9. 项目中的 PROJECT_MEMORY.md

在你做项目的目录里，调度官会自动维护一个 `PROJECT_MEMORY.md`：

```
## 2026-05-09 14:30 — 登录页面重构

### 需求
把老登录页改成 OAuth 2.0 流程

### 产出
- login.html（重写）
- auth.js（新增）
- 删除了 legacy/login_old.js

### 关键决策
- 用 PKCE 而不是 implicit flow，安全审核要求
- 不引入第三方库，纯 fetch

### 当前架构状态
登录 → auth.js → OAuth PKCE → 回调 → 主页面

### 未完成事项
- 令牌刷新逻辑还没写
- 错误页面 UI 待设计
```

下次打开项目，调度官会自动读取这个文件，接着上次做。

---

## 10. 常见问题

**Q: 启动 cgg 后连不上？**
检查 CC Switch 是否在运行（`http://127.0.0.1:15721`），DeepSeek API Key 是否已设为环境变量 `ANTHROPIC_AUTH_TOKEN`。

**Q: 视觉审查官不工作？**
检查 `OPENAI_API_KEY` 环境变量是否已设置，`~/.claude/settings.json` 中的 `OPENAI_BASE_URL` 是否正确。

**Q: 子代理被权限拒绝？**
检查 `~/.claude/settings.local.json` 的 `permissions.allow` 列表是否包含所需工具（至少需要 Edit 和 Write）。

**Q: 想换模型？**
编辑 `~/.claude/settings.json`，修改 `ANTHROPIC_MODEL` 等字段。CC Switch 会自动映射。

**Q: 怎么更新？**
```bash
cd ~/.claude
git pull   # 如果有远程仓库
# 或者重新运行 install.sh / install.ps1
```

---

## 11. 安全提醒

- `settings.json` 含有 API Key 占位符，已在 `.gitignore` 中排除，不会被提交
- API Key 建议通过系统环境变量注入（install 脚本自动处理）
- 每隔 90 天轮换一次 API Key
- 如果 Key 意外泄露到 git，立即到供应商后台 revoke，然后轮换新 Key

---

## 12. 进阶配置

### 切换多模态供应商

编辑 `~/.claude/settings.json`：

```json
"OPENAI_BASE_URL": "https://your-provider.com/v1",
"OPENAI_MODEL": "gpt-4o"
```

同步更新 `~/.claude/agents/visual-inspector.md` 的 `model` 字段。

### 自定义子代理行为

编辑 `~/.claude/agents/<角色>.md`，可调整：
- `maxTurns`：最大工作轮数
- `tools` / `disallowedTools`：工具权限
- 正文 Prompt：行为规则

---

部署完成？打开终端，输入 `cgg`，说一句"你好指挥官"。
