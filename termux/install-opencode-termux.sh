#!/data/data/com.termux/files/usr/bin/bash
# Install a compiled opencode binary into $PREFIX.

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}[OK]${NC}   $*"; }
fail() { echo -e "  ${RED}[FAIL]${NC} $*"; exit 1; }
warn() { echo -e "  ${YELLOW}[WARN]${NC} $*"; }

OPENCODE_ROOT="${OPENCODE_ROOT:-$(pwd)}"

if [ -z "${PREFIX:-}" ]; then
  fail "PREFIX not set. This script must run inside Termux."
fi

BINARY="$OPENCODE_ROOT/packages/cli/dist/cli-linux-arm64/bin/opencode"

if [ ! -f "$BINARY" ]; then
  fail "Binary not found at $BINARY — run: bash termux/build-opencode-termux.sh"
fi

echo "=========================================="
echo "Installing opencode binary"
echo "=========================================="
echo "  Binary:   $BINARY"
echo "  Target:   $PREFIX/lib/opencode/opencode"
echo "  Symlink:  $PREFIX/bin/opencode"
echo "=========================================="

echo ""
echo "=== Step 1: Copy binary ==="
mkdir -p "$PREFIX/lib/opencode"
cp "$BINARY" "$PREFIX/lib/opencode/opencode"
chmod 755 "$PREFIX/lib/opencode/opencode"
ok "Binary copied to $PREFIX/lib/opencode/opencode"

echo ""
echo "=== Step 1b: Install default AGENTS.md (if missing) ==="
mkdir -p "$HOME/.config/opencode"
if [ ! -f "$HOME/.config/opencode/AGENTS.md" ] && [ -f "$OPENCODE_ROOT/termux/AGENTS.md" ]; then
  cp "$OPENCODE_ROOT/termux/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
  chmod 0644 "$HOME/.config/opencode/AGENTS.md"
  ok "Default AGENTS.md installed"
elif [ -f "$HOME/.config/opencode/AGENTS.md" ]; then
  info "AGENTS.md already exists, leaving it untouched"
else
  warn "termux/AGENTS.md not found in build tree; skipping"
fi

echo ""
echo "=== Step 1c: Install default opencode.jsonc (if missing) ==="
if [ ! -f "$HOME/.config/opencode/opencode.jsonc" ] && [ -f "$OPENCODE_ROOT/termux/opencode.jsonc" ]; then
  cp "$OPENCODE_ROOT/termux/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
  chmod 0644 "$HOME/.config/opencode/opencode.jsonc"
  ok "Default opencode.jsonc installed"
elif [ -f "$HOME/.config/opencode/opencode.jsonc" ]; then
  info "opencode.jsonc already exists, leaving it untouched"
else
  warn "termux/opencode.jsonc not found in build tree; skipping"
fi

echo ""
echo "=== Step 2: Create symlink ==="
ln -sf "$PREFIX/lib/opencode/opencode" "$PREFIX/bin/opencode"
ok "Symlink created at $PREFIX/bin/opencode"

echo ""
echo "=== Step 3: Verify install ==="
VERSION_OUTPUT=$("$PREFIX/bin/opencode" --version 2>&1) || true
if [ -n "$VERSION_OUTPUT" ]; then
  ok "opencode --version: $VERSION_OUTPUT"
else
  warn "opencode --version produced no output (may need debugging)"
fi

echo ""
echo "=========================================="
echo "Install complete!"
echo "=========================================="
echo ""
INSTALLED_SIZE=$(du -h "$PREFIX/lib/opencode/opencode" 2>/dev/null | cut -f1 || echo "?")
echo "Binary:  $PREFIX/lib/opencode/opencode ($INSTALLED_SIZE)"
echo "Symlink: $PREFIX/bin/opencode -> $PREFIX/lib/opencode/opencode"
echo ""
echo "Now you can run opencode from anywhere:"
echo "  opencode"
echo "  opencode --version"
echo "  opencode run 'hello world'"
