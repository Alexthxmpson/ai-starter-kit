#!/usr/bin/env bash
# Setup wizard: connects MCPs and collects API keys into .env.
# Safe to re-run any time: it skips what is already set up.
# Run from the command center root:  bash setup/wizard.sh

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

bold()  { printf "\033[1m%s\033[0m\n" "$1"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn()  { printf "  \033[33m!\033[0m %s\n" "$1"; }
say()   { printf "  %s\n" "$1"; }

open_url() {
  if command -v open >/dev/null 2>&1; then open "$1";
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$1" >/dev/null 2>&1 || true;
  else say "Open this in your browser: $1"; fi
}

# Write or replace VAR=value in .env (never duplicates, never logs the value)
set_env() {
  local var="$1" val="$2"
  touch "$ENV_FILE"
  if grep -q "^${var}=" "$ENV_FILE"; then
    local tmp; tmp="$(mktemp)"
    sed "s|^${var}=.*|${var}=${val}|" "$ENV_FILE" > "$tmp" && mv "$tmp" "$ENV_FILE"
  else
    printf '%s=%s\n' "$var" "$val" >> "$ENV_FILE"
  fi
}

have_env() { grep -q "^${1}=..*" "$ENV_FILE" 2>/dev/null; }

# ask_key NAME VAR URL HINT  → opens page, collects key, saves
ask_key() {
  local name="$1" var="$2" url="$3" hint="$4"
  if have_env "$var"; then ok "$name already set, skipping"; return 0; fi
  echo ""
  bold "$name"
  say "$hint"
  printf "  Open %s now? [Y/n/skip] " "$url"
  read -r a || true
  case "${a:-y}" in
    [sS]*) warn "skipped $name"; return 0 ;;
    [nN]*) : ;;
    *) open_url "$url" ;;
  esac
  printf "  Paste your key here (or press Enter to skip): "
  read -r key || true
  if [ -z "${key:-}" ]; then warn "skipped $name"; return 0; fi
  set_env "$var" "$key"
  ok "$name saved to .env (…${key: -4})"
  return 0
}

echo ""
bold "Command Center setup wizard"
say "Connects your AI to the world. Re-run me any time: bash setup/wizard.sh"
echo ""

[ -f "$ENV_FILE" ] || cp "$ROOT/.env.example" "$ENV_FILE"

# ---------- MCPs (no key needed) ----------
bold "[1/3] Plugins (MCPs) — automatic"
if ! command -v claude >/dev/null 2>&1; then
  warn "Claude Code not found. Run ./install.sh first."
  exit 1
fi
MCPS="$(claude mcp list 2>/dev/null || true)"
add_mcp() {
  local name="$1"; shift
  if printf '%s' "$MCPS" | grep -qi "^$name:"; then ok "$name already connected"; else
    if claude mcp add "$@" >/dev/null 2>&1; then ok "$name connected"; else warn "$name failed, add later with: claude mcp add $*"; fi
  fi
}
add_mcp playwright playwright -s user -- npx '@playwright/mcp@latest'
add_mcp context7 context7 -s user -- npx -y '@upstash/context7-mcp@latest'
add_mcp notion --transport http notion https://mcp.notion.com/mcp -s user
say "Playwright gives your AI a browser. Context7 gives it live code docs."
say "Notion will ask you to approve access in your browser the first time it is used."

if [ ! -t 0 ]; then
  echo ""
  warn "Not running interactively, so I cannot collect API keys."
  say "Run this again from your terminal:  bash setup/wizard.sh"
  exit 0
fi

# ---------- Core keys ----------
echo ""
bold "[2/3] Core keys — I open the page, you paste the key"
ask_key "Tavily (web search, free 1,000/mo)" TAVILY_API_KEY "https://app.tavily.com" "Sign up free, copy the key starting with tvly- from the dashboard."
if have_env TAVILY_API_KEY; then
  TK="$(grep '^TAVILY_API_KEY=' "$ENV_FILE" | cut -d= -f2-)"
  if ! printf '%s' "$(claude mcp list 2>/dev/null)" | grep -qi '^tavily:'; then
    claude mcp add --transport http tavily "https://mcp.tavily.com/mcp/?tavilyApiKey=${TK}" -s user >/dev/null 2>&1 && ok "Tavily MCP connected" || warn "Tavily MCP add failed (key still saved)"
  fi
fi
ask_key "Airtable (your data's first home)" AIRTABLE_API_KEY "https://airtable.com/create/tokens" "Create a token with scopes data.records read+write and schema.bases read. Starts with pat."
if have_env AIRTABLE_API_KEY; then
  AK="$(grep '^AIRTABLE_API_KEY=' "$ENV_FILE" | cut -d= -f2-)"
  if curl -sf -H "Authorization: Bearer $AK" https://api.airtable.com/v0/meta/whoami >/dev/null 2>&1; then ok "Airtable key verified"; else warn "Airtable key did not verify. Check the token scopes and re-run me."; fi
fi
ask_key "Groq (free, ultra-fast transcription)" GROQ_API_KEY "https://console.groq.com/keys" "Free account, create an API key."

# ---------- Optional keys ----------
echo ""
bold "[3/3] Optional — only if you use these tools"
printf "  Go through optional connectors (Fathom, ElevenLabs, OpenAI, Gemini, Exa, Firecrawl, Perplexity, Supabase)? [y/N] "
read -r opt || true
if [ "${opt:-n}" = "y" ] || [ "${opt:-n}" = "Y" ]; then
  ask_key "Fathom (meeting recordings)" FATHOM_API_KEY "https://fathom.video/settings" "Settings, then API. Only if you record calls with Fathom."
  ask_key "ElevenLabs (voice generation)" ELEVENLABS_API_KEY "https://elevenlabs.io" "Profile, then API keys."
  ask_key "OpenAI" OPENAI_API_KEY "https://platform.openai.com/api-keys" "Only needed for OpenAI-specific builds."
  ask_key "Google Gemini" GEMINI_API_KEY "https://aistudio.google.com/apikey" "Free tier available."
  ask_key "Exa (semantic search)" EXA_API_KEY "https://dashboard.exa.ai" "Company and people research."
  ask_key "Firecrawl (scraping)" FIRECRAWL_API_KEY "https://firecrawl.dev" "Turns websites into clean data."
  ask_key "Perplexity" PERPLEXITY_API_KEY "https://www.perplexity.ai/settings/api" "AI web search with citations."
  ask_key "Supabase URL" SUPABASE_URL "https://supabase.com/dashboard" "Project, Settings, API: the Project URL."
  ask_key "Supabase anon key" SUPABASE_ANON_KEY "https://supabase.com/dashboard" "Same page: the anon public key."
fi

echo ""
bold "Wizard done."
say "Keys live in .env (never share that file). Re-run me any time to add more."
echo ""
bold "Final step, the fun one:"
echo ""
say "claude \"/onboard\""
echo ""
say "Claude will interview you and personalize this whole workspace to you."
echo ""
