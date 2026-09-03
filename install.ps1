# AI Command Center installer (Windows, native — works in Warp on Windows)
# One line (PowerShell):
#   irm https://raw.githubusercontent.com/Alexthxmpson/ai-starter-kit/main/install.ps1 | iex
# The cloned folder BECOMES your command center.

$ErrorActionPreference = "Stop"
$RepoUrl = "https://github.com/Alexthxmpson/ai-starter-kit.git"
$Target = Join-Path $HOME "ai-command-center"

function Say-Bold($t) { Write-Host $t -ForegroundColor White }
function Say-Ok($t)   { Write-Host "  [ok] $t" -ForegroundColor Green }
function Say-Warn($t) { Write-Host "  [!]  $t" -ForegroundColor Yellow }
function Say-Fail($t) { Write-Host "  [x]  $t" -ForegroundColor Red }

Write-Host ""
Say-Bold "AI Command Center (Windows)"
Write-Host "  One folder. Your whole AI setup. From the Bali AI event."
Write-Host ""

# ---------- 1. Machine checks ----------
Say-Bold "[1/4] Checking your machine"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Say-Warn "git not found, installing via winget..."
  winget install --id Git.Git -e --silent --accept-package-agreements --accept-source-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
if (Get-Command git -ErrorAction SilentlyContinue) { Say-Ok "git ready" } else { Say-Fail "git install failed. Install from git-scm.com, reopen the terminal, run this again."; exit 1 }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Say-Warn "Node.js not found, installing LTS via winget..."
  winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
if (Get-Command node -ErrorAction SilentlyContinue) { Say-Ok "Node.js $(node -v) ready" } else { Say-Fail "Node.js install failed. Install the LTS from nodejs.org, reopen the terminal, run this again."; exit 1 }

# ---------- 2. Claude Code ----------
Say-Bold "[2/4] Claude Code"
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Say-Ok "Claude Code already installed"
} else {
  Write-Host "  Installing Claude Code (can take a minute)..."
  npm install -g "@anthropic-ai/claude-code" | Out-Null
  Say-Ok "Claude Code installed"
}

# ---------- 3. Your command center folder ----------
Say-Bold "[3/4] Your command center"
if (Test-Path (Join-Path $Target ".git")) {
  Say-Ok "Found existing command center at $Target, updating it"
  git -C $Target pull --ff-only 2>$null | Out-Null
} else {
  Write-Host "  Cloning to $Target ..."
  git clone --quiet $RepoUrl $Target
  Say-Ok "Cloned"
}
if (-not (Test-Path (Join-Path $Target ".env"))) {
  Copy-Item (Join-Path $Target ".env.example") (Join-Path $Target ".env")
}
Say-Ok "Private .env ready (never committed)"

# ---------- 4. Plugins ----------
Say-Bold "[4/4] Connecting plugins (MCPs)"
try { claude mcp add playwright -s user -- npx "@playwright/mcp@latest" 2>$null | Out-Null; Say-Ok "Playwright (AI gets a browser)" } catch { Say-Warn "Playwright MCP: add later via /onboard" }
try { claude mcp add context7 -s user -- npx -y "@upstash/context7-mcp@latest" 2>$null | Out-Null; Say-Ok "Context7 (live code docs)" } catch { Say-Warn "Context7 MCP: add later via /onboard" }
try { claude mcp add --transport http notion "https://mcp.notion.com/mcp" -s user 2>$null | Out-Null; Say-Ok "Notion (approve in browser on first use)" } catch { Say-Warn "Notion MCP: add later via /onboard" }

Write-Host ""
Say-Bold "Done. The fun part is next:"
Write-Host ""
Write-Host "    cd $Target"
Write-Host "    claude `"/onboard`""
Write-Host ""
Write-Host "  Sign in when Claude asks (Claude Pro/Max subscription or API key)."
Write-Host "  Claude then interviews you, connects your API keys step by step,"
Write-Host "  and personalizes the whole workspace to you and your business."
Write-Host ""
Say-Bold "Go create magic."
Write-Host ""
