# ==============================================================
#  DeepSeekTeam 虚拟开发团队 — 一键部署脚本 (PowerShell)
#  用法: powershell -ExecutionPolicy Bypass -File install.ps1
#  效果: 5 分钟从零到可用的虚拟开发团队
# ==============================================================
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# ---- 颜色函数 ----
function Write-Banner {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   DeepSeekTeam 虚拟开发团队 — 部署向导" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-OK   { Write-Host "  ✓ " -NoNewline -ForegroundColor Green; Write-Host $args[0] }
function Write-Warn { Write-Host "  ⚠ " -NoNewline -ForegroundColor Yellow; Write-Host $args[0] }
function Write-Fail { Write-Host "  ✗ " -NoNewline -ForegroundColor Red; Write-Host $args[0] }
function Write-Info { Write-Host "  → " -NoNewline -ForegroundColor Cyan; Write-Host $args[0] }

Write-Banner

# ==============================================================
# 第 1 步：环境检查
# ==============================================================
Write-Host "[1/6] 检查环境..." -ForegroundColor Cyan

# 检查 PowerShell 版本（需要 5.1+ 或 PowerShell Core 6+）
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Fail "需要 PowerShell 5.1 或更高版本"
    exit 1
}
Write-OK "PowerShell $($PSVersionTable.PSVersion) 就绪"

# 检查 cgg
$cggCmd = $null
if (Get-Command cgg -ErrorAction SilentlyContinue) {
    $cggCmd = "cgg"
} elseif (Get-Command claude -ErrorAction SilentlyContinue) {
    $cggCmd = "claude"
}

if (-not $cggCmd) {
    Write-Warn "未检测到 cgg / claude 命令"
    Write-Info "正在尝试安装 Claude Code CGG..."
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        npm install -g claude-code-cgg
        if ($LASTEXITCODE -eq 0) {
            Write-OK "cgg 安装成功"
        } else {
            Write-Fail "cgg 安装失败，请手动执行: npm install -g claude-code-cgg"
            exit 1
        }
    } else {
        Write-Fail "需要 npm 环境，请先安装 Node.js"
        exit 1
    }
} else {
    Write-OK "cgg / claude 命令可用"
}

# 检查 git
$hasGit = $false
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-OK "git 可用"
    $hasGit = $true
} else {
    Write-Warn "git 不可用，将跳过版本管理初始化"
}

# ==============================================================
# 第 2 步：确定脚本路径
# ==============================================================
Write-Host ""
Write-Host "[2/6] 定位部署文件..." -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Info "脚本目录: $ScriptDir"

# 检查必要的源文件
$needFiles = @(
    "agents/project-lead.md",
    "agents/coder.md",
    "agents/debugger.md",
    "agents/code-reviewer.md",
    "agents/visual-inspector.md",
    "CLAUDE.md",
    "settings.local.json",
    ".gitignore"
)

$missing = @()
foreach ($f in $needFiles) {
    if (-not (Test-Path (Join-Path $ScriptDir $f))) {
        $missing += $f
    }
}

if ($missing.Count -gt 0) {
    Write-Fail "缺少以下部署文件："
    foreach ($m in $missing) {
        Write-Host "       - $m"
    }
    Write-Host ""
    Write-Info "请确保在 DeepSeekTeam 项目根目录（包含 agents/ 和 CLAUDE.md 的目录）中运行本脚本"
    exit 1
}
Write-OK "部署文件完整 ($($needFiles.Count) 个)"

# ==============================================================
# 第 3 步：创建目录 + 复制文件
# ==============================================================
Write-Host ""
Write-Host "[3/6] 部署文件..." -ForegroundColor Cyan

$ClaudeDir = "$env:USERPROFILE\.claude"
$AgentsDir = "$ClaudeDir\agents"

# 确保父目录存在（-Force 递归创建，但显式创建更清晰）
New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null

# 复制代理配置
Copy-Item (Join-Path $ScriptDir "agents\*.md") -Destination $AgentsDir -Force
Write-OK "5 个代理配置 → $AgentsDir\"

# 复制 CLAUDE.md 到用户主目录
Copy-Item (Join-Path $ScriptDir "CLAUDE.md") -Destination "$env:USERPROFILE\CLAUDE.md" -Force
Write-OK "调度官规则 → $env:USERPROFILE\CLAUDE.md"

# 复制 CLAUDE.md 到 .claude/（本地配置）
Copy-Item (Join-Path $ScriptDir "CLAUDE.md") -Destination "$ClaudeDir\CLAUDE.md" -Force -ErrorAction SilentlyContinue
# 如果上一步失败（同源同目标），静默跳过

# 复制权限白名单
Copy-Item (Join-Path $ScriptDir "settings.local.json") -Destination "$ClaudeDir\settings.local.json" -Force
Write-OK "权限白名单 → $ClaudeDir\settings.local.json"

# 复制 .gitignore
Copy-Item (Join-Path $ScriptDir ".gitignore") -Destination "$ClaudeDir\.gitignore" -Force
Write-OK "版本忽略规则 → $ClaudeDir\.gitignore"

# ==============================================================
# 第 4 步：交互式配置 API Key
# ==============================================================
Write-Host ""
Write-Host "[4/6] 配置 API 密钥" -ForegroundColor Cyan
Write-Host ""
Write-Host "  团队需要两个 API Key："
Write-Host "  ① DeepSeek API Key — 代码生成与调度核心（必填）" -ForegroundColor Yellow
Write-Host "  ② 多模态 API Key   — 视觉审查官看图用（可选）" -ForegroundColor Yellow
Write-Host ""

# --- DeepSeek Key ---
do {
    $deepseekKey = Read-Host -Prompt "  请输入 DeepSeek API Key (sk-...)"
    if ([string]::IsNullOrWhiteSpace($deepseekKey)) {
        Write-Warn "DeepSeek Key 为必填项，团队离开它无法工作"
    }
} while ([string]::IsNullOrWhiteSpace($deepseekKey))

# 写入 Windows 环境变量（永久存储）
try {
    [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $deepseekKey, "User")
    Write-OK "DeepSeek Key 已写入用户环境变量"
} catch {
    Write-Warn "无法写入用户环境变量，尝试写入机器环境变量..."
    try {
        [Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $deepseekKey, "Machine")
        Write-OK "DeepSeek Key 已写入机器环境变量"
    } catch {
        Write-Fail "环境变量写入失败，请手动设置 ANTHROPIC_AUTH_TOKEN"
    }
}
$env:ANTHROPIC_AUTH_TOKEN = $deepseekKey

# --- 多模态 Key ---
Write-Host ""
$multimodalKey = Read-Host -Prompt "  请输入多模态 API Key (留空跳过)"

if (-not [string]::IsNullOrWhiteSpace($multimodalKey)) {
    try {
        [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $multimodalKey, "User")
        Write-OK "多模态 Key 已写入用户环境变量"
    } catch {
        try {
            [Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $multimodalKey, "Machine")
            Write-OK "多模态 Key 已写入机器环境变量"
        } catch {
            Write-Fail "环境变量写入失败，请手动设置 OPENAI_API_KEY"
        }
    }
    $env:OPENAI_API_KEY = $multimodalKey
} else {
    Write-Warn "多模态 Key 已跳过（视觉审查官将不可用）"
}

# ==============================================================
# 第 5 步：生成 settings.json
# ==============================================================
Write-Host ""
Write-Host "[5/6] 生成配置文件..." -ForegroundColor Cyan

$settingsJson = @'
{
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "",
    "ANTHROPIC_BASE_URL": "http://127.0.0.1:15721",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-v4-flash",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_REASONING_MODEL": "deepseek-v4-pro",
    "OPENAI_BASE_URL": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "OPENAI_MODEL": "qwen3-vl-flash"
  },
  "theme": "auto",
  "includeCoAuthoredBy": false
}
'@

$settingsJson | Set-Content -Path "$ClaudeDir\settings.json" -Encoding UTF8
Write-OK "settings.json 已生成（密钥由环境变量注入，文件内无明文 Key）"

# ==============================================================
# 第 6 步：初始化 git 仓库 + 自检
# ==============================================================
Write-Host ""
Write-Host "[6/6] 初始化版本管理 & 自检..." -ForegroundColor Cyan

if ($hasGit) {
    Push-Location $ClaudeDir
    if (-not (Test-Path ".git")) {
        git init 2>&1 | Out-Null
        git config user.email "dev@deepseek-team.local" 2>&1 | Out-Null
        git config user.name "DeepSeek Team" 2>&1 | Out-Null
        git add .gitignore agents/ settings.local.json CLAUDE.md 2>&1 | Out-Null
        git commit -m "初始化 DeepSeekTeam 部署" 2>&1 | Out-Null
        Write-OK "git 仓库已初始化并创建初始提交"
    } else {
        Write-OK "git 仓库已存在，跳过初始化"
    }
    Pop-Location
}

# 自检：列出已部署文件
Write-Host ""
Write-Info "已部署文件清单："
Write-Host ""
Write-Host "  ~/.claude/"
Write-Host "  ├── settings.json          # 运行配置"
Write-Host "  ├── settings.local.json    # 权限白名单"
Write-Host "  ├── CLAUDE.md              # 调度官规则（本地）"
Write-Host "  ├── .gitignore             # 密钥排除规则"
Write-Host "  ├── agents/"
Write-Host "  │   ├── project-lead.md    # 项目负责人"
Write-Host "  │   ├── coder.md           # 码农"
Write-Host "  │   ├── debugger.md        # 调试工程师"
Write-Host "  │   ├── code-reviewer.md   # 代码审核官"
Write-Host "  │   └── visual-inspector.md # 视觉审查官"
Write-Host "  └── .git/                  # 版本管理"
Write-Host ""
Write-Host "  ~/CLAUDE.md                # 调度官规则（全局）"
Write-Host ""

# ==============================================================
# 完成
# ==============================================================
Write-Host "============================================" -ForegroundColor Green
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  重要：请重启 Claude Code 终端以使环境变量生效" -ForegroundColor Yellow
Write-Host ""
Write-Host "  启动团队：在终端输入 cgg" -ForegroundColor Cyan
Write-Host "  开始协作：对团队说 你好指挥官" -ForegroundColor Cyan
Write-Host ""
Write-Host "  如需重新配置 API Key，再次运行本脚本即可"
Write-Host ""
