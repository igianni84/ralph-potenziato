---
name: ralph
description: "Convert PRDs to prd.json format for the Ralph autonomous agent system. Use when you have an existing PRD and need to convert it to Ralph's JSON format. Triggers on: convert this prd, turn this into ralph format, create prd.json from this, ralph json."
user-invocable: true
---

# Ralph PRD Converter

Converts existing PRDs to the prd.json format that Ralph uses for autonomous execution.

---

## The Job

Take a PRD (markdown file or text) and convert it to `tasks/prd-{feature}.json`.

**Output location:** Always `tasks/prd-{feature}.json` where `{feature}` matches the source PRD name (e.g. `tasks/prd-product-notifications.md` → `tasks/prd-notifications.json`).

---

## Output Format

The output JSON must conform to `prd.schema.json` (the single source of truth for the format). See `tasks/prd.json.example` for a working example.

Key fields: `project`, `branchName` (prefixed `ralph/`, kebab-case), `description`, `userStories[]` with `id`, `title`, `description`, `acceptanceCriteria`, `priority`, `passes` (always `false`), `notes` (always `""`).

---

## Story Size: The Number One Rule

**Each story must be completable in ONE Ralph iteration (one context window).**

Ralph spawns a fresh Amp instance per iteration with no memory of previous work. If a story is too big, the LLM runs out of context before finishing and produces broken code.

### Right-sized stories:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

### Too big (split these):
- "Build the entire dashboard" - Split into: schema, queries, UI components, filters
- "Add authentication" - Split into: schema, middleware, login UI, session handling
- "Refactor the API" - Split into one story per endpoint or pattern

**Rule of thumb:** If you cannot describe the change in 2-3 sentences, it is too big.

---

## Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones.

**Correct order:**
1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

**Wrong order:**
1. UI component (depends on schema that does not exist yet)
2. Schema change

---

## Acceptance Criteria: Must Be Verifiable

Read `.claude/skills/references/acceptance-criteria.md` for the full standards: mandatory criteria by story type, quality rules, and test guidance.

---

## Conversion Rules

1. **Each user story becomes one JSON entry**
2. **IDs**: Sequential (US-001, US-002, etc.)
3. **Priority**: Based on dependency order, then document order
4. **All stories**: `passes: false` and empty `notes`
5. **branchName**: Derive from feature name, kebab-case, prefixed with `ralph/`
6. **Always add** to EVERY story: `"Typecheck passes"` and `"Tests pass"`
7. **Backend stories**: Also add `"Unit/Feature tests cover happy path and at least one failure case"`
8. **UI stories**: Also add `"Verify in browser using dev-browser skill"`

---

## Splitting Large PRDs

If a PRD has big features, split them:

**Original:**
> "Add user notification system"

**Split into:**
1. US-001: Add notifications table to database
2. US-002: Create notification service for sending notifications
3. US-003: Add notification bell icon to header
4. US-004: Create notification dropdown panel
5. US-005: Add mark-as-read functionality
6. US-006: Add notification preferences page

Each is one focused change that can be completed and verified independently.

---

## Example

**Input PRD:**
```markdown
# Task Status Feature

Add ability to mark tasks with different statuses.

## Requirements
- Toggle between pending/in-progress/done on task list
- Filter list by status
- Show status badge on each task
- Persist status in database
```

**Output `tasks/prd-task-status.json`:**
```json
{
  "project": "TaskApp",
  "branchName": "ralph/task-status",
  "description": "Task Status Feature - Track task progress with status indicators",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add status field to tasks table",
      "description": "As a developer, I need to store task status in the database.",
      "acceptanceCriteria": [
        "Add status column: 'pending' | 'in_progress' | 'done' (default 'pending')",
        "Generate and run migration successfully",
        "Feature test verifies column exists with correct type and default",
        "Typecheck passes",
        "Tests pass"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Display status badge on task cards",
      "description": "As a user, I want to see task status at a glance.",
      "acceptanceCriteria": [
        "Each task card shows colored status badge",
        "Badge colors: gray=pending, blue=in_progress, green=done",
        "Feature test verifies badge renders for each status",
        "Typecheck passes",
        "Tests pass",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-003",
      "title": "Add status toggle to task list rows",
      "description": "As a user, I want to change task status directly from the list.",
      "acceptanceCriteria": [
        "Each row has status dropdown or toggle",
        "Changing status saves immediately",
        "UI updates without page refresh",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 3,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-004",
      "title": "Filter tasks by status",
      "description": "As a user, I want to filter the list to see only certain statuses.",
      "acceptanceCriteria": [
        "Filter dropdown: All | Pending | In Progress | Done",
        "Filter persists in URL params",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 4,
      "passes": false,
      "notes": ""
    }
  ]
}
```

---

## Archiving Previous Runs

**Before writing a new `tasks/prd-{feature}.json`, check if there is an existing one from a different feature:**

1. Read the current `tasks/prd-{feature}.json` if it exists
2. Check if `branchName` differs from the new feature's branch name
3. If different AND `tasks/progress-{feature}.txt` has content beyond the header:
   - Create archive folder: `tasks/archive/YYYY-MM-DD-feature-name/`
   - Copy current PRD and progress files to archive
   - Reset progress file with fresh header

**The ralph.sh script handles this automatically** when you run it, but if you are manually updating the PRD JSON between runs, archive first.

---

## Checklist Before Saving

Before writing the file to `tasks/prd-{feature}.json`, verify:

- [ ] **Previous run archived** (if a PRD JSON exists with different branchName, archive it first)
- [ ] Each story is completable in one iteration (small enough)
- [ ] Stories are ordered by dependency (schema to backend to UI)
- [ ] Every story has BOTH "Typecheck passes" AND "Tests pass" as criteria
- [ ] Backend stories have "Unit/Feature tests cover happy path and at least one failure case"
- [ ] UI stories have "Verify in browser using dev-browser skill" as criterion
- [ ] Acceptance criteria include specific test hints (what to test, not just "tests pass")
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] No story depends on a later story
