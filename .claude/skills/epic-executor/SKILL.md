# Epic Executor

Sequential task execution with two-stage review. The core execution loop of the beads workflow.

## When to Use

After a beads epic has been created (via `/plan-to-epic` or manually). Executes all tasks in order until the epic is complete.

## Usage

```
/epic-executor <epic-id>
```

Example: `/epic-executor bd-0001`

## Execution Loop

### 1. Check Epic Status

```bash
bd epic status <epic-id>
```

If 100% complete, announce completion and stop.

### 2. Get Next Ready Task

```bash
bd ready
```

Pick the highest-priority open task from this epic. If a task has a dependency comment, ensure the dependency is closed first.

### 3. Claim the Task

```bash
bd update <task-id> --claim
```

### 4. Read Task Context

```bash
bd show <task-id>
```

Read the description, design, and acceptance fields. This is ALL the context you need. Do not rely on earlier conversation context.

### 5. Implement

- Read the relevant source files first
- Make changes following CLAUDE.md conventions
- Use `safe_remove` for all file deletions
- Bash 3.2 compatible, BSD commands
- Run `./scripts/quick-check.sh` after changes

### 6. Two-Stage Review

#### Stage 1: Spec Compliance
- Does the implementation satisfy ALL acceptance criteria?
- Were design decisions from the `design` field respected?
- Does the output match what was specified?

If spec compliance fails: fix the issues and re-check.

#### Stage 2: Code Quality
- Does it follow CLAUDE.md code conventions?
- Are there security concerns? (unsafe rm, unvalidated paths)
- Is it Bash 3.2 compatible?
- Are variables quoted? Functions using `local`?
- Is there test coverage?

If code quality fails: fix the issues and re-check.

### 7. Close the Task

```bash
bd close <task-id> --reason "Brief summary of what was done"
```

### 8. Loop

Go back to step 1. Continue until epic is 100% complete.

## Principles

- **Sequential execution.** One task at a time. No parallel conflicts.
- **Fix before closing.** Tasks with review issues get fixed, not skipped.
- **Fresh context per task.** Read `bd show` for each task -- don't carry assumptions from previous tasks.
- **Commit after each task.** Each completed task gets its own commit with the bead ID.

## Commit Format

```
type(scope): description (bd-XXXX.N)
```

Example: `feat(clean): add Docker cache cleanup module (bd-0001.3)`

## When Blocked

If a task cannot be completed:
1. Add a comment explaining the blocker: `bd comment <id> "Blocked: reason"`
2. Do NOT close the task
3. Move to the next ready task
4. Return to blocked tasks after the blocker is resolved
