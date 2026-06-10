## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately – don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents everytime is needed to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update `tasks/lessons.md` with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project
- For accumulated domain knowledge, see [Knowledge System](#knowledge-system) below

### 4. Verification Before Done
- Never invent variable, function, class, or other names — always verify their existence before using them
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff senior engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes – don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When I report a bug, don't start by trying to fix it. Instead, start by writing a test that reproduces the bug. Then, have subagents try to fix the bug and prove it with a passing test.
- Point at logs, errors, failing tests – then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

### Task Management

1. **Plan First:** Write plan to `plans/` with checkable items
2. **Verify Plan:** Check in before starting implementation
3. **Track Progress:** Mark items complete as you go
4. **Explain Changes:** High-level summary at each step
5. **Document Results:** Add review section to `plans/`
6. **Capture Lessons:** Update `tasks/lessons.md` after corrections

### Core Principles

- **Simplicity First:** Make every change as simple as possible. Impact minimal code.
- **No Laziness:** Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact:** Changes should only touch what's necessary. Avoid introducing bugs.
- **Follow Project Guidelines:** Adhere to the tech stack rules defined in root `CLAUDE.md`.

---

## Team Memory (Shared Across Collaborators)

Persistent, team-shared memory lives at **`.claude/memory/`** (committed to the repo). This is the canonical location for project-wide context — NOT the user's home `~/.claude/projects/.../memory/` path, which is machine-local and not shared with collaborators.

### Before Starting Any Task
- Read `.claude/memory/MEMORY.md` (the index)
- Load relevant entries on demand based on the task topic
- Memory entries are markdown files with frontmatter (`name`, `description`, `type`)

### When to Add a Memory
- Save team-relevant context: workflow conventions, project state, references to external systems, communication preferences
- Do NOT save personal/machine-local stuff (those would belong in the home-directory memory if needed)

### How to Add a Memory
1. Write a new file under `.claude/memory/{slug}.md` with this frontmatter:
   ```markdown
   ---
   name: Short title
   description: One-line hook
   type: user | feedback | project | reference
   ---
   ```
2. Add a one-line pointer to `.claude/memory/MEMORY.md`
3. Commit the file so collaborators inherit it

### Types of Memory
- **user** — facts about the project lead or team members (role, expertise, preferences)
- **feedback** — workflow conventions, "do this / don't do that" rules
- **project** — current state of work, what's been completed, what's next
- **reference** — pointers to where information lives (file paths, external systems, line numbers)

---

## Persistence Taxonomy

This project uses four knowledge persistence mechanisms. Each serves a different purpose and audience:

| Mechanism | Location | Scope | Lifetime | Purpose |
|---|---|---|---|---|
| **Auto Memory** | `~/.claude/projects/.../memory/` | Personal, per-machine | Cross-session | Your personal understanding of the user, preferences, feedback. Not shared with collaborators. Managed by the system. |
| **Team Memory** | `.claude/memory/` | Shared, committed to repo | Cross-session | Team-wide context: workflow conventions, external system references, project state. Visible to all collaborators. |
| **Lessons** | `tasks/lessons.md` | Shared, committed to repo | Cross-session | Mistakes and corrections. Updated after any user correction. Reviewed at session start. Quick-reference patterns to avoid repeating errors. |
| **Knowledge System** | `knowledge/{domain}/` | Shared, committed to repo | Long-term, evolving | Domain insights with a promotion lifecycle: observations → hypotheses (3 confirmations) → rules (applied by default). For patterns that transcend individual tasks. |

### When to use which

- **User corrects your approach** → Update `tasks/lessons.md` (Self-Improvement Loop)
- **You discover a domain pattern** → Add to `knowledge/{domain}/knowledge.md`; if it seems like a rule, start as a hypothesis in `hypotheses.md`
- **Team workflow convention or external reference** → Add to `.claude/memory/`
- **Personal preference about the user** → Auto Memory (system-managed, `~/.claude/projects/.../memory/`)

### Boundaries

- A **lesson** is a mistake pattern: "don't do X, do Y instead." It's prescriptive and immediate.
- A **knowledge entry** is an observation or pattern: "X behaves like Y in this codebase." It's descriptive and evolving.
- When a lesson reveals a deeper domain pattern (not just a mistake to avoid), promote the insight to knowledge and keep the lesson as a quick-reference.
- Team Memory is for context that doesn't fit lessons or knowledge: who works on what, where external systems live, communication preferences.

---

## Knowledge System

### Before Starting a New Task
- When needed review existing rules and hypotheses for the relevant domain in `knowledge/`
- Apply rules by default — these are confirmed patterns
- Check if any hypothesis can be tested or validated with today's work

### At the End of Each Task
- Extract insights from the work done
- Store them in the appropriate domain folder under `knowledge/`

### Domain Folder Structure
Each domain gets its own folder: `knowledge/{domain}/`

```
knowledge/
  INDEX.md              # Routes to each domain folder
  {domain}/
    knowledge.md        # Facts and patterns observed
    hypotheses.md       # Need more data to confirm
    rules.md            # Confirmed — apply by default
```

### Promotion & Demotion
- When a hypothesis gets confirmed **3 times**, promote it to a **rule**
- When a rule gets contradicted by new data, demote it back to a **hypothesis**
- Track confirmations directly in `hypotheses.md` with date and context:

```
### Hypothesis: X
- Confirmations: 2/3
  - 2026-03-15: observed during invoice generation refactor
  - 2026-03-22: confirmed again in payment flow tests
```

When the count reaches 3/3, move the entry to `rules.md` and remove it from `hypotheses.md`.

### Examples of Domains
- `auth` — authentication flows, session management, role-based access
- `billing` — payment processing, invoice generation, subscription lifecycle
- `notifications` — email/push/in-app notification patterns, delivery rules
- `search` — indexing strategies, faceted filtering, relevance tuning
- `admin` — admin panel patterns, resource conventions, custom components
- `testing` — test patterns, factory usage, common pitfalls

---

## Decision Journal

### When to Log a Decision
When choosing between alternatives that affect more than today's task — a library, an architecture pattern, an API design, or deciding **NOT** to do something — log it.

### File Format
File: `decisions/YYYY-MM-DD-{topic}.md`

```markdown
## Decision: {what you decided}
## Context: {why this came up}
## Alternatives considered: {what else was on the table}
## Reasoning: {why this option won}
## Trade-offs accepted: {what you gave up}
```

### Before Making a Similar Decision
- Search `decisions/` for prior choices on the same topic
- Follow them unless new information invalidates the reasoning
- If overriding a prior decision, create a new entry referencing the old one
