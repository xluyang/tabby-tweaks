<#
.SYNOPSIS
    部署 Tabby 客制化配置：先备份当前配置，再把本仓库的 config.yaml 部署到 Tabby。
    会检测 Tabby 是否运行；运行时拒绝部署（Tabby 退出时会用内存旧配置覆盖磁盘文件）。

.EXAMPLE
    pwsh -File .\scripts\deploy.ps1
    pwsh -File .\scripts\deploy.ps1 -ConfigDir "D:\tabby-data"
    pwsh -File .\scripts\deploy.ps1 -Force
#>
[CmdletBinding()]
param(
    [string]$ConfigDir,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repo 'config.yaml'

if (-not (Test-Path $source)) { throw "找不到源配置: $source" }

# 1) 目标配置目录 —— 默认 %APPDATA%\tabby
if (-not $ConfigDir) {
    $ConfigDir = Join-Path $env:APPDATA 'tabby'
}
$ConfigDir = [Environment]::ExpandEnvironmentVariables($ConfigDir)
$target = Join-Path $ConfigDir 'config.yaml'

# 2) 拦截运行中的 Tabby（关键：运行时部署会被内存配置覆盖）
$procs = @(Get-Process -Name 'Tabby' -ErrorAction SilentlyContinue)
if ($procs.Count -gt 0) {
    Write-Host "[deploy] 检测到 $($procs.Count) 个 Tabby 进程正在运行。" -ForegroundColor Red
    Write-Host "[deploy] 请先完全退出 Tabby（含托盘图标）再部署，否则改动会被覆盖。" -ForegroundColor Red
    throw 'Tabby 仍在运行，已中止部署。'
}

# 3) 备份当前配置（存在才备份）
if (Test-Path -LiteralPath $target) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $ConfigDir "config.yaml.bak-$stamp"
    Copy-Item -LiteralPath $target -Destination $backup
    Write-Host "[deploy] 已备份当前配置 -> $backup" -ForegroundColor DarkGray
} else {
    Write-Host "[deploy] 目标配置不存在，跳过备份（首次部署）" -ForegroundColor DarkGray
}

# 4) 确认
if (-not $Force) {
    Write-Host "[deploy] 即将部署客制化配置到: $target" -ForegroundColor Cyan
    $ans = Read-Host '确认继续? [Y/n]'
    if ($ans -and $ans -notmatch '^[Yy]$') {
        Write-Host '[deploy] 已取消。' -ForegroundColor Yellow
        exit 0
    }
}

# 5) 部署
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host "[deploy] 部署完成: $target" -ForegroundColor Green
Write-Host '[deploy] 启动 Tabby 即可生效。' -ForegroundColor Yellow
