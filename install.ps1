param(
  [switch]$SkipPlugins,
  [switch]$SkipSkills,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Step([string]$Message) {
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Ok([string]$Message) {
  Write-Host "OK   $Message" -ForegroundColor Green
}

function Warn([string]$Message) {
  Write-Host "WARN $Message" -ForegroundColor Yellow
}

function HasCommand([string]$Name) {
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function RunCmd([string]$Label, [string]$File, [string[]]$CommandArgs, [switch]$AllowFailure) {
  $cmdText = "$File $($CommandArgs -join ' ')"
  if ($DryRun) {
    Write-Host "[dry-run] $Label`: $cmdText"
    return
  }
  Write-Host "$Label`: $cmdText"
  & $File @CommandArgs
  $code = $LASTEXITCODE
  if ($code -ne 0) {
    if ($AllowFailure) {
      Warn "$Label failed with exit code $code, continue."
    } else {
      throw "$Label failed with exit code $code"
    }
  }
}

Write-Host "Qingqi Claude config installer"
Write-Host "Safety: this script never reads .env, API keys, tokens, MongoDB connection strings, or CloudBase secrets."
Write-Host "You can run it from any folder."

Step "Check base commands"
if (-not (HasCommand "node")) { Warn "node not found. Install Node.js LTS first." } else { Ok "node found" }
if (-not (HasCommand "npm")) { Warn "npm not found. Install Node.js LTS first." } else { Ok "npm found" }
if (-not (HasCommand "npx")) { Warn "npx not found. Install Node.js LTS first." } else { Ok "npx found" }
if (-not (HasCommand "claude")) { Warn "claude not found. Install Claude Code first." } else { Ok "claude found" }

if (-not $SkipPlugins -and (HasCommand "claude")) {
  Step "Install Claude Code plugin marketplaces"
  RunCmd "Add Anthropic official marketplace" "claude" @("plugin", "marketplace", "add", "anthropics/claude-plugins-official", "--scope", "user") -AllowFailure
  RunCmd "Add Chrome DevTools marketplace" "claude" @("plugin", "marketplace", "add", "ChromeDevTools/chrome-devtools-mcp", "--scope", "user") -AllowFailure

  Step "Install Claude Code plugins"
  $plugins = @(
    "superpowers@claude-plugins-official",
    "code-review@claude-plugins-official",
    "security-guidance@claude-plugins-official",
    "typescript-lsp@claude-plugins-official",
    "pyright-lsp@claude-plugins-official",
    "playwright@claude-plugins-official",
    "commit-commands@claude-plugins-official",
    "frontend-design@claude-plugins-official",
    "chrome-devtools-mcp@chrome-devtools-plugins",
    "figma@claude-plugins-official",
    "github@claude-plugins-official"
  )
  foreach ($plugin in $plugins) {
    RunCmd "Install plugin $plugin" "claude" @("plugin", "install", $plugin, "--scope", "user") -AllowFailure
  }
}

if (-not $SkipSkills -and (HasCommand "npx")) {
  Step "Install MiniMax office skills"
  $minimaxSkills = @("minimax-docx", "minimax-xlsx", "minimax-pdf", "pptx-generator", "vision-analysis")
  foreach ($skill in $minimaxSkills) {
    RunCmd "Install MiniMax skill $skill" "npx" @("-y", "skills", "add", "https://github.com/MiniMax-AI/skills", "--skill", $skill) -AllowFailure
  }

  Step "Install taste frontend skill"
  RunCmd "Install design-taste-frontend" "npx" @("-y", "skills", "add", "https://github.com/Leonxlnx/taste-skill", "--skill", "design-taste-frontend") -AllowFailure
}

if ((HasCommand "claude")) {
  Step "Install Playwright MCP if missing"
  $mcpList = ""
  try { $mcpList = (& claude mcp list 2>$null) -join "`n" } catch { $mcpList = "" }
  if ($mcpList -match "(?m)\bplaywright\b") {
    Ok "Playwright MCP already exists"
  } else {
    RunCmd "Add Playwright MCP" "claude" @("mcp", "add", "--scope", "user", "--transport", "stdio", "playwright", "--", "npx", "-y", "@playwright/mcp@latest") -AllowFailure
  }
}

Step "Done"
Write-Host "Restart Claude Code after installation."
Write-Host "Then ask Claude: list available Skills and plugins."
Write-Host "Important skills to check: minimax-docx, minimax-xlsx, minimax-pdf, pptx-generator, vision-analysis, design-taste-frontend."
Write-Host "Important plugins to check: frontend-design, chrome-devtools, superpowers, typescript-lsp, pyright-lsp."
