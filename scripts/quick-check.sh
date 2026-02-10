#!/bin/bash
# Quick check for Mole -- validates only changed files.
# Designed to run in <10 seconds as the inner feedback loop for agents.
# For full check with formatting, use: ./scripts/check.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# Get changed files (staged + unstaged vs HEAD)
CHANGED_SH=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(sh|bats)$' || true)
CHANGED_GO=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.go$' || true)

# Also include untracked shell files
UNTRACKED_SH=$(git ls-files --others --exclude-standard 2>/dev/null | grep -E '\.(sh|bats)$' || true)
CHANGED_SH=$(printf '%s\n%s' "$CHANGED_SH" "$UNTRACKED_SH" | sort -u | grep -v '^$' || true)

# Include 'mole' script if changed
if git diff --name-only HEAD 2>/dev/null | grep -q '^mole$'; then
    CHANGED_SH=$(printf '%s\nmole' "$CHANGED_SH" | sort -u)
fi

if [[ -z "$CHANGED_SH" ]] && [[ -z "$CHANGED_GO" ]]; then
    echo -e "${GREEN}No changed files to check.${NC}"
    exit 0
fi

# Syntax check changed shell files
if [[ -n "$CHANGED_SH" ]]; then
    echo "Checking shell syntax..."
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue
        if ! bash -n "$file" 2>&1; then
            echo -e "${RED}  x Syntax error: $file${NC}"
            FAILED=1
        fi
    done <<< "$CHANGED_SH"

    # ShellCheck
    if command -v shellcheck > /dev/null 2>&1; then
        echo "Running ShellCheck..."
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            [[ ! -f "$file" ]] && continue
            if ! shellcheck "$file" > /dev/null 2>&1; then
                echo -e "${RED}  x ShellCheck: $file${NC}"
                shellcheck "$file" 2>&1 | head -20
                FAILED=1
            fi
        done <<< "$CHANGED_SH"
    else
        echo -e "${YELLOW}  shellcheck not installed, skipping${NC}"
    fi

    # Format diff (detect only, no auto-fix)
    if command -v shfmt > /dev/null 2>&1; then
        echo "Checking formatting..."
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            [[ ! -f "$file" ]] && continue
            if ! shfmt -i 4 -ci -sr -d "$file" > /dev/null 2>&1; then
                echo -e "${YELLOW}  ! Format: $file (run: shfmt -i 4 -ci -sr -w $file)${NC}"
            fi
        done <<< "$CHANGED_SH"
    fi
fi

# Go checks
if [[ -n "$CHANGED_GO" ]]; then
    if command -v go > /dev/null 2>&1; then
        echo "Running Go checks..."
        if ! go vet ./cmd/... 2>&1; then
            echo -e "${RED}  x go vet failed${NC}"
            FAILED=1
        fi
        if ! go build ./... > /dev/null 2>&1; then
            echo -e "${RED}  x go build failed${NC}"
            FAILED=1
        fi
    fi
fi

if [[ $FAILED -ne 0 ]]; then
    echo -e "\n${RED}Quick check failed.${NC}"
    exit 1
fi

echo -e "${GREEN}Quick check passed.${NC}"
