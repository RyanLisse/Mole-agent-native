# Plan to Epic

Converts a design document from `docs/plans/` into a beads epic with structured tasks.

## When to Use

After brainstorming produces an approved design document. Converts the plan into actionable, tracked beads tasks.

## Process

### Step 1: Read the Plan

Read the design document from `docs/plans/`. Extract:
- All proposed file changes
- The logical ordering of work
- Safety considerations
- Test requirements

### Step 2: Create the Epic

```bash
bd create "<Feature Name>" -t epic -p <priority>
```

Priority levels:
- 0 = Critical (blocking other work)
- 1 = High (important feature)
- 2 = Normal (standard work)
- 3 = Low (nice to have)

### Step 3: Create Tasks

For each logical unit of work, create a task with three fields:

```bash
bd create "<task title>" \
  --parent <epic-id> \
  -p <priority> \
  -d "<description: mechanics of what to do>" \
  --acceptance "<completion criteria>" \
  --design "<architectural context for judgment calls>"
```

**Task splitting rules:**
- Each task should be completable in one focused session
- Each task should be independently testable
- Each task should touch a small, coherent set of files

### Step 4: Detect File Overlaps

If two tasks modify the same file, note this as a dependency. Tasks sharing files should be ordered sequentially, not parallelized.

Add a comment noting the dependency:
```bash
bd comment <later-task-id> "Depends on <earlier-task-id> -- both modify <file>"
```

### Step 5: Add Test Tasks

For every implementation task, ensure there's a corresponding test requirement in the acceptance criteria. If testing is complex, create a separate test task.

### Step 6: Verify Structure

```bash
bd epic status <epic-id>
```

Confirm:
- [ ] All plan items are covered by tasks
- [ ] Each task has description, design, and acceptance fields
- [ ] File overlaps are noted as dependencies
- [ ] Priority ordering reflects logical dependencies
- [ ] Test coverage is addressed

### Output

Print the epic status and announce readiness:
"Epic <id> created with N tasks. Run `/epic-executor <id>` to begin execution."

## Rules

- **Embed context, don't reference it.** Each task must contain everything a fresh subagent needs. Don't say "see the plan doc" -- copy the relevant context into the task.
- **Acceptance criteria are non-negotiable.** If a task doesn't have clear completion criteria, it's not ready.
- **Keep tasks small.** A task that touches more than 3-4 files is probably too big.
