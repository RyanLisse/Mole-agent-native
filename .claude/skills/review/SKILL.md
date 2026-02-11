# Review

Mole-specific multi-perspective code review. Checks for the patterns that matter most in this codebase.

## When to Use

After implementing a feature or fix, before closing a bead. Also usable standalone: `/review` to review all staged changes.

## Review Checks

Run all checks in parallel, then synthesize findings.

### 1. Safe File Operations Check

Search all changed files for:
- Direct `rm` or `rm -rf` usage (must use `safe_remove`)
- Direct `rm -rf` with variable expansion (injection risk)
- Missing path validation before deletion
- Operations on protected paths

```bash
# Pattern to flag:
grep -n 'rm -rf\|rm -r ' <changed-files>
# Should only appear in tests/teardown or lib/core/file_ops.sh
```

**Severity:** P1 (blocking) -- any direct `rm` outside of file_ops.sh or test teardown.

### 2. Bash 3.2 Compatibility Check

Search all changed `.sh` files for:
- `declare -A` (associative arrays)
- `${var,,}` or `${var^^}` (case transforms)
- `|&` (pipe stderr)
- `readarray` or `mapfile`
- `&>>` (append both streams)

Reference: `docs/learnings/bash-compatibility.md`

**Severity:** P1 (blocking) -- code will break on macOS default bash.

### 3. BSD Command Check

Search for GNU-isms in changed files:
- `stat --format` (should be `stat -f%z`)
- `sed -i 's/` without `''` (should be `sed -i '' 's/`)
- `date -d` (should be `date -r` or other macOS-compatible approach)

Reference: `docs/learnings/bash-compatibility.md`

**Severity:** P1 (blocking) -- code will break on macOS.

### 4. Convention Check

Verify changed scripts follow CLAUDE.md conventions:
- `set -euo pipefail` present
- Variables quoted: `"$var"` not `$var`
- `[[ ]]` not `[ ]` for tests
- `local` for function variables
- Source guards for new modules
- `snake_case` function names

**Severity:** P2 (should fix) -- inconsistency.

### 5. Security Check

Look for:
- Hardcoded paths to real user directories
- Secrets or credentials
- Unvalidated user input used in commands
- Missing `2>/dev/null` on commands that may fail
- Pipefail violations (commands that fail silently)

**Severity:** P1-P2 depending on nature.

### 6. Test Coverage Check

For each changed module, check if corresponding test file exists and covers the changes:
- New function in `lib/clean/foo.sh` -> test in `tests/clean_foo.bats`?
- New behavior -> new `@test` case?

**Severity:** P2 (should fix) -- no regression protection without tests.

## Output Format

```markdown
## Review: <summary>

### P1 (Must Fix)
- [ ] file.sh:42 -- Direct rm -rf usage, must use safe_remove
- [ ] file.sh:18 -- Uses declare -A, not bash 3.2 compatible

### P2 (Should Fix)
- [ ] file.sh:7 -- Missing set -euo pipefail
- [ ] file.sh:30 -- Unquoted variable: $path

### P3 (Consider)
- [ ] file.sh:55 -- Could use safe_find_delete instead of manual find+rm

### Passed
- Safe file operations: OK
- BSD commands: OK
```

## Rules

- P1 findings are **blocking**. Fix before closing the bead.
- P2 findings should be fixed in the same PR.
- P3 findings are optional, note for future improvement.
