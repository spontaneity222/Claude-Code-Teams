#!/usr/bin/env bash
# TeammateIdle hook: enforce quality checks when a teammate goes idle.
#
# Usage in settings.json:
#   {
#     "hooks": {
#       "TeammateIdle": [{
#         "matcher": "",
#         "hooks": [{ "type": "command", "command": "scripts/check-teammate-quality.sh" }]
#       }]
#     }
#   }
#
# Exit codes:
#   0 — teammate may go idle (quality checks passed or not applicable)
#   2 — block idle; feedback written to stdout will be sent back to the teammate

set -euo pipefail

# Parse the JSON payload from stdin
PAYLOAD=$(cat)

TEAMMATE_NAME=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('teammate_name', ''))" 2>/dev/null || echo "")
TASK_ID=$(echo "$PAYLOAD" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('task_id', ''))" 2>/dev/null || echo "")

# Only enforce checks if a task was assigned
if [[ -z "$TASK_ID" ]]; then
  exit 0
fi

ISSUES=()

# Check 1: ensure tests pass if any test files were modified
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '\.(test|spec)\.(ts|js|py)$'; then
  if ! npm test --silent 2>/dev/null; then
    ISSUES+=("Tests are failing. Fix failing tests before marking this task complete.")
  fi
fi

# Check 2: ensure no TypeScript errors if .ts files were modified
if git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '\.ts$'; then
  if command -v tsc &>/dev/null; then
    if ! tsc --noEmit --quiet 2>/dev/null; then
      ISSUES+=("TypeScript compilation errors found. Run 'tsc --noEmit' to see details and fix them.")
    fi
  fi
fi

# Check 3: ensure no obvious lint errors
if command -v eslint &>/dev/null && git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -qE '\.(ts|js)$'; then
  CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | grep -E '\.(ts|js)$' | head -20 || true)
  if [[ -n "$CHANGED_FILES" ]]; then
    if ! echo "$CHANGED_FILES" | xargs eslint --quiet 2>/dev/null; then
      ISSUES+=("ESLint errors found in changed files. Run 'eslint' on your changes and fix all errors.")
    fi
  fi
fi

# Report issues and block idle if any found
if [[ ${#ISSUES[@]} -gt 0 ]]; then
  echo "Quality gate failed for teammate '${TEAMMATE_NAME}' on task '${TASK_ID}':"
  echo ""
  for issue in "${ISSUES[@]}"; do
    echo "  - $issue"
  done
  echo ""
  echo "Please fix these issues before completing your task."
  exit 2
fi

exit 0
