# Compound Docs: Solutions

Captured solutions to problems encountered during development. Each file follows the YAML frontmatter schema below.

## Schema

```yaml
---
title: "Short description of the problem and fix"
module: "path/to/affected/file.sh"
symptom: "What was observed (error message, unexpected behavior)"
root_cause: "Why it happened (the actual bug or misunderstanding)"
solution: "What was done to fix it (code change, config change)"
prevention: "How to avoid this in the future (pattern, rule, test)"
date: YYYY-MM-DD
labels: [category1, category2]
---

## Details

Extended explanation if needed...
```

## Categories

Organize solutions into subdirectories:

- `build-errors/` -- Compilation, linking, and build failures
- `test-failures/` -- Test failures and flaky tests
- `shell-compatibility/` -- Bash 3.2 and BSD command issues
- `macos-quirks/` -- macOS version-specific behaviors
- `performance/` -- Performance regressions and fixes
- `security/` -- Security-related fixes

## Usage

When you encounter a problem and fix it, create a solution doc:

```bash
# Example filename
docs/solutions/shell-compatibility/stat-empty-on-nfs-volumes.md
```

Reference these docs in CLAUDE.md Key Learnings for quick agent access.
