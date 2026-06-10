---
name: setup
description: "Initialize and configure a new project from the Claude Code project template. Detects PROJECT_SETUP placeholders in root CLAUDE.md and interviews the user to configure project identity, tech stack, key invariants, and quality commands. Use this skill whenever the user wants to set up a new project, initialize the template, configure project settings, or when starting fresh with this template. Trigger on: 'set up project', 'initialize project', 'configure project', 'new project setup', 'configure template', or whenever root CLAUDE.md still has PROJECT_SETUP markers. If you notice CLAUDE.md is unconfigured during other work, proactively suggest running /setup first."
user-invocable: true
---

# Project Setup

Configure a new project from the Claude Code project template. This skill interviews you about your project and populates all configuration files so Claude and Ralph can work effectively from the start.

**Philosophy:** Zero assumptions. Every detail is asked, never guessed. If something is unclear, ask — don't fill in a default and hope for the best. The few minutes spent here save hours of miscommunication later.

---

## Phase 1: Detect State

Read root `CLAUDE.md` and check for `PROJECT_SETUP` markers.

**If markers found:** The project is fresh. Proceed to Phase 2.

**If no markers found:** The project appears already configured. Show the user a summary of the current configuration (project name, stack, invariants count, quality commands) and ask:
> "This project is already configured. Do you want to update the configuration, or did you mean to do something else?"

If they want to update, proceed to Phase 2 but pre-fill answers from the existing config so they only need to confirm or change what's different.

---

## Phase 2: Interview

Guide the user through four setup areas. This is a conversation, not a form — batch related questions (3-5 per round), adapt based on answers, and probe when answers are vague.

### 2.1 Project Identity

Ask:
- **Project name** — What's the project called?
- **One-line description** — What does it do and who is it for?
- **Additional context** (optional) — Background that helps Claude understand the project: why it exists, what problem it solves, organizational context.

This is usually quick — one round.

### 2.2 Tech Stack

Don't just ask "what's your stack?" — people forget things. Walk through each layer systematically:

- **Backend:** Framework, language, version (e.g., "Laravel 13, PHP 8.5" / "Next.js 15, Node 22" / "Django 5, Python 3.13")
- **Frontend:** Framework, styling (e.g., "React 19, Tailwind CSS 4" / "Vue 3, SCSS" / "Blade templates" / "server-rendered only")
- **Database:** Engine and version (e.g., "MySQL 8" / "PostgreSQL 16" / "SQLite")
- **Testing:** Frameworks and tools (e.g., "PHPUnit" / "Jest + Playwright" / "Pytest")
- **Build/Dev tools:** (e.g., "Vite 7" / "Webpack" / "Turbopack")
- **Key integrations:** External services, APIs (e.g., "Stripe, Xero, SendGrid")
- **Quality tools:** Formatters, linters, static analysis (e.g., "PHPStan, Pint" / "ESLint, Prettier" / "Ruff, mypy")

If the user isn't sure about versions, suggest they check (`php -v`, `node -v`, `python --version`, etc.). Approximate versions are fine.

### 2.3 Key Invariants

This is the most important section and the one users are least likely to think about unprompted. Start by explaining what invariants are:

> "Key invariants are the absolute business rules of your project — things that must NEVER be violated, no matter what feature is being built. Claude will refuse to write code that breaks these. Think of them as guardrails that protect data integrity and business logic."

Help the user discover their invariants through guided questions:
- "What data, once created, should never be modified?" (immutability)
- "What operations are irreversible in your domain?" (one-way transitions)
- "What quantity or relationship constraints must always hold?" (data integrity)
- "What is the authority hierarchy in your system?" (authorization)
- "What security boundaries must never be crossed?" (access control)

Offer concrete examples from common domains:

| Domain | Example invariant |
|---|---|
| E-commerce | An order cannot be modified after payment is captured |
| Healthcare | Patient records are append-only, never deleted |
| Finance | Transactions are immutable after settlement |
| Multi-tenant | Tenant A can never access Tenant B's data |
| Inventory | Stock count can never go negative |
| Auth | Admin roles cannot be self-assigned |

If the project is early-stage and the user doesn't have clear invariants yet, that's fine. Leave the section with a note to revisit as the domain solidifies. Don't force it — but flag it as important to define early.

### 2.4 Quality Commands

Based on the tech stack from 2.2, **suggest** quality commands and let the user confirm or correct. Most users won't know all of these off the top of their heads — your suggestions remove the guesswork.

Present a table with your best suggestions based on the stack:

| Command | Purpose | Your suggestion |
|---|---|---|
| format | Code formatter | *(auto-suggest)* |
| test_filter | Run a specific test by name | *(auto-suggest)* |
| test | Run tests (file or suite) | *(auto-suggest)* |
| type_check | Static type analysis | *(auto-suggest)* |
| lint | Code linter | *(auto-suggest)* |

**Reference for common stacks:**

| Stack | format | test_filter | test | type_check | lint |
|---|---|---|---|---|---|
| Laravel/PHP | `vendor/bin/pint --dirty` | `php artisan test --compact --filter={name}` | `php artisan test --compact` | `./vendor/bin/phpstan analyse` | — |
| Next.js/React | `npx prettier --write .` | `npm test -- --testPathPattern={name}` | `npm test` | `npx tsc --noEmit` | `npm run lint` |
| Python/Django | `black .` | `pytest -k {name}` | `pytest` | `mypy .` | `ruff check .` |
| Go | `gofmt -w .` | `go test -run {name} ./...` | `go test ./...` | — | `golangci-lint run` |
| Rails/Ruby | `bundle exec rubocop -A` | `bundle exec rspec --tag {name}` | `bundle exec rspec` | `bundle exec steep check` | `bundle exec rubocop` |
| Rust | `cargo fmt` | `cargo test {name}` | `cargo test` | — | `cargo clippy` |

Not every project needs all five commands. Leave empty what doesn't apply.

---

## Phase 3: Populate Files

### 3.1 Update root `CLAUDE.md`

Replace all `PROJECT_SETUP` sections with the real values gathered in Phase 2:

- **What This Is:** Project name and description from 2.1
- **Tech Stack:** Full listing with versions from 2.2
- **Key Invariants:** Numbered list of business rules from 2.3 (or a note if none yet)
- **Quality Commands:** Table with actual values from 2.4

Remove all `PROJECT_SETUP` HTML comment markers and example comments. The final file should read as a clean project configuration, not a template.

### 3.2 Recommend Next Steps

After populating CLAUDE.md, present tailored recommendations based on the stack:

**Stack-specific skills** — Suggest relevant skills to install:
- Laravel → "`laravel/boost` provides auto-injected Laravel guidelines and MCP tools"
- Tailwind → "tailwindcss-development skill for Tailwind v4 patterns"
- Inertia/React → "inertia-react-development skill for Inertia v3 + React"
- For other stacks → suggest community skills if known, or suggest the user search with `/find-skills`

**Permissions for `.claude/settings.local.json`** — Suggest additions based on stack:

```
Laravel:   Bash(php artisan:*), Bash(composer:*), Bash(vendor/bin/pint:*)
Node:      Bash(npm run:*), Bash(npx:*)
Python:    Bash(python manage.py:*), Bash(pytest:*)
Go:        Bash(go test:*), Bash(go build:*)
Ruby:      Bash(bundle exec:*), Bash(rails:*)
```

**CI/CD** — Suggest setting up `.github/workflows/` and offer to help configure it.

**MCP servers** — Mention relevant MCP tools (e.g., Laravel Boost for Laravel).

Present these as suggestions, not actions:
> "Based on your stack, here's what I'd recommend. Which of these should I apply now?"

Apply only what the user explicitly approves.

---

## Phase 4: Verify & Wrap Up

Show a summary of what was configured:

```
Project configured:
  Name:             [project name]
  Stack:            [backend] + [frontend] + [database]
  Invariants:       [count] defined (or "none yet — revisit later")
  Quality commands:  [count]/5 configured
  Updated:          CLAUDE.md
```

Then suggest the natural next step:
> "Project is ready. Run `/prd-product` to create a business PRD for your first feature, then `/prd-tech` for the technical design, or start coding directly."

---

## Edge Cases

- **User wants to skip a section:** Fine. Leave it empty in CLAUDE.md. They can re-run `/setup` anytime.
- **User gives very terse answers:** Probe gently: "Can you tell me more? The more context Claude has, the better it helps."
- **User doesn't know their stack versions:** Suggest terminal commands to check, or accept approximate versions.
- **User has a non-standard or mixed stack:** Support it fully. The template is stack-agnostic — any combination works.
- **User wants to add custom sections to CLAUDE.md:** Encourage it. CLAUDE.md is their project — extra context always helps.
- **User runs `/setup` on an already-configured project:** Show current config, ask what to change. Don't start from scratch unless asked.
