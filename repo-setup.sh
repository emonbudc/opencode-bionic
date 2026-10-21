#!/data/data/com.termux/files/usr/bin/sh
# One-command setup for the emonbudc/opencode-bionic Termux repository.
# Adds the signing key + sources entry, updates, installs opencode.
#   OPENCODE_CHANNEL=stable|beta|dev   (default: stable)
set -eu
BASE="https://udcemon.me/opencode-bionic"
CH="${OPENCODE_CHANNEL:-stable}"
case "$CH" in stable|beta|dev) ;; *) echo "OPENCODE_CHANNEL must be stable, beta or dev (got: $CH)" >&2; exit 1 ;; esac
[ -n "${PREFIX:-}" ] || { echo "Run this inside Termux." >&2; exit 1; }
command -v curl >/dev/null || { echo "pkg install curl first" >&2; exit 1; }
curl -fsSL "$BASE/opencode-bionic.gpg" -o "$PREFIX/etc/apt/trusted.gpg.d/opencode-bionic.gpg"
echo "deb [arch=aarch64] $BASE $CH main" > "$PREFIX/etc/apt/sources.list.d/opencode-bionic.list"
pkg update -y
VERSION="$(curl -fsSL "$BASE/dists/$CH/main/binary-aarch64/Packages" | sed -n 's/^Version: //p' | head -n 1)"
[ -n "$VERSION" ] || { echo "Could not resolve an opencode version for channel $CH" >&2; exit 1; }
if pkg install -y --allow-downgrades "opencode=$VERSION"; then
  INSTALLED="$(dpkg-query -W -f='${Version}' opencode 2>/dev/null || true)"
  if [ "$INSTALLED" != "$VERSION" ]; then
    echo "Expected opencode $VERSION from $CH, but found ${INSTALLED:-nothing installed}" >&2
    exit 1
  fi
  echo "Installed opencode $VERSION ($CH). pkg upgrade opencode keeps you current; rerun with OPENCODE_CHANNEL=beta or dev to switch lines."
else
  echo "pkg install opencode=$VERSION failed - run it manually to see the error" >&2
  exit 1
fi
