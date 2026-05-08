# 更新日志

## 2026-05-08

### 架构升级

- **Claude Code CGG 多模型协作**：从单一 DeepSeek 升级为多供应商架构。主会话走 DeepSeek，视觉审查官独立走多模态模型（千问/GPT/Claude/Gemini 可选）
- **五层团队**：新增调试工程师（v4-pro，复杂 bug 定位 + 最小修复）和视觉审查官（多模态，截图/UI/PDF 分析）

### 调度官行为规则新增

- **消息分流判断**：用户消息先分类再行动——闲聊/知识问答直接回复，代码任务/图片分析启动团队
- **调度官禁区**：视觉审查官失败时不得自行看图（越权），失败报告用户等指令
- **派发后守则**：派完任务立刻回用户对话 + 列出运行中代理看板 + 继续对接

### 码农（coder-agent.md）

- **分体式码农**：核心升级——flash 做双手，每次编码前 spawn 一个 pro 子代理（大脑）输出 Edit 指令清单，双手只负责执行
- 新增 Agent 工具权限（用于 spawn 大脑子代理）
- Edit 匹配失败最多重试 2 次，全败上报调度官
- 报告格式改为「大脑给哪些指令 + 执行情况」

### 项目负责人（project-lead-agent.md）

- 规格书模板全面升级：背景与目标 → 影响范围 → 技术方案 → 任务拆解 → 逐任务详述（含输入输出/边界/不可做）→ 验收标准 → 风险提示
- 文件路径必须来自实际 Grep/Glob，不凭空想象
- 每次输出附摘要：共 N 个任务，预估总行数 M，涉及 K 个文件

### 审核官（code-reviewer-agent.md）

- git diff 策略优化：先收集未 staged 变更，再收集 staged，合并两份集合避免遗漏
- 语言锚定升级为三段式：审什么 / 关注什么风险 / 不确定什么

### 新增文件

- `settings.example.json`：API Key 配置模板，含全部占位符
- `agents/debugger-agent.md`：调试工程师 agent 定义
- `agents/visual-inspector.md`：视觉审查官 agent 定义（provider: openai, model: qwen3-vl-flash）

### 新用户引导

- CLAUDE.md 新增「多模态供应商配置」章节：调度官主动询问用户 API Key、Base URL、模型名，自动写入 settings.json
