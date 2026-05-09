---
name: install-deepseek-team
description: >
  一键安装 DeepSeek 虚拟开发团队。克隆仓库后运行此 skill，自动部署全部 Agent、
  调度官规则和 API 配置模板。内置备份机制，已有配置不会被覆盖。
---

# 安装 DeepSeek 虚拟开发团队

## 你需要做什么

把这个仓库地址发给 Claude Code，说一句"帮我安装"：

```
https://github.com/2951617655-dotcom/deepseek-team
```

以下步骤 Claude Code 全自动完成。

## Claude Code 执行步骤

### 1. 克隆仓库（如果还没克隆）

```bash
git clone https://github.com/2951617655-dotcom/deepseek-team.git /tmp/deepseek-team-install
```

### 2. 运行安装脚本

**Windows：**
```bash
powershell -ExecutionPolicy Bypass -File C:\Users\<用户名>\deepseek-team\install.ps1
```

如果仓库在 `/tmp/deepseek-team-install`，则：
```bash
powershell -ExecutionPolicy Bypass -File /tmp/deepseek-team-install/install.ps1
```

**Linux / macOS：**
```bash
bash install.sh
```

### 3. 安装完成后引导用户

安装脚本完成后，向用户输出以下引导信息：

> 安装完成！接下来：
> 1. 编辑 `~/.claude/settings.json`，把占位符换成你的 API Key
> 2. 终端输入 `cgg` 启动
> 3. 说一句"你好指挥官"，团队激活

### 4. 如果 settings.json 已存在

不要覆盖已有配置。单独提醒用户检查 settings.json 是否包含多模态 API Key（OPENAI_API_KEY / OPENAI_BASE_URL / OPENAI_MODEL），缺少则手动补充。

## 验证安装

安装完成后运行：

```bash
ls ~/.claude/agents/
```

应该看到：
- `project-lead-agent.md`
- `coder-agent.md`
- `code-reviewer-agent.md`
- `debugger-agent.md`
- `visual-inspector.md`
- `task-schema.md`

以及 `~/.claude/agents/custom/` 目录已创建（为空，供自定义角色使用）。

## 注意事项

- 安装脚本会自动备份已有 Agent 文件，不会丢失旧配置
- 已有 `settings.json` 不会被覆盖
- 自定义角色目录 `~/.claude/agents/custom/` 会自动创建
