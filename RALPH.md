# Ralph Agent Instructions

You are an autonomous coding agent working on a software project.

## Directive Hierarchy

You MUST follow all directives from the auto-loaded `CLAUDE.md` files in addition to these instructions. When in conflict, this is the priority order:

1. **`./CLAUDE.md`** (root) — Project rules, key invariants, tech stack, quality commands. The Key Invariants are absolute and must NEVER be violated.
2. **`.claude/CLAUDE.md`** — Workflow orchestration, knowledge system, decision journal. Follow these patterns for how you work.
3. **`RALPH.md`** (this file) — Iteration-specific behavior: which story to pick, quality loop, what to update. Governs your per-iteration workflow.

If a CLAUDE.md directive conflicts with a RALPH.md instruction, the CLAUDE.md directive wins.

## Your Task

1. Read the PRD at the path specified in "Current Run Context" above
2. Read the progress log at the path from "Current Run Context" (check Codebase Patterns section first)
3. Check if the last output file from "Current Run Context" exists — if it does, a previous iteration may have failed. Read it for context on what went wrong. Check the `notes` field of the current story in the PRD for failure details.
4. Check you're on the correct branch from PRD `branchName`. If not, check it out or create from main.
5. Pick the **highest priority** user story where `passes: false`
6. Implement that single user story following the **Quality Loop** below
7. Capture reusable knowledge (see "What to Update" section below)
8. Commit ALL changes with message: `feat: [Story ID] - [Story Title]`
9. Update the PRD to set `passes: true` for the completed story
10. Append your progress to the progress file from "Current Run Context"

## Quality Loop (Step 6 — MANDATORY)

For every story, follow this loop. Do NOT commit until the loop is green.

### 6a. Implement
Write the implementation code for the story. Follow existing code patterns.

### 6b. Write Tests
Every story MUST have tests. Choose the right type based on what you built:

| What you built | Test type | Guidance |
|---|---|---|
| Service / utility class | Unit test | Isolated tests for business logic |
| Model / data layer | Unit test | Tests for data operations and constraints |
| Controller / endpoint / handler | Integration test | Tests for request/response behavior |
| UI component / page | Integration test | Tests for user-facing behavior |
| Background job / async task | Unit or Integration | Depends on side effects |
| Migration / schema change | Integration test | Verify schema is correct after migration |

**Rules:**
- Use factories or fixtures (check if one exists; create it if not)
- Cover happy path + at least one failure/edge case
- Use your project's test creation tools and follow existing test file conventions
- Check sibling test files for naming and structure patterns

### 6c. Run & Fix Loop
Run the quality commands defined in root `CLAUDE.md` → `### Quality Commands` table, in this order. If ANY step fails, fix and re-run FROM THAT STEP. Do not skip ahead. Skip any step whose command is not configured (empty in the table).

```
Step 1: format       — Run the format command
Step 2: test_filter  — Run YOUR specific test (substitute {name} with your test name/class)
Step 3: test         — Run the full affected test file
Step 4: type_check   — Run static type analysis (if configured)
Step 5: lint         — Run the linter (if configured)
```

**If tests fail:**
1. Read the error output carefully
2. Diagnose the root cause (don't guess)
3. Fix the implementation OR the test (whichever is wrong)
4. Re-run from the failing step
5. Repeat until green

**Maximum 5 fix attempts per step.** If still failing after 5 attempts:
- Do NOT commit broken code
- Do NOT mark the story as `passes: true`
- Write detailed failure notes in the progress file including: what failed, error messages, what you tried
- Set the story's `notes` field in the PRD with a summary of the failure
- End your response normally (next iteration will pick it up with context)

### 6d. Verify Acceptance Criteria
Before committing, check EVERY acceptance criterion in the story:
- Go through the list one by one
- Each must be demonstrably true
- For UI stories: verify in browser using dev-browser skill
- If a criterion is NOT met, go back to 6a and fix it

## Progress Report Format

APPEND to the progress file (never replace, always append):
```
## [Date/Time] - [Story ID]
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered (e.g., "this codebase uses X for Y")
  - Gotchas encountered (e.g., "don't forget to update Z when changing W")
  - Useful context (e.g., "the evaluation panel is in component X")
---
```

The learnings section is critical - it helps future iterations avoid repeating mistakes and understand the codebase better.

## Consolidate Patterns

If you discover a **reusable pattern** that future iterations should know, add it to the `## Codebase Patterns` section at the TOP of the progress file (create it if it doesn't exist). This section should consolidate the most important learnings:

```
## Codebase Patterns
- Example: Always use `IF NOT EXISTS` for migrations
- Example: Use factory states for test setup, not manual overrides
- Example: Export types from actions.ts for UI components
```

Only add patterns that are **general and reusable**, not story-specific details.

## What to Update

### ALWAYS update:
- **Progress file** (from Current Run Context) — append your iteration log in the format above
- **Codebase Patterns section** in the progress file — consolidate reusable patterns at the top

### WHEN APPROPRIATE:
- **`tasks/lessons.md`** — when you discover a mistake pattern that future iterations should avoid. Follow the Self-Improvement Loop in `.claude/CLAUDE.md`
- **`knowledge/{domain}/`** — for domain insights (rules, hypotheses, knowledge) that transcend this feature. Follow the Knowledge System defined in `.claude/CLAUDE.md`
- **`decisions/YYYY-MM-DD-{topic}.md`** — when choosing between architectural alternatives that affect future work

### NEVER modify:
- `./CLAUDE.md` — root project config, managed by the team
- `.claude/CLAUDE.md` — workflow orchestration, managed by the team
- `RALPH.md` — agent instructions, managed by the team

## Quality Requirements

- ALL commits must pass the full Quality Loop (6a-6d) — no exceptions
- Do NOT commit broken code — ever
- Every story MUST include tests (see 6b for test type selection)
- Keep changes focused and minimal
- Follow existing code patterns
- If you cannot make tests pass, do NOT mark `passes: true` — leave detailed notes instead

## Browser Testing (If Available)

For any story that changes UI, verify it works in the browser if you have browser testing tools configured (e.g., via MCP):

1. Navigate to the relevant page
2. Verify the UI changes work as expected
3. Take a screenshot if helpful for the progress log

If no browser tools are available, note in your progress report that manual browser verification is needed.

## Stop Condition

After completing a user story, check if ALL stories have `passes: true`.

If ALL stories are complete and passing, reply with:
<promise>COMPLETE</promise>

If there are still stories with `passes: false`, end your response normally (another iteration will pick up the next story).

## Important

- Work on ONE story per iteration
- Commit frequently
- Keep CI green
- Read the Codebase Patterns section in the progress file before starting
