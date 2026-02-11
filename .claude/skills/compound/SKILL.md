# Compound

Captures solved problems as permanent knowledge. Closes the Plan -> Work -> Review -> **Compound** loop.

## When to Use

After completing a fix, resolving a bug, or discovering a non-obvious pattern. Triggers on phrases like:
- "that worked"
- "it's fixed"
- "the bug was..."
- "turns out the issue was..."

Also usable standalone: `/compound` to document a recent fix.

## Process

### Step 1: Gather Context

Ask (or infer from conversation):

1. **Module:** Which file(s) were involved?
2. **Symptom:** What was observed? (error message, unexpected behavior)
3. **Investigation:** What did you check and rule out?
4. **Root cause:** Why did it happen?
5. **Solution:** What change fixed it?
6. **Prevention:** How to avoid this in the future?

### Step 2: Classify

Determine the category:
- `build-errors/` -- Compilation, linking, build failures
- `test-failures/` -- Test failures and flaky tests
- `shell-compatibility/` -- Bash 3.2 and BSD command issues
- `macos-quirks/` -- macOS version-specific behaviors
- `performance/` -- Performance regressions
- `security/` -- Security-related fixes

### Step 3: Check for Duplicates

Search `docs/solutions/` for existing entries about the same topic. If found, update rather than duplicate.

### Step 4: Write Solution Doc

Create `docs/solutions/<category>/<slug>.md`:

```markdown
---
title: "<Short description>"
module: "<path/to/file.sh>"
symptom: "<What was observed>"
root_cause: "<Why it happened>"
solution: "<What fixed it>"
prevention: "<How to avoid in future>"
date: YYYY-MM-DD
labels: [label1, label2]
---

## Details

<Extended explanation if the YAML fields don't capture everything>
```

### Step 5: Update Key Learnings

If the insight is broadly useful, add a one-liner to CLAUDE.md's Key Learnings section:

```markdown
- YYYY-MM-DD: <Concise insight that agents should know>
```

### Step 6: Update Learnings Docs

If the fix reveals a pattern that belongs in an existing learnings doc (e.g., `docs/learnings/bash-compatibility.md`), update it.

## Rules

- **Every non-trivial fix should produce a compound doc.** This is how knowledge compounds.
- **Solutions are structured, not prose.** Use the YAML schema.
- **One solution per file.** Don't stuff multiple fixes into one doc.
- **Keep Key Learnings concise.** One line per insight. Details go in docs/solutions/ or docs/learnings/.
