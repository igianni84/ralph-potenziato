# Ralph Potenziato

> A reusable **Claude Code** project template for structured, **autonomous** development — a two-step PRD pipeline, the Ralph agent loop, a cross-session knowledge system, and a decision journal.

**Requirements:** [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) · `jq` (`brew install jq`, used by Ralph).

## Quick Start

1. **Copy this template** into your new project directory
2. **Start Claude Code** and run `/setup`
3. The setup skill interviews you about your project, tech stack, and business rules, then configures all project files
4. **Create your first PRD** with `/prd-product` (business requirements) then `/prd-tech` (technical design)
5. **Run Ralph** for autonomous implementation: `/ralph` then `./ralph.sh`

## Workflow

```
/setup                                    → Configure project (once, at the start)
    |
/prd-product                              → Business PRD (what & why)
    |
tasks/prd-product-{feature}.md            → Business requirements document
    |
/prd-tech                                 → Technical PRD (how)
    |
tasks/prd-tech-{feature}.md              → Architecture + implementation tasks
    |
/ralph tasks/prd-tech-{feature}.md        → Convert to JSON for Ralph
    |
tasks/prd-{feature}.json                  → Machine-readable stories
    |
./ralph.sh --prd tasks/prd-{feature}.json → Autonomous implementation loop
    |
Code + Tests                              → One story at a time, quality-checked
```

## Structure

```
CLAUDE.md                      # Project config (tech stack, invariants, quality commands)
.claude/
  CLAUDE.md                    # Workflow orchestration (universal)
  settings.local.json          # Claude Code settings
  skills/
    setup/                     # Project initialization skill
    prd-product/               # Business PRD generator
    prd-tech/                  # Technical PRD generator
    ralph/                     # PRD-to-JSON converter
    references/                # Shared methodology (interview, writing protocol)
RALPH.md                       # Autonomous agent instructions
ralph.sh                       # Autonomous loop script
prd.schema.json                # JSON Schema for PRD validation
knowledge/                     # Domain knowledge accumulation
  INDEX.md
decisions/                     # Architectural decision journal
plans/                         # Implementation plans
tasks/
  prd.json.example             # Example PRD JSON format
  lessons.md                   # Self-improvement log
```

## Key Systems

### Two-Layer Configuration
- **Root `CLAUDE.md`** — Project-specific: name, tech stack, invariants, quality commands. Configured once via `/setup`.
- **`.claude/CLAUDE.md`** — Universal workflow: plan mode, subagent strategy, persistence taxonomy, knowledge system, decision journal. Works unchanged across projects.

### PRD Pipeline
Two-step PRD process separating business requirements from technical design:
1. **`/prd-product`** — Captures *what* to build and *why* through an iterative interview. Produces `tasks/prd-product-{feature}.md`.
2. **`/prd-tech`** — Transforms business PRD into technical specs: data model, services, routes, and an ordered implementation task breakdown. Produces `tasks/prd-tech-{feature}.md`.
3. **`/ralph`** — Converts a PRD to JSON format for autonomous execution.

### Ralph (Autonomous Agent)
Iteratively implements user stories from a PRD JSON. Each iteration picks the next unfinished story, implements with tests, runs the quality loop, and commits. See `README_RALPH.md` for details.

### Knowledge System
Accumulates domain insights across sessions in `knowledge/{domain}/`:
- **knowledge.md** — Observed facts and patterns
- **hypotheses.md** — Unconfirmed patterns (promoted to rules after 3 confirmations)
- **rules.md** — Confirmed patterns (applied by default)

### Persistence Taxonomy
Four persistence mechanisms with distinct purposes. See `.claude/CLAUDE.md` → **Persistence Taxonomy** for the full breakdown: Auto Memory (personal), Team Memory (shared), Lessons (corrections), Knowledge System (domain patterns).

### Decision Journal
Records architectural decisions in `decisions/YYYY-MM-DD-{topic}.md` with context, alternatives, and trade-offs.

## Customization

### Stack-Specific Skills
This template includes only universal skills. Add skills for your stack:
- **Laravel:** Install `laravel/boost` for auto-injected guidelines and MCP tools
- **Other frameworks:** Create skills in `.claude/skills/{name}/SKILL.md`
- **Skill Creator:** The `.agents/skills/skill-creator/` directory contains a skill for creating, editing, and benchmarking new skills. It is independent from the core template skills in `.claude/skills/`.

### Permissions
Add stack-specific permissions to `.claude/settings.local.json`:
```json
"allow": ["Bash(php artisan:*)", "Bash(npm test:*)"]
```

### CI/CD
No CI/CD templates included. Configure `.github/workflows/` for your stack.
