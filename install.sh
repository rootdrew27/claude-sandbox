#!/bin/sh
# Links claude-sandbox into a folder on your PATH (default: ~/.local/bin).
# Usage: ./install.sh [BIN_DIR]
set -e

repo="$(cd "$(dirname "$0")" && pwd)"
bin="${1:-$HOME/.local/bin}"

mkdir -p "$bin"
ln -sf "$repo/bin/claude-sandbox" "$bin/claude-sandbox"
echo "Linked $bin/claude-sandbox -> $repo/bin/claude-sandbox"

case ":$PATH:" in
  *":$bin:"*) ;;
  *) echo "Note: $bin is not on your PATH. Add it to your shell profile." ;;
esac
command -v docker >/dev/null || echo "Note: docker not found. Install Docker or OrbStack first."
