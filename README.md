# 青契 Claude 配置仓库

这是青契团队统一 Claude Code 配置仓库。

一行安装：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/hhh-dahah/qingqi-claude-config/main/install.ps1 | iex"
```

## 它会做什么

- 安装/检查 Claude Code 常用官方插件。
- 安装 MiniMax 官方办公 Skills 子集：Word、Excel、PDF、PPT、视觉分析。
- 安装 taste-skill 前端审美 Skill。
- 安装 Playwright MCP。
- 输出本机检查结果。

## 它不会做什么

- 不读取 `.env`。
- 不输出或保存 API key、token、MongoDB 连接串、CloudBase 密钥。
- 不替你登录 GitHub、CloudBase、Figma。

## 装完后

重启 Claude Code，然后输入：

```text
列出当前可用 Skills 和插件，检查 minimax-docx、minimax-xlsx、minimax-pdf、pptx-generator、vision-analysis、design-taste-frontend 是否存在。
```
