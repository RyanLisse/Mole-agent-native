# Agents Working Agreement

Instructions for when Claude operates as a sub-agent (delegated task, multi-agent workflow, or autonomous mode).

## Branch Rules

- Create feature branches from `dev`: `claude/<feature>-<session-suffix>`
- Never push directly to `main` or `dev`
- Always create a PR targeting `dev`

## Safety Boundaries

- **Never** use `rm -rf` directly. Use `safe_remove` from `lib/core/file_ops.sh`.
- **Never** modify files under `/System`, `/bin`, `/sbin`, `/usr`, `/etc`, `/private`.
- **Never** remove or weaken path validation in `lib/core/file_ops.sh`.
- **Never** remove entries from the protected paths list or app protection list.
- **Never** skip `set -euo pipefail` in new scripts.
- **Never** commit secrets, credentials, or API keys.

## Before Completing Any Task

1. Run `./scripts/check.sh` -- all checks must pass
2. Run `./scripts/test.sh` -- all tests must pass
3. If you added new functionality, add corresponding tests in `tests/`
4. If you fixed a bug, capture the learning in `docs/solutions/`

## Code Changes Checklist

- [ ] Uses `safe_remove` / `safe_find_delete` for any file deletion
- [ ] Bash 3.2 compatible (no associative arrays, no `${var,,}`, no `|&`)
- [ ] Uses BSD commands (macOS native), not GNU variants
- [ ] Variables quoted: `"$variable"`
- [ ] Functions use `local` for variables
- [ ] New scripts have `set -euo pipefail`
- [ ] New scripts have source guards
- [ ] Tests added/updated for changes
- [ ] `./scripts/check.sh` passes
- [ ] `./scripts/test.sh` passes

## Commit Convention

```
<type>(<scope>): <description>
```

- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `security`
- Scopes: `core`, `clean`, `optimize`, `analyze`, `status`, `uninstall`, `ci`, `purge`

## Output Format

When completing a task, report:

1. **What changed:** List of modified files with one-line descriptions
2. **Tests:** Which tests pass, any new tests added
3. **Verification:** Output of `./scripts/check.sh` and `./scripts/test.sh`
4. **Knowledge captured:** Any docs/solutions/ or docs/learnings/ entries created

## Adding New Modules

Follow the pattern documented in CLAUDE.md under "Adding a New Cleaning Module". Every new module needs:

1. Source guard to prevent double-loading
2. Dependency sourcing
3. Safe file operations only
4. Corresponding BATS test file
5. Integration into the relevant dispatcher script
