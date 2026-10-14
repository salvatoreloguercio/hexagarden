# Directives

The channel from the desktop app to Claude Code. The desktop app appends a
directive and stops. Claude Code executes it, then records the outcome under
the same heading and marks it `DONE` or `BLOCKED`.

Append-only, newest at the bottom. Do not delete completed directives — the
outcomes are the record of what the pipeline actually did, which matters
because the tagging skill is versioned and its effects need to be traceable.

A directive says **what** and **why**, and names its own stopping point. It
does not say which commands to type; that is what the slash commands are for.

---

## D1 — Clear the stale lock, land the pending work

**Status:** DONE (2026-10-13, Claude Code)

`.git/index.lock` is stale — created by the desktop app attempting `git
status`, and it cannot delete it. Nothing is holding it; no git process is
running. Remove it before anything else, or every git operation fails.

Then land the working tree, which holds a coherent change set from the desktop
session of 2026-10-13:

- `publish-keep.sh` — `transcript` added to the schema (now requiring
  `tags`/`domains`/`transcript`), parsed from `.structured_output`, written to
  `transcripts/<hex>.txt`, `git add` extended to `transcripts`
- `.claude/skills/keep-tags/SKILL.md` — vendored from `~/.claude/skills/`, plus
  a `## Transcript` section and a widened fragment description that no longer
  assumes every fragment is a Keep screenshot
- `.claude/commands/reprocess.md` — new
- `CLAUDE.md`, `PLAN.md`, `NOTES/*` — scaffold and ownership rules

Suggested split: one commit for the pipeline change (script + skill), one for
the scaffold and notes. Say in the pipeline commit message what behaviour
changed, since the skill now governs every future fragment.

**Stop after:** committed, not pushed. Report `git log --oneline -3`.


**Outcome.** Lock removed by hand (`rm` from the Claude Code prompt) — it was
held open by the desktop app's virtualization process, not stale in the
filesystem sense. Landed as `da6f2ff` (scaffold and notes) and `6aaec95`
(transcript capture + vendored skill + `/reprocess`), not the suggested split
of pipeline vs scaffold, because the scaffold had already been committed
before the transcript work arrived. Fixed one bug before committing: `git add
transcripts` aborted the publish under `set -e` when the directory did not
exist. `.probe` deleted. **Pushed**, not just committed — Salvatore approved.

---

## D2 — Backfill 29c26 and verify the vision step

**Status:** DONE (2026-10-13, Claude Code)

Run `/reprocess 2019-W21`.

**Why this matters beyond the backfill:** it is the first end-to-end test of
three things at once — that the vendored skill resolves, that the widened
schema works, and that the Read tool actually delivers images to the model.
That last one has been an open question since the first publish and tags could
never settle it. Six plausible tags can be invented; a verbatim transcript
cannot.

**What to report:**

- `git diff content/29c26.md` — what changed in tags and domains, and whether
  anything changed for the worse
- the first ~200 words of `transcripts/29c26.txt`
- **your own judgment on whether the transcript matches the screenshot.** Open
  `content/keep-29c26.png` and compare. Do not just confirm that a transcript
  exists.
- anything that reads as the model describing its own confusion rather than the
  fragment — that is what a missing or unresolved skill produces

**Stop after:** reported. Do not commit the reprocessed fragment. Whether the
new tags are better than the old ones is a judgment about the work, not the
code, and it is Salvatore's.


**Outcome.** The vision step works. `transcripts/29c26.txt` (126 words) was
checked by eye against `content/keep-29c26.png`: verbatim, note boundaries
kept, URL exact. One small error in an image description (three animal heads
read as two). Nothing resembling the model describing its own confusion.
Tags: kept `Cosmè-Tura`, `Erato`, `allegory-of-prudence`,
`one-wild-precious-life`; dropped `protein-folding`, `Mary-Oliver` (not
visible on the page, only her line); added `amino-acid-embeddings`,
`protein-language-model`, `ferrarese-painting`, `three-headed-beast`,
`trip-to-italy`, `Centrino-advanced-N-6205`. Domains unchanged. **Tags are not
deterministic** — three runs, three different sets. Salvatore kept the result;
committed and pushed as `ef4d9b9`, with `published:` restored by hand.
Running it surfaced four pipeline bugs (stdin swallowed by `claude -p`,
`published:` reset on overwrite, `cp` onto itself, `/reprocess` missing
`--date`), fixed in `1341c6d`.

---

## D3 — Publish something that is not a Keep screenshot

**Status:** OPEN — unblocked; waiting on an image from Salvatore

The skill now claims to handle photo grids, prose pages and artwork. Nothing
has tested that claim.

`PLAN.md` M2 wants ten fragments of mixed type. The next one should be the
first non-Keep fragment — a Photos-app grid or a page of text — specifically
because it exercises the generalised prompt while the corpus is small enough
that a bad result costs nothing.

**Stop after:** one fragment published, with its transcript and tags reported.
