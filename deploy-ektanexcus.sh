#!/usr/bin/env bash
###############################################################################
# Ekta NexCus — Think tank India 2047
# Advanced GitHub Deployment Script
#
# What it does:
#   1. Verifies prerequisites (git, gh CLI, gh auth status)
#   2. Initialises a git repo (if not already one)
#   3. Creates the GitHub repository (if it doesn't already exist) via gh CLI
#   4. Adds/updates index.html (and any other site files in this folder)
#   5. Commits with a meaningful, timestamped message
#   6. Pushes to GitHub (main branch)
#   7. Enables GitHub Pages on the repo (branch: main, path: /)
#   8. Prints the live Pages URL when done
#
# Usage:
#   chmod +x deploy-ektanexcus.sh
#   ./deploy-ektanexcus.sh
#
# First-time setup (only needed once per machine):
#   gh auth login
#
# Optional overrides (set as environment variables before running):
#   REPO_NAME="my-custom-repo"   GH_USERNAME="your-github-username" ./deploy-ektanexcus.sh
###############################################################################

set -euo pipefail

# ── CONFIG (edit these or override via env vars) ───────────────────────────
REPO_NAME="${REPO_NAME:-ektanexcus-eng.github.io}"     # repo to create/use
GH_USERNAME="${GH_USERNAME:-}"                          # auto-detected if blank
SITE_DIR="${SITE_DIR:-$(pwd)}"                           # folder with index.html
DEFAULT_BRANCH="main"
COMMIT_MSG="${COMMIT_MSG:-}"
VISIBILITY="${VISIBILITY:-public}"                       # public | private

# ── COLORS ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()  { echo -e "${BLUE}${BOLD}▶${NC} $1"; }
ok()   { echo -e "${GREEN}✔${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✘ $1${NC}" >&2; }
die()  { err "$1"; exit 1; }

trap 'err "Deployment failed at line $LINENO. See message above."' ERR

# ── 1. PREREQUISITE CHECKS ──────────────────────────────────────────────────
log "Checking prerequisites..."

command -v git >/dev/null 2>&1 || die "git is not installed. Install it first: https://git-scm.com/downloads"
ok "git found ($(git --version))"

command -v gh >/dev/null 2>&1 || die "GitHub CLI (gh) is not installed. Install it: https://cli.github.com/"
ok "gh CLI found ($(gh --version | head -n1))"

if ! gh auth status >/dev/null 2>&1; then
  warn "You are not logged in to GitHub CLI."
  log "Launching 'gh auth login'..."
  gh auth login
fi
ok "GitHub CLI authenticated"

if [[ -z "$GH_USERNAME" ]]; then
  GH_USERNAME="$(gh api user --jq .login)"
fi
ok "GitHub user: $GH_USERNAME"

cd "$SITE_DIR"
[[ -f "index.html" ]] || die "index.html not found in $SITE_DIR. Run this script from the folder containing your site files."
ok "Found index.html in $SITE_DIR"

# ── 2. GIT REPO INIT ─────────────────────────────────────────────────────────
log "Setting up local git repository..."

if [[ ! -d ".git" ]]; then
  git init -b "$DEFAULT_BRANCH"
  ok "Initialised new git repo (branch: $DEFAULT_BRANCH)"
else
  ok "Git repo already initialised"
  CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo "")"
  if [[ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" && -n "$CURRENT_BRANCH" ]]; then
    git branch -m "$CURRENT_BRANCH" "$DEFAULT_BRANCH"
    ok "Renamed branch '$CURRENT_BRANCH' → '$DEFAULT_BRANCH'"
  fi
fi

# Sensible default .gitignore if one doesn't exist
if [[ ! -f ".gitignore" ]]; then
  cat > .gitignore <<'EOF'
.DS_Store
*.log
node_modules/
.env
EOF
  ok "Created default .gitignore"
fi

# Identify git user locally if not already configured (repo-level, non-destructive)
if [[ -z "$(git config user.email || true)" ]]; then
  GH_EMAIL="$(gh api user --jq .email 2>/dev/null || true)"
  [[ -z "$GH_EMAIL" || "$GH_EMAIL" == "null" ]] && GH_EMAIL="${GH_USERNAME}@users.noreply.github.com"
  git config user.email "$GH_EMAIL"
  git config user.name "$GH_USERNAME"
  ok "Configured local git identity: $GH_USERNAME <$GH_EMAIL>"
fi

# ── 3. CREATE / VERIFY REMOTE REPO ──────────────────────────────────────────
log "Checking if remote repo '$GH_USERNAME/$REPO_NAME' exists..."

if gh repo view "$GH_USERNAME/$REPO_NAME" >/dev/null 2>&1; then
  ok "Remote repo already exists: https://github.com/$GH_USERNAME/$REPO_NAME"
else
  log "Repo not found. Creating it on GitHub (visibility: $VISIBILITY)..."
  gh repo create "$GH_USERNAME/$REPO_NAME" \
    --"$VISIBILITY" \
    --description "Ekta NexCus — Think tank India 2047 | 6-Hour Workday Policy Movement" \
    --homepage "https://${GH_USERNAME}.github.io/${REPO_NAME/.github.io/}" \
    -y
  ok "Created remote repo: https://github.com/$GH_USERNAME/$REPO_NAME"
fi

# Wire up remote 'origin' if not already set
if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "https://github.com/$GH_USERNAME/$REPO_NAME.git"
  ok "Added remote 'origin'"
else
  CURRENT_REMOTE="$(git remote get-url origin)"
  ok "Remote 'origin' already set: $CURRENT_REMOTE"
fi

# ── 4. STAGE & COMMIT ────────────────────────────────────────────────────────
log "Staging files..."
git add -A

if git diff --cached --quiet; then
  warn "Nothing new to commit — working tree already matches last commit."
else
  if [[ -z "$COMMIT_MSG" ]]; then
    COMMIT_MSG="Update site — $(date '+%Y-%m-%d %H:%M:%S') — 15 Aug 2026 to 26 Jan 2027 Independence-to-Republic movement banner"
  fi
  git commit -m "$COMMIT_MSG"
  ok "Committed: \"$COMMIT_MSG\""
fi

# ── 5. PUSH ──────────────────────────────────────────────────────────────────
log "Pushing to GitHub ($DEFAULT_BRANCH)..."
git push -u origin "$DEFAULT_BRANCH" --force-with-lease 2>/dev/null || git push -u origin "$DEFAULT_BRANCH"
ok "Pushed to origin/$DEFAULT_BRANCH"

# ── 6. ENABLE GITHUB PAGES ───────────────────────────────────────────────────
log "Configuring GitHub Pages (branch: $DEFAULT_BRANCH, path: /)..."

PAGES_PAYLOAD=$(cat <<EOF
{"source":{"branch":"$DEFAULT_BRANCH","path":"/"}}
EOF
)

if gh api "repos/$GH_USERNAME/$REPO_NAME/pages" >/dev/null 2>&1; then
  gh api -X PUT "repos/$GH_USERNAME/$REPO_NAME/pages" \
    --input - <<< "$PAGES_PAYLOAD" >/dev/null 2>&1 || true
  ok "GitHub Pages already enabled and updated"
else
  gh api -X POST "repos/$GH_USERNAME/$REPO_NAME/pages" \
    --input - <<< "$PAGES_PAYLOAD" >/dev/null 2>&1 || \
    warn "Could not auto-enable Pages via API. Enable manually: Settings → Pages → Source: $DEFAULT_BRANCH /"
  ok "Requested GitHub Pages activation"
fi

# ── 7. DONE ──────────────────────────────────────────────────────────────────
if [[ "$REPO_NAME" == *.github.io ]]; then
  PAGES_URL="https://${GH_USERNAME}.github.io/"
  [[ "$REPO_NAME" != "${GH_USERNAME}.github.io" ]] && PAGES_URL="https://${GH_USERNAME}.github.io/${REPO_NAME%.github.io}"
else
  PAGES_URL="https://${GH_USERNAME}.github.io/${REPO_NAME}/"
fi

echo
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  ✔ Deployment complete — Ekta NexCus is live${NC}"
echo -e "${GREEN}${BOLD}════════════════════════════════════════════════════════${NC}"
echo -e "  Repo:   ${BOLD}https://github.com/$GH_USERNAME/$REPO_NAME${NC}"
echo -e "  Pages:  ${BOLD}$PAGES_URL${NC}  (may take 1–2 min to go live)"
echo
echo -e "${YELLOW}Tip:${NC} Re-run this script any time after editing index.html — it will"
echo -e "     auto-commit and push the latest version."
echo
