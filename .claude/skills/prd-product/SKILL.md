---
name: prd-product
description: "Generate a business-focused Product Requirements Document (PRD). Use for defining product vision, business user stories, personas, and success criteria — with ZERO technical implementation details. This is the first step of the PRD pipeline (prd-product → prd-tech → ralph). Triggers on: create a product prd, business prd, write business requirements, product requirements, define the product, prd-product, business user stories, product spec. Also use when the user wants to formalize a feature idea into business requirements before technical design."
user-invocable: true
---

# PRD Product — Business Requirements Generator

Create business-focused Product Requirements Documents through deep, iterative interviews. The goal: capture **what** the product should do and **why**, so clearly that any stakeholder can validate it — without a single line of technical jargon.

**Core philosophy:** Interview the user until you have 95% confidence about what they *actually* want — not what they think they should want. Zero assumptions. Zero ambiguity. Every unclear detail gets a question, not a guess.

**Boundary:** This skill produces business requirements ONLY. Technical architecture, data models, and implementation details belong in `/prd-tech`, which consumes this document as input.

---

## Detect Mode

When invoked, determine which mode to use:

**Import Mode** — The user provides an existing document (file path, pasted content, or reference to an existing spec/brief). Read it, analyze it, then interview to fill gaps.

**New Mode** — The user describes a feature or need without an existing document. Start the interview from scratch.

Both modes converge on the same interview and generation process. The difference is the starting point.

---

## Phase 0: Context Gathering

Read `.claude/skills/references/interview-methodology.md` → **Phase 0** for the generic context gathering steps.

**Additional steps for this skill:**
- **Check domain vocabulary** — Load the Canonical Terminology table from CLAUDE.md (if defined). All entities in the PRD MUST use these canonical terms consistently.

### Import Mode: Gap Analysis

Read `.claude/skills/references/interview-methodology.md` → **Import Mode: Gap Analysis** and follow the process described there.

---

## Phase 1: Deep Interview

This is the heart of the skill. Your job is to understand what the user actually needs — not just what they say they want, but the underlying problem they're solving.

Read `.claude/skills/references/interview-methodology.md` for: **Interview Rules**, **Question Style**, and **Anti-Patterns**.

**Additional rule for this skill:** Stay business-level. If the user drifts into technical details ("we'll need a migration for..."), gently steer back: "I'm capturing that as a business requirement — the technical design will come in the next step (prd-tech). For now: what should the user experience be?"

**Additional anti-pattern:** Don't discuss implementation. No databases, APIs, migrations, or code. Keep it business-level.

### Interview Areas

Progress through these areas, spending more time where complexity is higher:

**1. Problem & Context**
- What problem does this solve? Why now? What's the cost of not doing it?
- What are users doing today without this feature?
- What does success look like in concrete, observable terms?
- What triggered the need for this feature?

**2. Personas & User Roles**
- Who are the primary users? What are their roles?
- What are their goals and motivations?
- What is their skill level / familiarity with the system?
- Are there different user types with different needs?
- Who are secondary stakeholders (affected but not direct users)?

**3. Core Workflows**
- What are the key user journeys, step by step?
- What decisions does the user make at each step?
- What information does the user need to see at each point?
- What actions can the user take? What are the outcomes?
- What are the business rules that govern behavior?

**4. Boundaries & Scope**
- What is explicitly out of scope?
- What looks related but should NOT be part of this feature?
- What's the minimum viable version vs the full vision?
- Are there phases? What goes in phase 1 vs later?

**5. Edge Cases & Business Exceptions**
- What happens when things go wrong from the user's perspective?
- What are the boundary conditions? (Empty states, limits, conflicting actions)
- What business exceptions exist? How should they be communicated to the user?
- What are the failure modes and their consequences for the business?

**6. Dependencies & Constraints**
- What existing features or processes does this interact with?
- Are there business constraints (regulatory, contractual, temporal)?
- What invariants must be preserved? (Cross-reference CLAUDE.md key invariants)
- What external systems or partners are involved from a business perspective?

**7. Success Metrics & Validation**
- How do we know each piece is done from a business perspective?
- How do we know it's working correctly for users?
- What KPIs or metrics matter? What are their targets?
- How will we measure adoption and satisfaction?

### Confidence Tracking

Read `.claude/skills/references/interview-methodology.md` → **Confidence Tracking** for the mechanism.

**This skill's threshold: 95%** across all 7 business areas listed above.

---

## Phase 2: PRD Generation

Once all confidence areas are at 95%+, generate the PRD.

### Structure

#### 1. Introduction/Overview
Brief description of the feature and the problem it solves. Include context on why this is being built now and what business value it delivers.

#### 2. Goals
Specific, measurable business objectives (bullet list). Each goal should be verifiable — not aspirational. Focus on outcomes, not outputs.

#### 3. Personas & User Roles
For each persona:
- **Role name** and brief description
- **Goals** — what they're trying to accomplish
- **Pain points** — what's frustrating about the current situation
- **Key workflows** — which workflows they participate in

#### 4. User Stories

Each story captures a business need from the user's perspective. Stories should be grouped by workflow or persona.

Each story needs:
- **Title:** Short descriptive name
- **Description:** "As a [persona], I want [capability] so that [business benefit]"
- **Acceptance Criteria:** Verifiable checklist of what "done" means from the user's perspective

**Format:**
```markdown
### US-001: [Title]
**Description:** As a [persona], I want [capability] so that [business benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion (user-observable behavior)
- [ ] Another criterion
- [ ] ...
```

Acceptance criteria must describe **observable outcomes**, not implementation details:
- Good: "The user sees a confirmation message with the order total"
- Bad: "The system saves the record to the database"
- Good: "The list updates within 2 seconds of applying the filter"
- Bad: "The query uses an index for performance"

#### 5. Business Rules & Constraints
Explicit business rules that govern the feature's behavior:
- Conditional logic ("If X then Y, unless Z")
- Limits and thresholds ("Maximum 50 items per order")
- Permissions ("Only role X can perform action Y")
- Temporal rules ("Orders can only be modified within 24 hours")

Use worked examples for complex rules: show input → expected outcome.

#### 6. Non-Goals (Out of Scope)
What this feature will NOT include. Be specific about whether something is "not in this phase" vs "never". This section prevents scope creep.

#### 7. Success Metrics
How will business success be measured? Use concrete, measurable criteria with specific targets. Include both leading indicators (adoption, usage) and lagging indicators (revenue impact, efficiency gains).

#### 8. Open Questions
Genuine remaining unknowns that couldn't be resolved during the interview. These should be rare if the interview was thorough — this section should be short or empty.

### Incremental Writing Protocol

Read `.claude/skills/references/incremental-writing-protocol.md` and follow the protocol.

**Skill-specific details:**
- **Document title prefix:** `# PRD Product: [Feature Name]`
- **Sections:** 8 total (see Structure above)
- **Sections that may need batching:** User Stories (Section 4), Business Rules (Section 5) — max 20 items per `Edit`
- **Output path:** `tasks/prd-product-{feature}.md`

---

## Phase 3: Review & Refinement

Read `.claude/skills/references/interview-methodology.md` → **Review & Refinement** and follow the process.

**After confirmation, suggest:** "The business PRD is ready. When you want to proceed with the technical design, run `/prd-tech`."

---

## Output

- **Format:** Markdown (`.md`)
- **Location:** `tasks/`
- **Filename:** `prd-product-{feature}.md` (kebab-case)
- **How it's written:** Always use the **Incremental Writing Protocol**. Never produce the full PRD in a single `Write` call.

**Important:** Do NOT start technical design or implementation. The output is the business PRD only. The next step is `/prd-tech`.

---

## Pre-Save Checklist

Read `.claude/skills/references/incremental-writing-protocol.md` → **Pre-Save Checklist (Common)** for shared items.

**Additional checks for this skill:**
- [ ] All confidence areas reached 95%+
- [ ] No assumptions were made without user confirmation
- [ ] All entities use Canonical Terminology from CLAUDE.md
- [ ] Zero technical implementation details in the document
- [ ] User stories are grouped logically with verifiable acceptance criteria
- [ ] Business rules are explicit with worked examples where needed
- [ ] Non-goals section defines clear boundaries
- [ ] Edge cases and business exceptions are covered
- [ ] Key invariants from CLAUDE.md are respected
- [ ] Success metrics are concrete and measurable
