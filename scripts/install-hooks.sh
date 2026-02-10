#!/bin/bash
# Install git hooks for Mole development.
# Copies pre-commit and commit-msg hooks to .git/hooks/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

if [[ ! -d "$HOOKS_DIR" ]]; then
    echo "Error: .git/hooks/ not found. Are you in a git repository?" >&2
    exit 1
fi

# Install pre-commit hook
if [[ -f "$SCRIPT_DIR/pre-commit" ]]; then
    cp "$SCRIPT_DIR/pre-commit" "$HOOKS_DIR/pre-commit"
    chmod +x "$HOOKS_DIR/pre-commit"
    echo "Installed pre-commit hook"
fi

# Install commit-msg hook (if it exists)
if [[ -f "$SCRIPT_DIR/commit-msg" ]]; then
    cp "$SCRIPT_DIR/commit-msg" "$HOOKS_DIR/commit-msg"
    chmod +x "$HOOKS_DIR/commit-msg"
    echo "Installed commit-msg hook"
fi

echo "Done. Hooks installed to $HOOKS_DIR/"
