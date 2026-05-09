#!/usr/bin/env bash
# DeepSeek Team 一键安装脚本 (Linux / macOS / Git Bash)
# 用法：cd deepseek-team && bash install.sh

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${CYAN}  DeepSeek 虚拟开发团队 — 一键安装${NC}"
echo -e "${CYAN}========================================${NC}\n"

# 1. 检测目标目录
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
CUSTOM_DIR="$AGENTS_DIR/custom"
SOURCE_DIR="$(cd "$(dirname "$0")/agents" && pwd)"

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}[错误] 找不到 agents 目录，请确保在 deepseek-team 仓库根目录运行此脚本${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] 创建目录结构...${NC}"
mkdir -p "$AGENTS_DIR"
mkdir -p "$CUSTOM_DIR"
echo -e "${GREEN}   ✓  ~/.claude/agents/     已就绪${NC}"
echo -e "${GREEN}   ✓  ~/.claude/agents/custom/  已就绪（自定义角色用）${NC}"

# 2. 备份旧文件
echo -e "\n${YELLOW}[2/5] 检查已有文件...${NC}"
BACKUP_DIR="$CLAUDE_DIR/backup_$(date +%Y%m%d_%H%M%S)"
HAS_BACKUP=false

for file in "$SOURCE_DIR"/*; do
    fname=$(basename "$file")
    target="$AGENTS_DIR/$fname"
    if [ -f "$target" ]; then
        if [ "$HAS_BACKUP" = false ]; then
            mkdir -p "$BACKUP_DIR"
            HAS_BACKUP=true
        fi
        cp "$target" "$BACKUP_DIR/$fname"
        echo -e "   → 已备份: $fname"
    fi
done

if [ "$HAS_BACKUP" = true ]; then
    echo -e "${GREEN}   ✓  旧文件已备份到: $BACKUP_DIR${NC}"
else
    echo -e "${GREEN}   ✓  无需备份（首次安装）${NC}"
fi

# 3. 复制 Agent 文件
echo -e "\n${YELLOW}[3/5] 安装 Agent 文件...${NC}"
count=0
for file in "$SOURCE_DIR"/*; do
    cp "$file" "$AGENTS_DIR/"
    fname=$(basename "$file")
    echo -e "${GREEN}   ✓  $fname${NC}"
    count=$((count + 1))
done
echo -e "${GREEN}   ✓  共安装 $count 个 Agent${NC}"

# 4. 部署调度官配置
echo -e "\n${YELLOW}[4/5] 部署调度官配置...${NC}"
CLAUDE_MD="$HOME/CLAUDE.md"
CLAUDE_EXAMPLE="$(cd "$(dirname "$0")" && pwd)/CLAUDE.md.example"

if [ -f "$CLAUDE_MD" ]; then
    BACKUP_PATH="$HOME/CLAUDE.md.backup_$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_MD" "$BACKUP_PATH"
    echo -e "${YELLOW}   → 已有 CLAUDE.md 已备份到: $BACKUP_PATH${NC}"
fi
cp "$CLAUDE_EXAMPLE" "$CLAUDE_MD"
echo -e "${GREEN}   ✓  CLAUDE.md 已安装（全局调度官规则）${NC}"

# 5. 配置 API Key
echo -e "\n${YELLOW}[5/5] 配置 API Key...${NC}"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
SETTINGS_EXAMPLE="$(cd "$(dirname "$0")" && pwd)/settings.example.json"

if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${YELLOW}   → settings.json 已存在，跳过（不覆盖已有配置）${NC}"
    echo -e "${YELLOW}   → 如需重新配置，请手动编辑: $SETTINGS_FILE${NC}"
else
    cp "$SETTINGS_EXAMPLE" "$SETTINGS_FILE"
    echo -e "${GREEN}   ✓  settings.json 已创建（含占位符）${NC}"
fi

# 完成
echo -e "\n${CYAN}========================================${NC}"
echo -e "${GREEN}  安装完成！${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "\n${NC}下一步：${NC}"
echo -e "${YELLOW}  1. 编辑 $SETTINGS_FILE${NC}"
echo -e "     填入你的 DeepSeek API Key 和多模态 API Key"
echo -e "${YELLOW}  2. 启动 Claude Code：${NC}"
echo -e "     ${CYAN}cgg${NC}"
echo -e "${YELLOW}  3. 说一句${NC}\"你好指挥官\"${YELLOW}测试团队是否正常启动${NC}\n"
echo -e "${NC}如需自定义角色，将角色文件放入: $CUSTOM_DIR${NC}"
echo -e "详细文档: https://github.com/2951617655-dotcom/deepseek-team\n"
