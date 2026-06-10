#!/bin/bash
# =============================================================================
# Ralph Wiggum — Long-running autonomous AI agent loop
#
# Iteratively launches Claude Code instances to implement user stories from a
# PRD JSON file. Each iteration picks the highest-priority unfinished story,
# implements it with tests, and marks it as passing. Stops when all stories
# pass or max iterations are reached.
#
# Usage: ./ralph.sh [--prd tasks/prd-module.json] [max_iterations]
#
# Examples:
#   ./ralph.sh                                    # tasks/prd.json, 10 iterations
#   ./ralph.sh --prd tasks/prd-module-a.json 20   # specific module, 20 iterations
#   ./ralph.sh 5                                  # tasks/prd.json, 5 iterations
#
# Prerequisites: claude CLI, jq
# =============================================================================

set -e

# ------------------------------------
# Argument parsing
# --prd <path>   Path to PRD JSON (relative to project root, default: tasks/prd.json)
# <number>       Max iterations (default: 10)
# ------------------------------------
MAX_ITERATIONS=10
PRD_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --prd)
      PRD_ARG="$2"
      shift 2
      ;;
    --prd=*)
      PRD_ARG="${1#*=}"
      shift
      ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then
        MAX_ITERATIONS="$1"
      fi
      shift
      ;;
  esac
done

# ------------------------------------
# Path resolution
# All paths are relative to the project root (SCRIPT_DIR).
# The progress file is derived from the PRD filename:
#   tasks/prd-module-a.json  →  tasks/progress-module-a.txt
#   tasks/prd.json           →  tasks/progress.txt
# ------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PRD_ARG="${PRD_ARG:-tasks/prd.json}"
PRD_FILE="$SCRIPT_DIR/$PRD_ARG"

if [ ! -f "$PRD_FILE" ]; then
  echo "Error: PRD file not found: $PRD_FILE"
  exit 1
fi

PRD_BASENAME="$(basename "$PRD_ARG" .json)"
PRD_DIRNAME="$(dirname "$PRD_ARG")"
PROGRESS_BASENAME="$(echo "$PRD_BASENAME" | sed 's/^prd/progress/')"
PROGRESS_ARG="$PRD_DIRNAME/$PROGRESS_BASENAME.txt"
PROGRESS_FILE="$SCRIPT_DIR/$PROGRESS_ARG"

# Internal state files (hidden, in tasks/)
ARCHIVE_DIR="$SCRIPT_DIR/tasks/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/tasks/.last-branch"    # Tracks branch to detect run switches
LAST_OUTPUT_FILE="$SCRIPT_DIR/tasks/.last-output"     # Last 100 lines of output for failure context
LAST_OUTPUT_ARG="tasks/.last-output"

# ------------------------------------
# Archive previous run
# When the PRD's branchName differs from the last recorded branch, the previous
# run's PRD and progress files are copied to tasks/archive/ and the progress
# file is reset. This prevents mixing logs from different feature branches.
# ------------------------------------
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    # Reset progress file for the new run
    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# ------------------------------------
# Branch tracking
# Save the current branch so we can detect switches on the next run.
# ------------------------------------
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# ------------------------------------
# Initialize progress file
# Create a fresh progress file if one doesn't exist yet.
# ------------------------------------
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# =============================================================================
# Main loop
# Each iteration launches a Claude Code instance with RALPH.md as the prompt,
# prepended with a "Current Run Context" block containing the concrete paths
# for this run. The Claude instance reads these paths to find the PRD, progress
# log, and last output file.
# =============================================================================
echo "Starting Ralph - PRD: $PRD_ARG - Max iterations: $MAX_ITERATIONS"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "==============================================================="
  echo "  Ralph Iteration $i of $MAX_ITERATIONS"
  echo "==============================================================="

  # Build the prompt: "Current Run Context" header + RALPH.md instructions.
  # The context block gives the Claude instance the actual file paths for
  # this run, so RALPH.md can reference them generically.
  RUN_CONTEXT="## Current Run Context
- PRD file: $PRD_ARG
- Progress file: $PROGRESS_ARG
- Last output file: $LAST_OUTPUT_ARG
"

  # Launch Claude Code in autonomous mode.
  # --dangerously-skip-permissions: no user confirmation prompts
  # --effort max: use maximum reasoning effort
  # --print: output mode (no interactive TUI)
  # 2>&1 | tee /dev/stderr: capture output while also displaying it live
  OUTPUT=$({ echo "$RUN_CONTEXT"; cat "$SCRIPT_DIR/RALPH.md"; } | claude --dangerously-skip-permissions --effort max --print 2>&1 | tee /dev/stderr) || true

  # ------------------------------------
  # Completion check
  # The Claude instance outputs <promise>COMPLETE</promise> when ALL stories
  # in the PRD have passes: true. This is the signal to stop the loop.
  # ------------------------------------
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    rm -f "$LAST_OUTPUT_FILE"
    exit 0
  fi

  # ------------------------------------
  # Failure context for next iteration
  # Save the last 100 lines of output so the next Claude instance can
  # diagnose what went wrong if the previous iteration failed mid-story.
  # ------------------------------------
  echo "$OUTPUT" | tail -100 > "$LAST_OUTPUT_FILE"

  # ------------------------------------
  # Progress report
  # Read the PRD to show how many stories are passing vs total.
  # ------------------------------------
  STORIES_PASSING=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  STORIES_TOTAL=$(jq '[.userStories[]] | length' "$PRD_FILE" 2>/dev/null || echo "0")
  echo "Progress: $STORIES_PASSING/$STORIES_TOTAL stories passing"

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

# If we get here, we ran out of iterations without completing all stories
echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
exit 1
