# Session log

Append-only, newest at the bottom. One entry per session.

Write for a stranger with no memory — in three weeks that is who you are.
**Record numbers and filenames.** "Fixed the layout" is useless; "graph hidden
below 1510px by Quartz's `.desktop-only`; confirmed hidden at 916px, visible
at 1700px" is what a future session needs.

---

## 2026-10-13 — scaffold, and a survey of actual state

**Done**
- Scaffolded the repo as shared state: `CLAUDE.md`, `PLAN.md`,
  `NOTES/decisions.md`, this log, `.claude/commands/{resume,wrap-up,publish}`.
- Backfilled `decisions.md` with 16 decisions from the Sept–Oct desktop
  sessions, each with its reasoning and what would change it.
- Connected the repo to the desktop app, so planning sessions can read real
  state and write into `NOTES/` instead of emitting documents to hand-carry.
  Roughly ten documents had been carried by hand before this.

**Found — things the planning sessions did not know**
- **A `domains` layer exists** (commit `2a979d3`), accumulated alongside
  `tags`, open-ended with no enum. `29c26` carries
  `renaissance-painting, poetry, biochemistry, consumer-hardware`. This is a
  better answer to the tag-recurrence problem than the vocabulary-reuse scheme
  that was about to be implemented — that plan is now superseded in
  `decisions.md`.
- **The tagging skill is outside the repo**, at `~/.claude/skills/keep-tags/`,
  with a `skill_installed()` guard (commit `19ade7d`). Not version-controlled
  with the project.
- **`content/index.md` is a duplicate of `29c26`** and the publish script
  rewrites it every time (`git add … content/index.md`). The newest fragment
  therefore exists twice and appears twice in the graph.
- `quartz/components/BannerToggle.tsx` is a **custom component**, not upstream.
- `Component.Graph` is wrapped in `DesktopOnly()` in `quartz.layout.ts`, so
  desktop-only is a deliberate layout choice, not only Quartz's CSS default.
- Tag casing is inconsistent: `Cosmè-Tura`, `Erato`, `Mary-Oliver` against
  `allegory-of-prudence`, `one-wild-precious-life`. `Poetry` ≠ `poetry` in the
  graph. Also `Fprotein-folding` is still live — a typo'd tag can never recur.
- `transcripts/` does not exist. Transcript capture not started.
- `public/`, `private/`, `node_modules` correctly gitignored; nothing tracked
  that shouldn't be.

**Open**
- Landing page: duplicate-fragment vs static frontispiece. UNRESOLVED, and the
  duplication compounds with every publish.
- Link previews still show the Quartz logo — `static/og-image.png` and
  `static/icon.png` are unreplaced. Assets ready in the desktop session's
  outputs (`icons/`).
- Search and Backlinks components still in the layout; both have nothing to
  show.
- 1 fragment published: `29c26` (2019-W21), 27 days ago.

**Next**
1. Transcript capture — `TRANSCRIPT_CAPTURE.md` in the desktop outputs, with
   section 4's schema widened to keep `domains` alongside `tags` and
   `transcript`.
2. Then normalise casing and fix `Fprotein-folding` while the corpus is one
   fragment and it costs nothing.
3. Then settle the landing page.
