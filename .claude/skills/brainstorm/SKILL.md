# Brainstorm

Investigation-first brainstorming for Mole features and fixes.

## When to Use

Before ANY creative work: new features, new cleaning modules, behavior changes, refactoring. You MUST brainstorm before coding.

## Process

### Phase 1: Investigate (DO NOT WRITE CODE)

1. **Read the relevant source files.** Use Grep, Glob, and Read to understand the current implementation. Do not guess.
2. **Map the affected modules.** Which files in `lib/`, `bin/`, `cmd/`, or `tests/` are involved?
3. **Check for existing patterns.** Does the codebase already handle something similar? Look at nearby modules.
4. **Check docs/solutions/ and docs/learnings/.** Has this problem been encountered before?

### Phase 2: Ask Questions (ONE AT A TIME)

Ask the user clarifying questions to refine the idea:

- What specific outcome do you want?
- Are there edge cases or constraints?
- Should this be behind `--dry-run`?
- Does this need sudo?
- What's the testing strategy?

Ask ONE question, wait for the answer, then ask the next. Do not dump all questions at once.

### Phase 3: Design Document

After investigation and Q&A, produce a design document:

```markdown
# Design: <Feature Name>

## Problem
What we're solving and why.

## Current State
What exists today (with file references).

## Proposed Solution
How we'll solve it, with specific file changes.

## Files to Modify
- `lib/clean/new_module.sh` -- New file
- `bin/clean.sh` -- Wire new module into dispatcher
- `tests/clean_new_module.bats` -- New test file

## Safety Considerations
- Does this touch protected paths?
- Does it need safe_remove wrappers?
- Does it need dry-run support?

## Test Strategy
- Unit tests in BATS
- What edge cases to cover
```

Save to `docs/plans/YYYY-MM-DD-<type>-<name>-plan.md`.

### Phase 4: Chain to Implementation

After user approves the design:
- If using beads: "Ready to create a beads epic from this plan. Run /plan-to-epic."
- If simple task: Proceed directly to implementation.

## Rules

- **NEVER write code during brainstorming.** Investigation only.
- **ALWAYS read actual source files.** Do not rely on memory or assumptions.
- **ALWAYS check docs/learnings/.** Existing knowledge may apply.
- **ONE question at a time.** Wait for answers.
