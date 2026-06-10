# Ralph — Autonomous Agent Loop

Ralph is a bash script that iteratively launches Claude Code instances to implement user stories from a PRD, one story per iteration, until all stories pass or the max iterations are reached.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- `jq` installed (`brew install jq`)

## Quick Start

```bash
# 1. Write a PRD (markdown)
#    Use /prd-product then /prd-tech in Claude Code, or create tasks/prd-tech-my-feature.md manually

# 2. Convert PRD to ralph JSON format
#    Use the /ralph skill in Claude Code:
#    > /ralph tasks/prd-tech-my-feature.md

# 3. Run ralph
./ralph.sh --prd tasks/prd-my-feature.json
```

## Usage

```bash
./ralph.sh [--prd <path>] [max_iterations]
```

| Argument | Default | Description |
|---|---|---|
| `--prd <path>` | `tasks/prd.json` | Path to the PRD JSON file (relative to project root) |
| `max_iterations` | `10` | Maximum number of iterations before stopping |

### Examples

```bash
# Default PRD, default iterations
./ralph.sh

# Specific feature, 20 iterations
./ralph.sh --prd tasks/prd-module-a.json 20

# Default PRD, 5 iterations
./ralph.sh 5
```

## PRD JSON Format

The PRD JSON file is the input that drives Ralph. Its format is defined by `prd.schema.json` (the single source of truth). See `tasks/prd.json.example` for a working example.

Key fields:

| Field | Description |
|---|---|
| `branchName` | Git branch Ralph works on (always prefixed `ralph/`, kebab-case) |
| `userStories[].priority` | Execution order (1 = first). Based on dependency order |
| `userStories[].passes` | Starts `false`. Ralph sets to `true` when the story is complete and verified |
| `userStories[].notes` | Starts `""`. Ralph writes failure details here if a story fails after 5 attempts |
| `userStories[].acceptanceCriteria` | Must always include `"Typecheck passes"` and `"Tests pass"` (enforced by schema) |

To generate this JSON from a markdown PRD, use the `/ralph` skill in Claude Code.

## How It Works

Each iteration, Ralph:

1. Prepends a "Current Run Context" (with paths to PRD, progress, and last output files) to `RALPH.md`
2. Pipes the combined prompt to `claude --dangerously-skip-permissions --effort max --print`
3. The Claude instance picks the highest-priority story with `passes: false`
4. Implements it, writes tests, runs the quality loop (see Quality Commands in `CLAUDE.md`)
5. Commits and marks the story as `passes: true`
6. Appends a progress log entry

If all stories pass, Ralph exits with `<promise>COMPLETE</promise>`. Otherwise, the next iteration picks up the next story.

## File Structure

```
project-root/
  ralph.sh              # The launcher script
  RALPH.md              # Agent instructions (passed as prompt)
  tasks/
    prd-{feature}.json  # PRD in ralph JSON format (input)
    prd-product-{feature}.md   # Business PRD (reference)
    prd-tech-{feature}.md      # Technical PRD (reference)
    progress-{feature}.txt     # Auto-generated progress log
    .last-branch        # Internal: tracks branch for archiving
    .last-output        # Internal: last 100 lines of output for failure context
    archive/            # Auto-created: archived runs when branch changes
      YYYY-MM-DD-feature-name/
        prd-{feature}.json
        progress-{feature}.txt
```

The progress file is derived automatically from the PRD filename:
- `tasks/prd-my-feature.json` produces `tasks/progress-my-feature.txt`
- `tasks/prd.json` produces `tasks/progress.txt`

## What Ralph Updates

Ralph updates source code, tests, the progress file, and the PRD JSON each iteration. It may also update `knowledge/` and `decisions/` when appropriate. See `RALPH.md` → **What to Update** for the full breakdown.

Ralph **never** modifies `./CLAUDE.md`, `.claude/CLAUDE.md`, or `RALPH.md`.

## Monitoring a Run

```bash
# Watch progress in real time (ralph outputs to stderr)
# The script already uses tee, so you'll see output live

# Check story progress
jq '[.userStories[] | {id, title, passes}]' tasks/prd-my-feature.json

# Read the progress log
cat tasks/progress-my-feature.txt
```

## Workflow

See `README.md` for the full workflow diagram (from `/prd-product` through to `./ralph.sh`).
