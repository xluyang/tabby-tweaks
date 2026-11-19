<#
.SYNOPSIS
    恢复出厂设置：先备份当前配置，再用本仓库的 config.yaml.orig（客制化前的原始配置）覆盖。
    与 deploy.ps1 对称，同样拦截运行中的 Tabby。

.EXAMPLE
    pwsh -File .\scripts\restore.ps1
    pwsh -File .\scripts\restore.ps1 -ConfigDir "D:\tabby-data"
    pwsh -File .\scripts\restore.ps1 -Force
#>
[CmdletBinding()]
param(
    [string]$ConfigDir,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repo 'config.yaml.orig'

if (-not (Test-Path $source)) { throw "找不到原始配置: $source" }

# 1) 目标配置目录 —— 默认 %APPDATA%\tabby
if (-not $ConfigDir) {
    $ConfigDir = Join-Path $env:APPDATA 'tabby'
}
$ConfigDir = [Environment]::ExpandEnvironmentVariables($ConfigDir)
$target = Join-Path $ConfigDir 'config.yaml'

# 2) 拦截运行中的 Tabby
$procs = @(Get-Process -Name 'Tabby' -ErrorAction SilentlyContinue)
if ($procs.Count -gt 0) {
    Write-Host "[restore] 检测到 $($procs.Count) 个 Tabby 进程正在运行。" -ForegroundColor Red
    Write-Host "[restore] 请先完全退出 Tabby（含托盘图标）再恢复。" -ForegroundColor Red
    throw 'Tabby 仍在运行，已中止恢复。'
}

# 3) 备份当前（客制化）配置，方便反悔
if (Test-Path -LiteralPath $target) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $ConfigDir "config.yaml.before-restore-$stamp"
    Copy-Item -LiteralPath $target -Destination $backup
    Write-Host "[restore] 已备份当前配置 -> $backup" -ForegroundColor DarkGray
}

# 4) 确认
if (-not $Force) {
    Write-Host "[restore] 即将恢复出厂配置到: $target" -ForegroundColor Cyan
    Write-Host '[restore] 这会清除所有快捷键与外观客制化。' -ForegroundColor Yellow
    $ans = Read-Host '确认继续? [Y/n]'
    if ($ans -and $ans -notmatch '^[Yy]$') {
        Write-Host '[restore] 已取消。' -ForegroundColor Yellow
        exit 0
    }
}

# 5) 恢复
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host "[restore] 已恢复出厂配置: $target" -ForegroundColor Green
Write-Host '[restore] 启动 Tabby 即可生效。' -ForegroundColor Yellow
Write-Host '[restore] 想重新启用客制化，运行 deploy.ps1（当前配置已备份，可找回）。' -ForegroundColor DarkGray
