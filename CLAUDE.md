# Mole

Mole is a macOS system cleaner CLI tool that combines CleanMyMac, AppCleaner, DaisyDisk, and iStat Menus into a single binary. It deep-cleans caches, uninstalls apps with remnant detection, optimizes system services, visualizes disk usage, and monitors system health.

**Version:** 1.25.0
**License:** MIT
**Platforms:** macOS 10.14+ (Intel & Apple Silicon)
**Languages:** Bash 3.2+ (main CLI), Go 1.24+ (TUI components)

## Architecture

```
mole                          # Main entry point (Bash)
bin/
  clean.sh                    # Deep cleanup dispatcher
  uninstall.sh                # App uninstaller dispatcher
  optimize.sh                 # System optimization dispatcher
  analyze.sh                  # Disk analyzer dispatcher (launches Go TUI)
  status.sh                   # System monitor dispatcher (launches Go TUI)
  purge.sh                    # Project artifact purge
  installer.sh                # Installer file cleanup
  check.sh                    # Health check
  touchid.sh                  # Touch ID for sudo
  completion.sh               # Shell completion setup
lib/
  core/                       # Foundation layer (loaded by all modules)
    common.sh                 # Colors, logging, utilities -- LOAD THIS FIRST
    file_ops.sh               # Safe file operations with path validation
    commands.sh               # Subcommand routing
    ui.sh                     # UI components (spinners, progress bars)
    base.sh                   # Timeout/execution primitives
    sudo.sh                   # Privilege escalation
    log.sh                    # Operation logging to ~/.config/mole/operations.log
    timeout.sh                # Timeout wrapper
    app_protection.sh         # Critical app/system component detection
  clean/                      # Cleaning modules (each handles one domain)
    caches.sh                 # System and user cache cleanup
    system.sh                 # System-level cleanup (logs, tmp)
    user.sh                   # User-level cleanup (browser data, etc.)
    apps.sh                   # Orphaned app data detection
    app_caches.sh             # Per-app cache cleanup
    brew.sh                   # Homebrew cleanup
    dev.sh                    # Developer tool caches
    project.sh                # Project build artifacts
  optimize/
    tasks.sh                  # Individual optimization tasks
    maintenance.sh            # System maintenance routines
  uninstall/
    batch.sh                  # Batch app uninstallation
    brew.sh                   # Homebrew cask uninstallation
  manage/
    whitelist.sh              # User whitelist management
    purge_paths.sh            # Purge path configuration
    autofix.sh                # Auto-fix routines
    update.sh                 # Self-update
  check/
    all.sh                    # Health checks
    health_json.sh            # Machine-readable health output
  ui/
    menu_paginated.sh         # Paginated menu system
    menu_simple.sh            # Simple menu system
    app_selector.sh           # Interactive app selector
cmd/
  analyze/                    # Go TUI: disk usage visualizer (Bubble Tea)
    main.go                   # Entry point
    scanner.go                # Directory scanner with xxhash
    view.go                   # TUI rendering
    cache.go, cleanable.go, constants.go, delete.go, format.go, heap.go
  status/                     # Go TUI: system monitor dashboard (Bubble Tea)
    main.go                   # Entry point
    metrics.go                # Metrics collection coordinator
    view.go                   # TUI rendering
    metrics_cpu.go, metrics_memory.go, metrics_disk.go, metrics_network.go,
    metrics_gpu.go, metrics_battery.go, metrics_bluetooth.go,
    metrics_hardware.go, metrics_health.go, metrics_process.go
tests/                        # BATS test suite (180+ test cases)
scripts/
  check.sh                   # Quality checks: format + lint + syntax
  test.sh                     # Test runner: lint + BATS + Go tests
  quick-check.sh              # Fast changed-files-only validation (<10s)
  bd                          # Beads task tracker (git-backed)
  pre-commit                  # Pre-commit hook (syntax + shellcheck + format)
  commit-msg                  # Commit message convention enforcement
  install-hooks.sh            # Install git hooks
  setup-quick-launchers.sh    # Raycast/Alfred integration
.claude/
  settings.json               # SessionStart hooks, tool permissions
  skills/
    brainstorm/SKILL.md       # Investigation-first brainstorming
    plan-to-epic/SKILL.md     # Convert plans to beads epics
    epic-executor/SKILL.md    # Sequential task execution with review
    review/SKILL.md           # Mole-specific multi-perspective review
    compound/SKILL.md         # Knowledge capture after fixes
    audit/SKILL.md            # Agent-native scoring audit
.beads/                        # Persistent task state (git-tracked)
docs/
  plans/                       # Design documents and implementation plans
  solutions/                   # Captured bug fixes (compound docs)
  learnings/                   # Reusable patterns and knowledge
```

## Commands

```bash
# Run quality checks (formats code, then lints)
./scripts/check.sh

# Run quality checks without formatting
./scripts/check.sh --no-format

# Format only
./scripts/check.sh --format

# Run all tests
./scripts/test.sh

# Run specific BATS test file
bats tests/core_common.bats

# Build Go binaries (local architecture)
make build

# Build Go binaries for release
make release-amd64
make release-arm64

# Go development
go build ./...
go vet ./cmd/...
go test ./cmd/...

# Quick check (changed files only, <10 seconds)
./scripts/quick-check.sh

# Syntax check individual scripts
bash -n mole
bash -n bin/clean.sh

# Beads task tracker
bd ready                     # What tasks are actionable?
bd epic status bd-XXXX       # Epic progress
bd show bd-XXXX.N            # Task details
bd create "title" --parent bd-XXXX  # Add task to epic

# Install git hooks (pre-commit + commit-msg)
./scripts/install-hooks.sh
```

## Code Conventions

### Bash (Primary Language)

- **Bash 3.2+ compatible** -- macOS default. No `declare -A`, no `${var,,}`, no `|&`.
- `set -euo pipefail` in all scripts
- 4-space indentation (enforced by shfmt: `-i 4 -ci -sr`)
- Quote all variables: `"$variable"`, not `$variable`
- Use `[[ ]]` for tests, not `[ ]`
- Use `local` for function variables, `readonly` for constants
- Function names: `snake_case`
- BSD commands (macOS native): `stat -f%z` not `stat --format`, `sed -i ''` not `sed -i`
- Comments explain **why**, not what
- Debug output: `echo "[MODULE_NAME] message" >&2` when `MO_DEBUG=1`

### Go (TUI Components)

- Go 1.24+ with modules
- Each file focused on single responsibility
- Extract constants, no magic numbers
- Context for timeout control on external commands
- Formatted with goimports (local: `github.com/tw93/Mole`)

### File Operations -- CRITICAL

**Never use `rm -rf` directly.** Always use safe wrappers from `lib/core/file_ops.sh`:

```bash
safe_remove "/path/to/file"              # Single file/directory
safe_find_delete "$dir" "*.log" 7 "f"    # Purge old files
safe_sudo_remove "/Library/Caches/x"     # With sudo
```

These wrappers validate paths (reject empty, `/../`, control chars, system paths) and log all operations.

### Protected Paths (NEVER delete)

```
/ /System /bin /sbin /usr /etc /var /Library/Extensions /private
```

Exceptions for specific system caches are listed in `lib/core/file_ops.sh:60-78`.

## Safety Rules

1. All file deletions route through `lib/core/file_ops.sh`
2. Path validation rejects: empty paths, `/../`, control characters, system root paths
3. `com.apple.*` LaunchAgents/Daemons are never touched
4. VPN tools, AI tools, and critical system components are protected (see `lib/core/app_protection.sh`)
5. Time Machine running? Skip cleanup. Status unclear? Also skip.
6. Orphan detection requires: app missing from all 3 locations + untouched 60+ days
7. Dry-run mode (`--dry-run`) available for preview
8. Operations logged to `~/.config/mole/operations.log`

## Adding a New Cleaning Module

1. Create `lib/clean/your_module.sh` with `set -euo pipefail`
2. Add source guard: `if [[ -n "${MOLE_YOUR_MODULE_LOADED:-}" ]]; then return 0; fi`
3. Source dependencies: `lib/core/common.sh`, `lib/core/file_ops.sh`
4. Use `safe_remove` / `safe_find_delete` for all deletions
5. Add corresponding test file: `tests/clean_your_module.bats`
6. Wire into `bin/clean.sh` dispatcher
7. Run `./scripts/check.sh && ./scripts/test.sh`

## Adding a BATS Test

```bash
#!/usr/bin/env bats
# tests/your_test.bats

setup() {
    TEST_DIR="$(mktemp -d "${TMPDIR:-/tmp}/tmp-home.XXXXXX")"
    export HOME="$TEST_DIR"
    source "$BATS_TEST_DIRNAME/../lib/core/common.sh"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "describe what is being tested" {
    # arrange
    mkdir -p "$TEST_DIR/Library/Caches/test"
    # act
    result=$(your_function "$TEST_DIR")
    # assert
    [[ "$result" == "expected" ]]
}
```

## CI/CD

- **test.yml**: Unit/integration tests on push to main/dev and PRs. macOS-latest + compatibility matrix (macOS-14, macOS-15). Security checks for unsafe rm, app protection, hardcoded secrets.
- **check.yml**: Auto-format (shfmt, goimports) + lint (shellcheck, golangci-lint) + syntax check. Auto-commits formatting fixes.
- **release.yml**: Triggered by `V*` tags. Builds amd64/arm64 binaries, creates GitHub release, updates Homebrew formulas.
- **dependabot.yml**: Weekly updates for GitHub Actions and Go modules.

## PR Convention

- Submit PRs to `dev` branch, not `main`
- Run `./scripts/check.sh && ./scripts/test.sh` before pushing
- Commit messages: `<type>(<scope>): <description>`
  - Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `security`
  - Scopes: `core`, `clean`, `optimize`, `analyze`, `status`, `uninstall`, `ci`, `purge`

## Task Management (Beads Workflow)

This project uses **beads** (`scripts/bd`) for persistent task tracking across agent sessions.

### Rules

- **ALWAYS** check `bd ready` before asking "what should I work on?"
- **ALWAYS** run `bd update <id> --claim` when starting a task
- **ALWAYS** close tasks when done: `bd close <id> --reason "explanation"`
- **ALWAYS** include bead IDs in commit messages: `feat(core): add X (bd-0001.3)`
- **NEVER** use markdown TODO lists for tracking work -- use beads
- Run `bd sync` at end of session to stage state for commit

### Workflow: Plan -> Work -> Review -> Compound

1. **Plan**: Brainstorm and investigate before coding. Write plan to `docs/plans/`.
2. **Work**: Execute tasks from `bd ready`, one at a time, sequentially.
3. **Review**: Two-stage -- spec compliance first, code quality second. Fix before closing.
4. **Compound**: After fixes, capture learnings in `docs/solutions/` or `docs/learnings/`.

### Common Commands

```bash
bd ready                        # What's actionable right now?
bd epic status bd-XXXX          # Overall progress on an epic
bd show bd-XXXX.N               # Full context for a task
bd update bd-XXXX.N --claim     # Claim and start working
bd close bd-XXXX.N              # Mark complete
bd comment bd-XXXX.N "notes"    # Add context for future sessions
bd list --status open           # All open issues
```

### Landing the Plane (End of Session)

Before ending any session:
1. Update bead statuses (`bd update` / `bd close` for completed work)
2. Run `./scripts/check.sh` and `./scripts/test.sh`
3. `bd sync` to stage beads state
4. Commit and push

## Key Learnings

- 2026-02-09: This codebase uses BSD commands (macOS native), not GNU. `stat -f%z` not `stat --format`. `sed -i ''` not `sed -i`.
- 2026-02-09: Bash 3.2 compatibility is strict. No associative arrays (`declare -A`), no lowercase transform (`${var,,}`), no `|&` pipe.
- 2026-02-09: All file operations MUST go through `lib/core/file_ops.sh` wrappers. Direct `rm` usage will fail security CI checks.
- 2026-02-09: Test environment uses `TMPDIR` temp directories with fake `$HOME` to avoid touching real system.
