# Tabby 终端客制化配置备份

本目录备份 Tabby 终端（Windows，v1.0.237）的快捷键与外观客制化配置，便于版本管理、迁移与回滚。

## 文件说明

| 文件 | 说明 |
|---|---|
| `config.yaml` | **当前生效版**：Windows Terminal 风格快捷键 + 药丸形圆角标签 + tmux 风格分割线 + 隐藏滚动条 |
| `config.yaml.orig` | **原始版**：本机 Tabby 首次客制化前的配置（仅作回滚参考） |

Tabby 实际读取的配置路径为 `%APPDATA%\tabby\config.yaml`（Windows）。

## 客制化内容清单

### 1. 快捷键（Windows Terminal 风格）—— `hotkeys:`

| 功能 | 原键位 | 现键位 |
|---|---|---|
| 向右分屏 | `Ctrl+Shift+S` | `Alt+Shift+=` / `Alt+Shift+D` |
| 向下分屏 | `Ctrl+Shift+D` | `Alt+Shift+-` |
| 窗格跳转 ←↑↓→ | `Ctrl+Alt+方向键` | `Alt+方向键` |
| 上一/下一窗格 | `Ctrl+Alt+[` `]` | `Alt+[` `]` |
| 左右分屏调宽/窄 | 无 | `Alt+Shift+→` / `Alt+Shift+←` |
| 上下分屏调高/矮 | 无 | `Alt+Shift+↓` / `Alt+Shift+↑` |
| 调节步进 `paneResizeStep` | 默认 `0.1` | `0.05` |

> 注：`Alt+Shift` 在部分 Windows 多语言环境下可能与输入法切换冲突；`Alt+Shift+=` 更可靠。

### 2. 外观（CSS 注入）—— `appearance.css`

通过 `appearance.css` 配置项直接内嵌 CSS（Tabby 注入到 `<style id="custom-css">`，优先级高于主题默认样式）：

- **隐藏终端滚动条**：`.xterm-viewport` 及 webkit 滚动条设为 0 宽 / `none`，保留滚动功能
- **tmux 风格分割线**：`split-tab-spanner` 默认透明、宽 4px，hover / 拖动时才显示主题色
- **激活窗格着色**：`split-tab > .child.focused` 加 1px 主题色边框
- **Firefox 风格药丸标签**：`tab-header` 四角全圆 `12px`、四周留白悬浮、主题色线圈（非激活 45% 透明、hover 80%、激活实色 + 同色辉光）；隐藏原 `current-tab-indicator`

颜色统一用 CSS 变量（`--theme-primary`、`--body-bg` 等），换主题自动适配。

## 关键实现依据（供后续客制化参考）

- Tabby 内置插件完整源码位于 `C:\Program Files\Tabby\resources\builtin-plugins\`（`tabby-core/src`、`tabby-terminal/src`），比在线文档更精确可靠。
- 相关选择器：
  - 标签栏：`.main.content > .tab-bar > .tabs > tab-header(.active)`
  - 分割线：`split-tab-spanner`（`.h` 左右分屏 / `.v` 上下分屏 / `.active` 拖动中）
  - 分屏子面板：`split-tab > .child`（焦点为 `.focused`）
  - 终端视口：`.xterm-viewport`
- ⚠️ **Tabby 运行时会把内存中的配置全量写回磁盘**。修改 `config.yaml` 前必须先完全退出 Tabby（含托盘），否则改动会被覆盖。改完重启生效。

## 恢复方法

```powershell
# 恢复当前客制化配置
Copy-Item "$env:APPDATA\tabby\config.yaml" `
          "$env:APPDATA\tabby\config.yaml.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"  # 先备份现有
Copy-Item ".\config.yaml" "$env:APPDATA\tabby\config.yaml" -Force

# 回滚到原始配置
Copy-Item ".\config.yaml.orig" "$env:APPDATA\tabby\config.yaml" -Force
```

复制前请确保 Tabby 已完全退出。
