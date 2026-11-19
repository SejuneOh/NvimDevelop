#!/usr/bin/env bash
# Injects the /readable skill rules into every turn's context.
set -uo pipefail

SKILL="$HOME/.claude/skills/readable/SKILL.md"
[ -r "$SKILL" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

sed '1,/^---$/d' "$SKILL" | jq -Rs '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: ("아래 readable 규칙을 이번 답변에 적용한다. 사용자가 /readable 을 입력하지 않아도 항상 적용한다.\n\n" + .)
  },
  suppressOutput: true
}'
