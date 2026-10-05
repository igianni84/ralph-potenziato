#!/bin/bash
# =============================================================================
# Ralph Piano — autonomous loop over the phases of a Markdown plan
#
# Does what you would do by hand: open a fresh Claude Code session, say
# "proceed with the next phase of plan X", wait, /clear, repeat.
# The plan file is the only state: its `> **Stato**` line and its
# `## Consegne tra le fasi` handoff block (see RALPH-PIANO.md). No JSON.
#
# Usage: ./ralph-piano.sh <plan.md> [max_iterations]      (default 10)
#
# Stops when the agent ends its reply with one of:
#   <promise>FASE_CHIUSA</promise>     phase closed, next one is Claude's → next iteration
#   <promise>GATE</promise> <why>      a human is needed (push, deploy, decision, manual test, failure)
#   <promise>PIANO_COMPLETO</promise>  nothing left
# No signal = the session died or ran out of context: the loop stops, the output
# is in tasks/.ralph-piano-last and the next run hands it to the agent first.
#
# Backend: .codex/ralph-agent.sh if present (RALPH_AGENT=claude|codex), else
# claude --print --dangerously-skip-permissions --effort max (+ CLAUDE_FLAGS).
# Exit codes: 0 complete · 1 no signal / max iterations · 2 gate.
# =============================================================================
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PLAN="${1:?usage: ./ralph-piano.sh <plan.md> [max_iterations]}"
MAX="${2:-10}"
[ -f "$PLAN" ] || { echo "Plan not found: $PLAN" >&2; exit 1; }

LAST="tasks/.ralph-piano-last"
LOG="tasks/ralph-piano.log"
mkdir -p tasks

if [ -x .codex/ralph-agent.sh ]; then
  AGENT=(bash .codex/ralph-agent.sh)
else
  # shellcheck disable=SC2206
  AGENT=(claude --print --dangerously-skip-permissions --effort "${RALPH_EFFORT:-max}" ${CLAUDE_FLAGS:-})
fi

log() { echo "- $(date '+%Y-%m-%d %H:%M') · $(basename "$PLAN") · iter $1 · $2" | tee -a "$LOG"; }

echo "Ralph Piano — $PLAN — max $MAX iterations"
for i in $(seq 1 "$MAX"); do
  echo; echo "=== Iteration $i of $MAX — $(date '+%H:%M') ==="
  PREV=""
  [ -f "$LAST" ] && PREV="- Previous iteration ended WITHOUT a signal. Its output is in $LAST: read it first."
  OUTPUT=$({ printf '## Run context\n- Plan: %s\n- Iteration: %s of %s\n%s\n\nProceed with the next phase of plan %s.\n\n' "$PLAN" "$i" "$MAX" "$PREV" "$PLAN"; cat RALPH-PIANO.md; } | "${AGENT[@]}" | tee /dev/stderr) || true

  if echo "$OUTPUT" | grep -q '<promise>PIANO_COMPLETO</promise>'; then
    rm -f "$LAST"; log "$i" "PIANO_COMPLETO"; exit 0
  elif echo "$OUTPUT" | grep -q '<promise>GATE</promise>'; then
    rm -f "$LAST"; log "$i" "$(echo "$OUTPUT" | grep -m1 '<promise>GATE</promise>')"; exit 2
  elif echo "$OUTPUT" | grep -q '<promise>FASE_CHIUSA</promise>'; then
    rm -f "$LAST"; log "$i" "FASE_CHIUSA"
  else
    # ponytail: no automatic retry — relaunch by hand; add one if a missing signal turns out common
    echo "$OUTPUT" | tail -100 > "$LAST"; log "$i" "NO SIGNAL — see $LAST"; exit 1
  fi
done
log "$MAX" "max iterations reached"; exit 1
