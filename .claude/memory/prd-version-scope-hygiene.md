---
name: PRD version & scope hygiene
description: Treat the designated master PRD as the source of truth; ignore legacy version labels and stale scope markers from earlier drafts
type: feedback
---

When writing derived PRDs (prd-product, prd-tech) for any project:

**Rule:** Do NOT use legacy version labels (e.g. "v1", "post-vN") as scope markers. Treat the designated master document as the single source of truth. References inside it to older versions are usually leftovers from earlier drafts and should not be read as current scope.

**Correct terminology:**
- **"Current scope"** — what must exist according to the master document (what you are building now)
- **"Deferred"** — what the master itself explicitly marks as out of scope for the current cycle
- Avoid echoing legacy version labels back in derived PRDs, interview questions, or user stories

**Why:** Legacy version labels are a common source of scope confusion — they survive in copy-pasted text long after they stop meaning anything operationally, and propagate downstream into wrong assumptions.

**How to apply:** Confirm the source-of-truth document with the user at the start of any PRD work. When you encounter an old version reference inside it, mentally translate it to "current scope" or "deferred" based on context, and never echo the legacy label back.
