# DeepSeek Team 一键安装脚本 (Windows PowerShell)
# 用法：在 deepseek-team 目录下，右键 → "使用 PowerShell 运行"
# 或：powershell -ExecutionPolicy Bypass -File install.ps1

$ErrorActionPreference = "Stop"
Write-Host "`n  DeepSeek 虚拟开发团队 — 一键安装" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. 检测目标目录
$ClaudeDir = "$env:USERPROFILE\.claude"
$AgentsDir = "$ClaudeDir\agents"
$CustomDir = "$AgentsDir\custom"
$SourceDir = "$PSScriptRoot\agents"

if (-not (Test-Path $SourceDir)) {
    Write-Host "[错误] 找不到 agents 目录，请确保在 deepseek-team 仓库根目录运行此脚本" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] 创建目录结构..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $CustomDir | Out-Null
Write-Host "   ✓  ~\.claude\agents\     已就绪" -ForegroundColor Green
Write-Host "   ✓  ~\.claude\agents\custom\  已就绪（自定义角色用）" -ForegroundColor Green

# 2. 备份旧文件（如果存在）
Write-Host "`n[2/5] 检查已有文件..." -ForegroundColor Yellow
$BackupDir = "$ClaudeDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$hasBackup = $false

foreach ($file in Get-ChildItem $SourceDir -File) {
    $target = Join-Path $AgentsDir $file.Name
    if (Test-Path $target) {
        if (-not $hasBackup) {
            New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
            $hasBackup = $true
        }
        Copy-Item $target "$BackupDir\$($file.Name)"
        Write-Host "   → 已备份: $($file.Name)"
    }
}
if ($hasBackup) {
    Write-Host "   ✓  旧文件已备份到: $BackupDir" -ForegroundColor Green
} else {
    Write-Host "   ✓  无需备份（首次安装）" -ForegroundColor Green
}

# 3. 复制 Agent 文件
Write-Host "`n[3/5] 安装 Agent 文件..." -ForegroundColor Yellow
$count = 0
foreach ($file in Get-ChildItem $SourceDir -File) {
    Copy-Item $file.FullName $AgentsDir -Force
    $name = $file.Name
    Write-Host "   ✓  $name" -ForegroundColor Green
    $count++
}
Write-Host "   ✓  共安装 $count 个 Agent" -ForegroundColor Green

# 4. 部署调度官配置
Write-Host "`n[4/5] 部署调度官配置..." -ForegroundColor Yellow
$ClaudeMD = "$env:USERPROFILE\CLAUDE.md"
$ClaudeExample = "$PSScriptRoot\CLAUDE.md.example"

if (Test-Path $ClaudeMD) {
    $backupPath = "$env:USERPROFILE\CLAUDE.md.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $ClaudeMD $backupPath
    Write-Host "   → 已有 CLAUDE.md 已备份到: $backupPath" -ForegroundColor Yellow
}
Copy-Item $ClaudeExample $ClaudeMD -Force
Write-Host "   ✓  CLAUDE.md 已安装（全局调度官规则）" -ForegroundColor Green

# 5. 配置 API Key
Write-Host "`n[5/5] 配置 API Key..." -ForegroundColor Yellow
$SettingsFile = "$ClaudeDir\settings.json"
$SettingsExample = "$PSScriptRoot\settings.example.json"

if (Test-Path $SettingsFile) {
    Write-Host "   → settings.json 已存在，跳过（不覆盖已有配置）" -ForegroundColor Yellow
    Write-Host "   → 如需重新配置，请手动编辑: $SettingsFile" -ForegroundColor Yellow
} else {
    Copy-Item $SettingsExample $SettingsFile
    Write-Host "   ✓  settings.json 已创建（含占位符）" -ForegroundColor Green
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  安装完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n下一步：" -ForegroundColor White
Write-Host "  1. 编辑 $SettingsFile" -ForegroundColor Yellow
Write-Host "     填入你的 DeepSeek API Key 和多模态 API Key" -ForegroundColor White
Write-Host "  2. 启动 Claude Code：" -ForegroundColor Yellow
Write-Host "     cgg" -ForegroundColor White
Write-Host "  3. 说一句"你好指挥官"测试团队是否正常启动`n" -ForegroundColor White
Write-Host "如需自定义角色，将角色文件放入: $CustomDir" -ForegroundColor Gray
Write-Host "详细文档: https://github.com/2951617655-dotcom/deepseek-team`n" -ForegroundColor Gray
