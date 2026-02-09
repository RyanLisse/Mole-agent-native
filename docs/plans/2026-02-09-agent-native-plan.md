# Agent-Native Transformation Plan for Mole

**Date:** 2026-02-09
**Type:** Architecture / Process
**Status:** Proposed

## Executive Summary

Transform Mole from a well-engineered traditional CLI project into a 100% agent-native codebase using the compound engineering methodology (Plan -> Work -> Review -> Compound). This means every unit of engineering work compounds -- making subsequent work easier, not harder.

## Current State Audit

### What Mole Already Does Well

| Principle | Current State | Score |
|-----------|--------------|-------|
| **Testing** | 180+ BATS tests, ~88% coverage, Go tests, CI-enforced | 8/10 |
| **Linting** | shellcheck + golangci-lint + shfmt, CI-enforced | 9/10 |
| **CI/CD** | 4 GitHub Actions workflows (test, check, release, contributors) | 8/10 |
| **Code Safety** | Safe wrappers, path validation, protected paths, dry-run | 9/10 |
| **Documentation** | CONTRIBUTING.md, SECURITY_AUDIT.md, README.md | 7/10 |
| **Modularity** | Single-responsibility files, clean lib/ structure | 8/10 |
| **Code Style** | EditorConfig, shellcheckrc, golangci.yml, enforced | 8/10 |

### What's Missing for Agent-Native

| Principle | Current State | Gap |
|-----------|--------------|-----|
| **CLAUDE.md** | Does not exist | Critical -- agents have no project context |
| **AGENTS.md** | Does not exist | No sub-agent working agreement |
| **Pre-commit hooks** | None (only CI gates) | Agents get no local feedback before push |
| **Knowledge compounding** | No docs/solutions/ or learnings system | Fixes don't compound into reusable knowledge |
| **SessionStart hooks** | None | Claude Code web sessions can't auto-setup |
| **Compound docs** | No pattern for capturing solved problems | Each fix is one-and-done |
| **Plan documents** | No docs/plans/ convention | No planning audit trail |
| **Structured commit messages** | No enforced convention | Agents can't parse commit history |

---

## Phase 1: Foundation (Agent Context Layer)

**Goal:** Give agents full project context so they can work autonomously.

### 1.1 Create CLAUDE.md

The single most impactful change. This file is the "system prompt" for every agent that touches the codebase. It must contain:

- **Project identity:** What Mole is, what it does, who it's for
- **Architecture map:** Directory structure, module responsibilities, data flow
- **Verification commands:** Exact commands to check, test, lint, build
- **Code conventions:** Style rules, safety patterns, naming conventions
- **Safety rules:** What agents must NEVER do (rm -rf, touch protected paths, etc.)
- **Key patterns:** How to add a new cleaning module, how to add a test, etc.
- **Key learnings:** Dated entries of important discoveries

**Why first:** Without CLAUDE.md, agents are flying blind. Every other improvement depends on agents understanding the project.

### 1.2 Create AGENTS.md

Working agreement for when Claude operates as a sub-agent (e.g., in multi-agent review workflows):

- Branch naming convention
- Safety boundaries (never push to main, never modify protected paths)
- Testing requirements before completing a task
- Output format expectations

### 1.3 Create .claude/ hooks

Configure SessionStart hooks so Claude Code web sessions automatically validate the environment:

- Check that required tools are available (shellcheck, shfmt, bats, go)
- Run syntax validation
- Display project context summary

---

## Phase 2: Feedback Loops (Reward Signals)

**Goal:** Agents need fast, local feedback -- not just CI results 20 minutes later.

### 2.1 Pre-commit hooks

Install git pre-commit hooks that run before every commit:

```
pre-commit:
  - bash -n on changed .sh files (syntax check)
  - shellcheck on changed .sh files
  - shfmt --diff on changed .sh files (format check)
  - go vet ./cmd/... (if Go files changed)
```

**Why:** Agents get immediate feedback. Bad code never makes it to CI. This is the "reward signal" that tells agents whether their work succeeded.

### 2.2 Quick-check script

Create a `scripts/quick-check.sh` that runs in <10 seconds:

- Syntax check on changed files only
- ShellCheck on changed files only
- Format diff check (no auto-fix, just report)

This is the fast feedback loop agents run after every edit, vs the full `scripts/check.sh` which reformats everything.

### 2.3 Structured test runner output

Ensure test output is machine-parseable:

- Use TAP format consistently
- Add exit codes that distinguish "test failed" from "test errored"
- Print summary line: `X passed, Y failed, Z skipped`

---

## Phase 3: Knowledge Compounding

**Goal:** Every solved problem becomes permanent institutional knowledge.

### 3.1 docs/solutions/ directory

Structure for capturing solved problems:

```
docs/solutions/
  build-errors/
  test-failures/
  shell-compatibility/
  macos-quirks/
  performance/
  security/
```

Each solution file follows the compound docs schema:

```yaml
---
title: "Fix for stat -f%z on macOS Sonoma"
module: lib/core/file_ops.sh
symptom: "stat command returns empty on mounted volumes"
root_cause: "macOS 15 changed stat behavior for NFS volumes"
solution: "Add fallback to wc -c when stat returns empty"
prevention: "Always test file size functions on network volumes"
date: 2026-02-09
---
```

### 3.2 docs/learnings/ directory

For broader patterns and insights that aren't tied to a single bug fix:

- `bash-compatibility.md` -- Bash 3.2 gotchas and patterns
- `macos-versions.md` -- Version-specific behaviors
- `safe-file-ops.md` -- Patterns for safe file operations
- `testing-patterns.md` -- How to write effective BATS tests

### 3.3 Key Learnings section in CLAUDE.md

A dated, concise section at the bottom of CLAUDE.md where agents record important discoveries:

```markdown
## Key Learnings

- 2026-02-09: BSD stat uses `-f%z` not `--format`, always use `get_file_size` wrapper
- 2026-02-09: Arrays in Bash 3.2 don't support `[@]:offset:length` with associative arrays
```

This is the fastest-access knowledge layer -- always loaded into agent context.

---

## Phase 4: Workflow Integration

**Goal:** Formalize the Plan -> Work -> Review -> Compound cycle.

### 4.1 Plan convention

All non-trivial changes start with a plan document in `docs/plans/`:

```
docs/plans/YYYY-MM-DD-<type>-<name>-plan.md
```

Types: `feature`, `fix`, `refactor`, `infra`, `security`

Plans include:
- Problem statement
- Research findings (what exists, what patterns to follow)
- Implementation steps
- Test strategy
- Risk assessment

### 4.2 Structured PR template

Update `.github/ISSUE_TEMPLATE/` and add a PR template:

```markdown
## Summary
<!-- 1-3 bullet points -->

## Plan
<!-- Link to docs/plans/ document, or "N/A - trivial change" -->

## Test strategy
<!-- How was this tested? -->

## Knowledge captured
<!-- Link to docs/solutions/ or docs/learnings/ updates, or "N/A" -->
```

### 4.3 Commit message convention

Adopt a structured format that agents can parse and learn from:

```
<type>(<scope>): <description>

Types: feat, fix, refactor, test, docs, chore, security
Scopes: core, clean, optimize, analyze, status, uninstall, ci, purge
```

---

## Phase 5: Agent-Native Architecture Scoring

**Goal:** Measure progress against the 8-principle audit from compound engineering.

### Current Estimated Scores

| # | Principle | Mole Score | Notes |
|---|-----------|-----------|-------|
| 1 | **Action Parity** | N/A | CLI tool -- users and agents use the same interface (the shell) |
| 2 | **Tools as Primitives** | 8/10 | Modular lib/ structure with atomic functions |
| 3 | **Context Injection** | 1/10 | No CLAUDE.md, no dynamic context |
| 4 | **Shared Workspace** | 9/10 | Filesystem is the shared workspace |
| 5 | **CRUD Completeness** | 7/10 | Clean/optimize/analyze work, but no undo |
| 6 | **UI Integration** | N/A | CLI -- output is immediate |
| 7 | **Capability Discovery** | 3/10 | --help exists but no agent-friendly discovery |
| 8 | **Prompt-Native Features** | 2/10 | No CLAUDE.md, no skills, no prompt-defined behaviors |

### Target Scores After Implementation

| # | Principle | Target | How |
|---|-----------|--------|-----|
| 1 | Action Parity | 10/10 | CLI already has parity; document it |
| 2 | Tools as Primitives | 9/10 | Already strong; document patterns |
| 3 | Context Injection | 9/10 | CLAUDE.md + AGENTS.md + docs/ structure |
| 4 | Shared Workspace | 10/10 | Already strong; filesystem is workspace |
| 5 | CRUD Completeness | 8/10 | Document capabilities and limitations |
| 6 | UI Integration | N/A | CLI paradigm |
| 7 | Capability Discovery | 8/10 | CLAUDE.md maps all capabilities |
| 8 | Prompt-Native Features | 7/10 | Plans, solutions, learnings as prompts |

---

## Phase 6: Continuous Improvement

### 6.1 Compound trigger

After every significant fix or feature, capture the learning:

1. What was the problem?
2. What was the root cause?
3. How was it fixed?
4. How can it be prevented?

This becomes a docs/solutions/ entry.

### 6.2 Periodic audit

Monthly, review:

- Are agents successfully completing tasks without human intervention?
- What patterns of failure exist?
- What knowledge is missing from CLAUDE.md?
- Are docs/solutions/ entries being created?

### 6.3 CLAUDE.md evolution

CLAUDE.md is a living document. It should be updated:

- When a new module is added
- When a convention changes
- When a common mistake is discovered
- When a new tool or dependency is introduced

---

## Implementation Priority

| Priority | Item | Impact | Effort |
|----------|------|--------|--------|
| P0 | CLAUDE.md | Highest -- unlocks all agent work | Medium |
| P0 | AGENTS.md | High -- enables multi-agent workflows | Low |
| P1 | Pre-commit hooks | High -- fast feedback loop | Low |
| P1 | docs/ structure | High -- knowledge compounding | Low |
| P1 | .claude/ hooks | Medium -- web session support | Low |
| P2 | PR template | Medium -- workflow formalization | Low |
| P2 | Commit convention | Medium -- parseable history | Low |
| P2 | quick-check.sh | Medium -- faster agent feedback | Low |
| P3 | Compound docs capture | Medium -- long-term compounding | Ongoing |
| P3 | Monthly audit | Low -- continuous improvement | Ongoing |

---

## Success Criteria

The codebase is 100% agent-native when:

- [ ] An agent can read CLAUDE.md and understand the entire project without asking questions
- [ ] An agent can run tests, lint, and build with commands from CLAUDE.md
- [ ] An agent can add a new cleaning module by following patterns documented in CLAUDE.md
- [ ] An agent can fix a bug and capture the learning in docs/solutions/
- [ ] Pre-commit hooks catch issues before they reach CI
- [ ] Every PR links to a plan document (for non-trivial changes)
- [ ] Knowledge compounds: agents reference docs/solutions/ when encountering similar issues
- [ ] The codebase works better after 3 months of agent use than on day one

## References

- [Compound Engineering: How Every Codes With Agents](https://every.to/chain-of-thought/compound-engineering-how-every-codes-with-agents)
- [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin)
- [Learning from Every's Compound Engineering](https://lethain.com/everyinc-compound-engineering/)
- [Agent-Native Engineering](https://www.generalintelligencecompany.com/writing/agent-native-engineering)
