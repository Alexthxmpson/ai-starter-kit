#!/usr/bin/env bash
# AI Command Center installer (macOS / Linux / WSL)
# One line:  curl -fsSL https://raw.githubusercontent.com/Alexthxmpson/ai-starter-kit/main/install.sh | bash
# The cloned folder BECOMES your command center. Re-running inside it just updates dependencies.

set -euo pipefail

REPO_URL="https://github.com/Alexthxmpson/ai-starter-kit.git"
DEFAULT_TARGET="$HOME/ai-command-center"

bold()  { printf "\033[1m%s\033[0m\n" "$1"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn()  { printf "  \033[33m!\033[0m %s\n" "$1"; }
fail()  { printf "  \033[31m✗\033[0m %s\n" "$1"; }

echo ""
bold "AI Command Center"
echo "  One folder. Your whole AI setup. From the Bali AI event."
echo ""

# ---------- 1. Machine checks ----------
bold "[1/4] Checking your machine"
OS="$(uname -s)"
if [ "$OS" != "Darwin" ] && [ "$OS" != "Linux" ]; then
  fail "Use install.ps1 on Windows (see README), or run this inside WSL."
  exit 1
fi
ok "$OS detected"

if ! command -v git >/dev/null 2>&1; then
  fail "git is not installed."
  [ "$OS" = "Darwin" ] && echo "    Run: xcode-select --install   then run this installer again." || echo "    Run: sudo apt install git   then run this installer again."
  exit 1
fi
ok "git found"

if ! command -v node >/dev/null 2>&1; then
  fail "Node.js is not installed. Get the LTS from https://nodejs.org then run this again."
  [ "$OS" = "Darwin" ] && echo "    Or with Homebrew: brew install node"
  exit 1
fi
NODE_MAJOR="$(node -v | sed 's/^v//' | cut -d. -f1)"
if [ "$NODE_MAJOR" -lt 18 ]; then
  fail "Node.js 18+ required (you have $(node -v)). Get the LTS from https://nodejs.org"
  exit 1
fi
ok "Node.js $(node -v) found"

# ---------- 2. Claude Code ----------
bold "[2/4] Claude Code"
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code already installed"
else
  echo "  Installing Claude Code (can take a minute)..."
  if npm install -g @anthropic-ai/claude-code >/dev/null 2>&1; then ok "Claude Code installed"; else
    warn "Needed elevated rights, trying sudo..."
    sudo npm install -g @anthropic-ai/claude-code
    ok "Claude Code installed"
  fi
fi

# ---------- 3. Your command center folder ----------
bold "[3/4] Your command center"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/.claude/commands" ]; then
  TARGET="$SCRIPT_DIR"
  ok "Running inside your command center: $TARGET"
else
  TARGET="$DEFAULT_TARGET"
  if [ -t 0 ]; then
    printf "  Where should your command center live? [%s] " "$DEFAULT_TARGET"
    read -r ANSWER || true
    [ -n "${ANSWER:-}" ] && TARGET="$ANSWER"
  fi
  if [ -d "$TARGET/.git" ]; then
    ok "Found existing command center at $TARGET, updating it"
    git -C "$TARGET" pull --ff-only >/dev/null 2>&1 && ok "Updated to the latest kit" || warn "Could not auto-update (local changes?). Continuing."
  else
    echo "  Cloning your command center to $TARGET ..."
    git clone --quiet "$REPO_URL" "$TARGET"
    ok "Cloned"
  fi
fi
[ -f "$TARGET/.env" ] || cp "$TARGET/.env.example" "$TARGET/.env"
ok "Private .env ready (never committed)"

# ---------- 4. The wizard ----------
bold "[4/4] Connecting your AI to the world"
if [ -t 0 ]; then
  bash "$TARGET/setup/wizard.sh" || warn "Wizard hit a snag. Re-run later: bash setup/wizard.sh"
else
  warn "Not interactive, skipping the wizard. Run it next:  cd $TARGET && bash setup/wizard.sh"
  echo ""
  bold "Then the fun part:"
  echo ""
  echo "    cd $TARGET"
  echo "    claude \"/onboard\""
  echo ""
  echo "  Claude interviews you and personalizes the whole workspace."
  echo ""
  bold "Go create magic."
  echo ""
fi
