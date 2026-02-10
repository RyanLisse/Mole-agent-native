# Agent-Native Audit

Scores the Mole codebase against the 8 agent-native principles from compound engineering.

## When to Use

Periodically (monthly or after major changes) to measure progress toward 100% agent-native.

Run: `/audit`

## The 8 Principles

Score each principle by examining the codebase. For each, count what's implemented vs what's possible.

### 1. Action Parity
**"Whatever the user can do, the agent can do."**

For a CLI tool, this means: can the agent run every `mo` subcommand, read all outputs, and make decisions based on results?

Check:
- [ ] All `mo` subcommands documented in CLAUDE.md
- [ ] Output formats are parseable (not just pretty-printed)
- [ ] `--dry-run` available for destructive operations
- [ ] `mo check --json` provides machine-readable health data

Score: X out of Y user actions have agent-accessible equivalents.

### 2. Tools as Primitives
**"Tools provide capability, not behavior."**

Check that lib/ functions are atomic and composable:
- [ ] `safe_remove` is a primitive (not `clean_all_caches`)
- [ ] Functions in lib/core/ are single-responsibility
- [ ] Cleaning modules can be called independently
- [ ] No god-functions that do everything

Score: X out of Y tools are proper primitives.

### 3. Context Injection
**"System prompt includes dynamic context about project state."**

Check:
- [ ] CLAUDE.md exists with project architecture
- [ ] CLAUDE.md has verification commands
- [ ] CLAUDE.md has code conventions
- [ ] CLAUDE.md has safety rules
- [ ] CLAUDE.md has key learnings
- [ ] CLAUDE.md has beads workflow rules
- [ ] .claude/settings.json has SessionStart hooks
- [ ] AGENTS.md exists for sub-agent work

Score: X out of 8 context types present.

### 4. Shared Workspace
**"Agent and user work in the same data space."**

For CLI tools, filesystem IS the shared workspace:
- [ ] Agent reads/writes the same files users do
- [ ] Config in `~/.config/mole/` is accessible
- [ ] Beads state in `.beads/` is git-tracked
- [ ] No separate "agent sandbox"

Score: X out of Y data stores shared.

### 5. CRUD Completeness
**"Every entity has full CRUD."**

Check each entity type:
- [ ] Cleaning modules: can add, list, run, skip (via whitelist)
- [ ] Beads tasks: create, read, update, close
- [ ] Whitelist entries: add, list, remove
- [ ] Purge paths: add, list, remove

Score: X out of Y entities with full CRUD.

### 6. UI Integration
**"Agent actions immediately reflected in UI."**

For CLI: output is the UI:
- [ ] All operations produce stdout/stderr feedback
- [ ] Exit codes indicate success/failure
- [ ] Progress indicators during long operations
- [ ] Summary output after operations

Score: X out of Y actions with immediate feedback.

### 7. Capability Discovery
**"Users can discover what the agent can do."**

Check:
- [ ] CLAUDE.md documents all capabilities
- [ ] `mo --help` shows all commands
- [ ] Skills are documented in .claude/skills/
- [ ] AGENTS.md describes working agreement
- [ ] docs/plans/ shows available plan templates
- [ ] Commit convention is documented
- [ ] Beads commands are documented

Score: X out of 7 discovery mechanisms.

### 8. Prompt-Native Features
**"Features are prompts defining outcomes, not code."**

Check:
- [ ] Skills define workflows via prose, not code
- [ ] New behaviors can be added by writing new skill files
- [ ] CLAUDE.md patterns guide agent behavior
- [ ] docs/learnings/ influence agent decisions
- [ ] Beads workflow is prompt-driven

Score: X out of Y features defined in prompts.

## Output Format

```markdown
## Agent-Native Audit: Mole

| # | Principle | Score | % | Status |
|---|-----------|-------|---|--------|
| 1 | Action Parity | X/Y | Z% | pass/partial/fail |
| 2 | Tools as Primitives | X/Y | Z% | pass/partial/fail |
| 3 | Context Injection | X/8 | Z% | pass/partial/fail |
| 4 | Shared Workspace | X/Y | Z% | pass/partial/fail |
| 5 | CRUD Completeness | X/Y | Z% | pass/partial/fail |
| 6 | UI Integration | X/Y | Z% | pass/partial/fail |
| 7 | Capability Discovery | X/7 | Z% | pass/partial/fail |
| 8 | Prompt-Native Features | X/Y | Z% | pass/partial/fail |

**Overall Score: X%**

### Status Key
- **pass** (80%+) -- Excellent
- **partial** (50-79%) -- Needs improvement
- **fail** (<50%) -- Needs work

### Top Recommendations
1. ...
2. ...
3. ...
```

## Rules

- Be honest. Under-scoring is better than over-scoring.
- Check actual files, don't rely on memory.
- Recommendations should be specific and actionable.
