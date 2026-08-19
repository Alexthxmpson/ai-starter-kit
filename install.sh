#!/usr/bin/env bash
# AI Starter Kit installer
# From Alexander Alberts' AI event in Bali.
# Creates your AI workspace and installs Claude Code.

set -euo pipefail

REPO_URL="https://github.com/Alexthxmpson/ai-starter-kit.git"
DEFAULT_WORKSPACE="$HOME/ai-workspace"

bold()  { printf "\033[1m%s\033[0m\n" "$1"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn()  { printf "  \033[33m!\033[0m %s\n" "$1"; }
fail()  { printf "  \033[31m✗\033[0m %s\n" "$1"; }

echo ""
bold "AI Starter Kit"
echo "  Workspace + starter skills from the Bali AI event."
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
  if [ "$OS" = "Darwin" ]; then
    echo "    Easiest fix: install from https://nodejs.org (LTS version), then run this again."
    echo "    Or with Homebrew: brew install node"
  else
    echo "    Install the LTS version from https://nodejs.org, then run this again."
  fi
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

# ---------- 3. Create the workspace ----------
bold "[3/4] Your workspace"

WORKSPACE="$DEFAULT_WORKSPACE"
if [ -t 0 ]; then
  printf "  Where should your workspace live? [%s] " "$DEFAULT_WORKSPACE"
  read -r ANSWER || true
  if [ -n "${ANSWER:-}" ]; then WORKSPACE="$ANSWER"; fi
fi

# Find the workspace template: next to this script, or clone the repo to get it
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
TEMPLATE=""
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/workspace" ]; then
  TEMPLATE="$SCRIPT_DIR/workspace"
else
  TMP_CLONE="$(mktemp -d)"
  echo "  Fetching the kit..."
  git clone --depth 1 --quiet "$REPO_URL" "$TMP_CLONE/kit"
  TEMPLATE="$TMP_CLONE/kit/workspace"
fi

mkdir -p "$WORKSPACE"
# Copy without overwriting anything that already exists
(cd "$TEMPLATE" && find . -type d -exec mkdir -p "$WORKSPACE/{}" \;)
(cd "$TEMPLATE" && find . -type f | while read -r f; do
  dest="$WORKSPACE/${f#./}"
  if [ -e "$dest" ]; then
    warn "kept your existing ${f#./}"
  else
    cp "$f" "$dest"
  fi
done)
ok "Workspace ready at $WORKSPACE"

# ---------- 4. Done ----------
bold "[4/4] Done. Next steps:"
echo ""
echo "    cd $WORKSPACE"
echo "    claude"
echo ""
echo "  Sign in when it asks (Claude subscription or API key)."
echo "  Then try your first skill:"
echo ""
echo "    /brain-dump I want to build a dashboard for my weekly numbers"
echo ""
bold "Go create magic."
echo ""
