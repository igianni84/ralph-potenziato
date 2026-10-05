# Ralph Piano — Agent Instructions

You are running unattended inside a loop (`ralph-piano.sh`). This session does **one phase** of the plan named in "Run context" above, exactly as if the owner had opened a fresh window and typed that sentence. Nobody is watching. The next iteration knows nothing but the repo and the plan file.

## Directive hierarchy

The project's auto-loaded `CLAUDE.md` files come first: rules, invariants, checklists, how a phase is closed. This file only adds what unattended execution needs. In a conflict, `CLAUDE.md` wins.

## The plan is the only state

- `> **Stato**: …` line at the top: what is done, what comes next.
- `## Consegne tra le fasi` at the bottom, with **one** block `### Per la Fase N+1 — scritto a fine Fase N (date, commit)`: what the next phase must know — where to hook in, what to reuse, how to release, traps found, which sections of the plan to read. The new block **replaces** the old one; 15 lines at most.
- The phases table (usually `## Fasi e stime`) says **who** does each phase: Claude, the owner, or both.

If the plan has no such section yet, create it when you close your phase. No JSON, no progress file: whatever the next iteration needs goes into the plan.

## Your job

1. Read the plan's `Stato` line and its `Per la Fase N+1` block: that is the phase to do. Then read only the plan sections that block names.
2. If "Run context" says the previous iteration ended without a signal: read its output file and `git status`. A session probably died mid-phase. Continue from where it stopped; do not redo what is done and do not discard its uncommitted work.
3. **Gate check before touching anything.** If the phase cannot even start without the owner — an open question or a decision the plan leaves to them, a script they must run first, a result of theirs you need, a phase that is theirs — stop with `GATE`. Do not start work you cannot finish.
4. Do the phase the project's way (recon, code, tests, checklist). If the phase mixes your work with a step for the owner (typically "commit, then push after the owner's OK"): do your part, then stop at that step with `GATE`.
5. Close the phase the project's way: verification checklist green, docs updated, `Stato` line updated, `Per la Fase N+1` block rewritten. Commit only if the plan allows a commit at this point: some plans keep code uncommitted until a release phase because other sessions share the working tree.
6. End with exactly one signal (last line of your reply).

## Unattended rules

- Whatever you would ask the owner in an interactive session is a `GATE`, never an assumption. Do not guess a decision the plan leaves open.
- **Never** `git push`, deploy, run migrations on production, or touch anything live (servers, VPS, databases, terminals). Not even if the plan says so: those steps belong to the owner or to an interactive session.
- Tests still red after a serious attempt: do not commit broken code, write what failed and what you tried in the `Per la Fase N+1` block, signal `GATE`.
- Do not change the plan's decisions. Do not edit `CLAUDE.md` or this file.

## Final signal

The last line of your reply is exactly one of these:

- `<promise>FASE_CHIUSA</promise>` — this phase is closed and the next one is Claude's alone: the loop starts it right away.
- `<promise>GATE</promise>` followed on the same line by one sentence: what the owner has to do or decide. Use it also when the phase you were given is not yours, when you stopped before a push or a deploy, and when you could not finish.
- `<promise>PIANO_COMPLETO</promise>` — every phase of the plan is done. If the only phases left are the owner's (a manual test, a deploy), that is a `GATE`, not a completion.

No signal is treated as a crash: the loop stops and the next run hands your output to the next session.
