#!/bin/bash
# ==============================================================
#  DeepSeekTeam 虚拟开发团队 — 一键部署脚本 (Git Bash / WSL)
#  用法: bash install.sh
#  效果: 5 分钟从零到可用的虚拟开发团队
# ==============================================================
set -e

# ---- 颜色定义 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

banner() {
  echo ""
  echo -e "${CYAN}============================================${NC}"
  echo -e "${CYAN}   DeepSeekTeam 虚拟开发团队 — 部署向导${NC}"
  echo -e "${CYAN}============================================${NC}"
  echo ""
}

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

banner

# ==============================================================
# 第 1 步：环境检查
# ==============================================================
echo -e "${CYAN}[1/6]${NC} 检查环境..."

# 检查 bash 版本
if [ -z "$BASH_VERSION" ]; then
  fail "需要 bash 环境运行，请在 Git Bash 或 WSL 中执行"
  exit 1
fi
ok "bash 环境就绪"

# 检查 cgg
if ! command -v cgg &>/dev/null && ! command -v claude &>/dev/null; then
  warn "未检测到 cgg / claude 命令"
  info "正在尝试安装 Claude Code CGG..."
  if command -v npm &>/dev/null; then
    npm install -g claude-code-cgg && ok "cgg 安装成功" || {
      fail "cgg 安装失败，请手动执行: npm install -g claude-code-cgg"
      exit 1
    }
  else
    fail "需要 npm 环境，请先安装 Node.js"
    exit 1
  fi
else
  ok "cgg / claude 命令可用"
fi

# 检查 git
if command -v git &>/dev/null; then
  ok "git 可用"
  HAS_GIT=true
else
  warn "git 不可用，将跳过版本管理初始化"
  HAS_GIT=false
fi

# ==============================================================
# 第 2 步：确定脚本路径（从哪里复制文件）
# ==============================================================
echo ""
echo -e "${CYAN}[2/6]${NC} 定位部署文件..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "脚本目录: $SCRIPT_DIR"

# 检查必要的源文件
NEED_FILES=(
  "agents/project-lead.md"
  "agents/coder.md"
  "agents/debugger.md"
  "agents/code-reviewer.md"
  "agents/visual-inspector.md"
  "CLAUDE.md"
  "settings.local.json"
  ".gitignore"
)

MISSING=()
for f in "${NEED_FILES[@]}"; do
  if [ ! -f "$SCRIPT_DIR/$f" ]; then
    MISSING+=("$f")
  fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
  fail "缺少以下部署文件："
  for m in "${MISSING[@]}"; do
    echo "       - $m"
  done
  echo ""
  info "请确保在 DeepSeekTeam 项目根目录（包含 agents/ 和 CLAUDE.md 的目录）中运行本脚本"
  exit 1
fi
ok "部署文件完整 ($((${#NEED_FILES[@]})) 个)"

# ==============================================================
# 第 3 步：创建目录 + 复制文件
# ==============================================================
echo ""
echo -e "${CYAN}[3/6]${NC} 部署文件..."

CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"

mkdir -p "$AGENTS_DIR"

# 复制代理配置
cp "$SCRIPT_DIR/agents/"*.md "$AGENTS_DIR/"
ok "5 个代理配置 → $AGENTS_DIR/"

# 复制 CLAUDE.md 到用户主目录（供 Claude Code 读取）
cp "$SCRIPT_DIR/CLAUDE.md" "$HOME/CLAUDE.md"
ok "调度官规则 → $HOME/CLAUDE.md"

# 复制 CLAUDE.md 到 .claude/（本地配置）—— 跳过自复制
if [ "$SCRIPT_DIR/CLAUDE.md" != "$CLAUDE_DIR/CLAUDE.md" ]; then
  cp "$SCRIPT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
fi

# 复制权限白名单
cp "$SCRIPT_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json"
ok "权限白名单 → $CLAUDE_DIR/settings.local.json"

# 复制 .gitignore
cp "$SCRIPT_DIR/.gitignore" "$CLAUDE_DIR/.gitignore"
ok "版本忽略规则 → $CLAUDE_DIR/.gitignore"

# ==============================================================
# 第 4 步：交互式配置 API Key
# ==============================================================
echo ""
echo -e "${CYAN}[4/6]${NC} 配置 API 密钥"
echo ""
echo -e "  团队需要两个 API Key："
echo -e "  ${YELLOW}① DeepSeek API Key${NC} — 代码生成与调度核心（必填）"
echo -e "  ${YELLOW}② 多模态 API Key${NC}   — 视觉审查官看图用（可选）"
echo ""

# --- DeepSeek Key ---
while true; do
  read -r -p "  请输入 DeepSeek API Key (sk-...): " DEEPSEEK_KEY
  if [ -n "$DEEPSEEK_KEY" ]; then
    break
  fi
  warn "DeepSeek Key 为必填项，团队离开它无法工作"
done

# 写入 Windows 环境变量（永久存储）
if command -v setx &>/dev/null; then
  setx ANTHROPIC_AUTH_TOKEN "$DEEPSEEK_KEY" > /dev/null 2>&1
  ok "DeepSeek Key 已写入系统环境变量"
else
  # WSL / Linux fallback
  echo "export ANTHROPIC_AUTH_TOKEN=\"$DEEPSEEK_KEY\"" >> "$HOME/.bashrc"
  ok "DeepSeek Key 已写入 ~/.bashrc"
fi
export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_KEY"

# --- 多模态 Key ---
echo ""
read -r -p "  请输入多模态 API Key (留空跳过): " MULTIMODAL_KEY

if [ -n "$MULTIMODAL_KEY" ]; then
  if command -v setx &>/dev/null; then
    setx OPENAI_API_KEY "$MULTIMODAL_KEY" > /dev/null 2>&1
    ok "多模态 Key 已写入系统环境变量"
  else
    echo "export OPENAI_API_KEY=\"$MULTIMODAL_KEY\"" >> "$HOME/.bashrc"
    ok "多模态 Key 已写入 ~/.bashrc"
  fi
  export OPENAI_API_KEY="$MULTIMODAL_KEY"
else
  warn "多模态 Key 已跳过（视觉审查官将不可用）"
fi

# ==============================================================
# 第 5 步：生成 settings.json
# ==============================================================
echo ""
echo -e "${CYAN}[5/6]${NC} 生成配置文件..."

cat > "$CLAUDE_DIR/settings.json" << 'SETEOF'
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
SETEOF
ok "settings.json 已生成（密钥由环境变量注入，文件内无明文 Key）"

# ==============================================================
# 第 6 步：初始化 git 仓库 + 自检
# ==============================================================
echo ""
echo -e "${CYAN}[6/6]${NC} 初始化版本管理 & 自检..."

if [ "$HAS_GIT" = true ]; then
  cd "$CLAUDE_DIR"
  if [ ! -d .git ]; then
    git init && \
    git config user.email "dev@deepseek-team.local" && \
    git config user.name "DeepSeek Team" && \
    git add .gitignore agents/ settings.local.json CLAUDE.md && \
    git commit -m "初始化 DeepSeekTeam 部署" && \
    ok "git 仓库已初始化并创建初始提交"
  else
    ok "git 仓库已存在，跳过初始化"
  fi
  cd "$OLDPWD"
fi

# 自检：列出已部署文件
echo ""
info "已部署文件清单："
echo ""
echo "  ~/.claude/"
echo "  ├── settings.json          # 运行配置"
echo "  ├── settings.local.json    # 权限白名单"
echo "  ├── CLAUDE.md              # 调度官规则（本地）"
echo "  ├── .gitignore             # 密钥排除规则"
echo "  ├── agents/"
echo "  │   ├── project-lead.md    # 项目负责人"
echo "  │   ├── coder.md           # 码农"
echo "  │   ├── debugger.md        # 调试工程师"
echo "  │   ├── code-reviewer.md   # 代码审核官"
echo "  │   └── visual-inspector.md # 视觉审查官"
echo "  └── .git/                  # 版本管理"
echo ""
echo "  ~/CLAUDE.md                # 调度官规则（全局）"
echo ""

# ==============================================================
# 完成
# ==============================================================
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  部署完成！${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${YELLOW}重要${NC}：请重启 Claude Code 终端以使环境变量生效"
echo ""
echo -e "  启动团队：在终端输入 ${CYAN}cgg${NC}"
echo -e "  开始协作：对团队说 ${CYAN}你好指挥官${NC}"
echo ""
echo -e "  如需重新配置 API Key，再次运行本脚本即可"
echo ""
