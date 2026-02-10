# Bash 3.2 Compatibility Guide

Mole targets macOS default Bash (3.2). This doc captures patterns that work and patterns that break.

## Forbidden Constructs

| Construct | Bash 4+ Only | Use Instead |
|-----------|-------------|-------------|
| `declare -A` | Associative arrays | Parallel indexed arrays or case statements |
| `${var,,}` | Lowercase transform | `echo "$var" \| tr '[:upper:]' '[:lower:]'` |
| `${var^^}` | Uppercase transform | `echo "$var" \| tr '[:lower:]' '[:upper:]'` |
| `\|&` | Pipe stderr | `2>&1 \|` |
| `readarray` / `mapfile` | Read into array | `while IFS= read -r` loop |
| `${!prefix@}` | Variable name expansion | Avoided; use explicit lists |
| `&>>` | Append both streams | `>> file 2>&1` |
| `coproc` | Coprocess | Named pipes or temp files |

## Safe Patterns

### Reading into arrays
```bash
# CORRECT (3.2 compatible)
local items=()
while IFS= read -r line; do
    items+=("$line")
done < <(some_command)

# WRONG (requires bash 4+)
readarray -t items < <(some_command)
```

### Case-insensitive comparison
```bash
# CORRECT
if [[ "$(echo "$var" | tr '[:upper:]' '[:lower:]')" == "value" ]]; then

# WRONG (bash 4+)
if [[ "${var,,}" == "value" ]]; then
```

### Arithmetic edge cases
```bash
# CORRECT (handles zero without set -e failure)
((count++)) || true

# WRONG (exits with set -e when count is 0)
((count++))
```

## BSD vs GNU Commands

| Operation | BSD (macOS) | GNU (Linux) |
|-----------|-------------|-------------|
| File size | `stat -f%z file` | `stat --format=%s file` |
| In-place sed | `sed -i '' 's/a/b/' file` | `sed -i 's/a/b/' file` |
| Date formatting | `date -r timestamp` | `date -d @timestamp` |
| Extended regex | `grep -E` or `sed -E` | Same (but behavior may differ) |
| Sort stability | Not guaranteed | `sort -s` for stable |
