#!/usr/bin/env bash
# AI Starter Kit installer
# From Alexander Alberts' AI event in Bali.
# Fresh install:  ./install.sh          (or the curl one-liner in the README)
# Update later:   ./install.sh --update (adds new skills and docs, never touches your files)

set -euo pipefail

REPO_URL="https://github.com/Alexthxmpson/ai-starter-kit.git"
DEFAULT_WORKSPACE="$HOME/ai-workspace"
MODE="install"
[ "${1:-}" = "--update" ] && MODE="update"

bold()  { printf "\033[1m%s\033[0m\n" "$1"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn()  { printf "  \033[33m!\033[0m %s\n" "$1"; }
fail()  { printf "  \033[31m✗\033[0m %s\n" "$1"; }

echo ""
bold "AI Starter Kit"
if [ "$MODE" = "update" ]; then
  echo "  Update mode: adding anything new, never touching your existing files."
else
  echo "  Workspace + starter skills from the Bali AI event."
fi
echo ""

# ---------- 1. Check the machine ----------
bold "[1/4] Checking your machine"

OS="$(uname -s)"
if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
  fail "This installer supports macOS and Linux. On Windows, use WSL and run it again."
  exit 1
fi
ok "$OS detected"

if ! command -v git >/dev/null 2>&1; then
  fail "git is not installed."
  if [ "$OS" = "Darwin" ]; then
    echo "    Run: xcode-select --install   (then run this installer again)"
  else
    echo "    Run: sudo apt install git     (then run this installer again)"
  fi
  exit 1
fi
ok "git found"

if ! command -v node >/dev/null 2>&1; then
  fail "Node.js is not installed."
  echo "    Install the LTS version from https://nodejs.org, then run this again."
  [ "$OS" = "Darwin" ] && echo "    Or with Homebrew: brew install node"
  exit 1
fi

NODE_MAJOR="$(node -v | sed 's/^v//' | cut -d. -f1)"
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js 18 or newer is required (you have $(node -v))."
  echo "    Install the LTS version from https://nodejs.org, then run this again."
  exit 1
fi
ok "Node.js $(node -v) found"

# ---------- 2. Install Claude Code ----------
bold "[2/4] Claude Code"

if command -v claude >/dev/null 2>&1; then
  ok "Claude Code already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
  echo "  Installing Claude Code (this can take a minute)..."
  if npm install -g @anthropic-ai/claude-code >/dev/null 2>&1; then
    ok "Claude Code installed"
  else
    warn "Global npm install needed elevated rights. Trying with sudo..."
    sudo npm install -g @anthropic-ai/claude-code
    ok "Claude Code installed"
  fi
fi

# ---------- 3. Create or update the workspace ----------
if [ "$MODE" = "update" ]; then bold "[3/4] Updating your workspace"; else bold "[3/4] Your workspace"; fi

WORKSPACE="$DEFAULT_WORKSPACE"
if [ -t 0 ] && [ "$MODE" = "install" ]; then
  printf "  Where should your workspace live? [%s] " "$DEFAULT_WORKSPACE"
  read -r ANSWER || true
  if [ -n "${ANSWER:-}" ]; then WORKSPACE="$ANSWER"; fi
fi
if [ "$MODE" = "update" ] && [ ! -d "$WORKSPACE" ]; then
  fail "No workspace found at $WORKSPACE. Run a fresh install first (without --update)."
  exit 1
fi

# Find the kit source: next to this script, or clone the repo fresh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
KIT=""
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/workspace" ]; then
  KIT="$SCRIPT_DIR"
else
  TMP_CLONE="$(mktemp -d)"
  echo "  Fetching the latest kit..."
  git clone --depth 1 --quiet "$REPO_URL" "$TMP_CLONE/kit"
  KIT="$TMP_CLONE/kit"
fi
TEMPLATE="$KIT/workspace"

mkdir -p "$WORKSPACE"
ADDED=0
# Copy without overwriting anything that already exists
(cd "$TEMPLATE" && find . -type d -exec mkdir -p "$WORKSPACE/{}" \;)
while read -r f; do
  dest="$WORKSPACE/${f#./}"
  if [ -e "$dest" ]; then
    [ "$MODE" = "install" ] && warn "kept your existing ${f#./}"
  else
    cp "$TEMPLATE/$f" "$dest"
    ADDED=$((ADDED+1))
    [ "$MODE" = "update" ] && ok "added ${f#./}"
  fi
done < <(cd "$TEMPLATE" && find . -type f)

# Ship the guides too
mkdir -p "$WORKSPACE/docs/guides"
for g in "$KIT"/docs/*.md; do
  [ -e "$g" ] || continue
  dest="$WORKSPACE/docs/guides/$(basename "$g")"
  if [ ! -e "$dest" ]; then cp "$g" "$dest"; ADDED=$((ADDED+1)); fi
done

if [ "$MODE" = "update" ] && [ "$ADDED" -eq 0 ]; then
  ok "Already up to date. Nothing new to add."
else
  ok "Workspace ready at $WORKSPACE ($ADDED new files)"
fi

# ---------- 4. Done ----------
bold "[4/4] Done. Your skills:"
echo ""
for s in "$WORKSPACE/.claude/commands/"*.md; do
  printf "    /%s\n" "$(basename "$s" .md)"
done
echo ""
echo "  Next steps:"
echo ""
echo "    cd $WORKSPACE"
echo "    claude"
echo ""
echo "  Sign in when it asks (Claude subscription or API key)."
echo "  Then try: /brain-dump I want a dashboard for my weekly numbers"
echo "  Guides live in $WORKSPACE/docs/guides/"
echo ""
bold "Go create magic."
echo ""
