# PLAN

No deadlines. Milestones ordered by dependency, not date. Work happens in
irregular spare-time bursts, so units are sized to finish in one sitting.
**⏸ marks a safe place to stop.**

Statuses below were verified against the repo on 2026-10-13.

---

## M1 — Close the apparatus ⟵ current

| Unit | State |
|---|---|
| Fragments at content root, hex labels, collision handling | ✅ done |
| Week + date derived from screenshot filename | ✅ done |
| Two layout modes, bare and expanded | ✅ done |
| Dark by default | ✅ done |
| Graph config: `showTags`, `depth: 2`, `opacityScale: 4` | ✅ done |
| Skill-missing guard in `publish-keep.sh` | ✅ done |
| `domains` layer alongside `tags` | ✅ done |
| About page | ✅ done |
| Landing page is static, not the latest fragment | ✅ done (choice of image open — M1.1) |
| Transcript capture → `transcripts/` | 🟡 script + skill done; untested until `/reprocess 29c26` |
| Tags NFC-normalised; `Fprotein-folding` fixed | ✅ done |
| Favicon + og-image (still the Quartz logo in link previews) | ⬜ not started |
| Remove Search — it indexes one line of body text | ⬜ not started |
| Remove Backlinks — always empty, fragments never link | ⬜ not started |
| Colophon: rewrite, then re-link in the footer | ⬜ not started |
| Clicking a fragment → `static/random.html` | ⬜ not started |

### M1.1 — The landing page: decided, static

Reconfirmed 2026-10-13: `/` is **not** the latest fragment. Commit `0c63ffd`
had made it one (a duplicate rewritten by `publish-keep.sh` on every publish);
that part was reverted before it was ever pushed. `content/index.md` is back to
the Lindisfarne gif that was already live, and the publish script no longer
touches it.

Still open, and **not** blocking publishing: which illumination, and whether
it goes full-bleed. The current page is a 300×284 gif with a "Welcome!" under
it; `quartz/static/banner-full.webp` (the full Chi-Rho, 1448×655) is the
obvious candidate. See `NOTES/decisions.md`.

**M1 done when:** publishing is one command, link previews aren't Quartz's
logo, and the frontispiece image is chosen.

## M2 — Publish

Ten fragments, deliberately mixed: Keep screenshots, at least one text
fragment, at least one Photos grid. The mix proves the pipeline is general and
gives the graph something heterogeneous.

Each publish is its own unit. ⏸ after every one.

**Done when:** ten fragments exist and domains have recurred across them.
Tags may well not recur — that is by design. If *domains* don't recur either,
the extraction is too specific at both layers and needs adjusting.

## M3 — Decide the graph method

Blocked on M2; cannot be evaluated below ~20–30 fragments.

Build all three over the same corpus, offline, and look:

1. tags + domains as now
2. embeddings over `transcripts/` (kNN, cosine)
3. hybrid — embeddings for structure, a model call per edge for the label

The hybrid puts concepts *on the edges* as explanations of why two fragments
touched, which a tag cannot carry. Expected to win; not assumed to.

**Done when:** one method is chosen in `decisions.md` with the comparison that
justified it.

## M4 — The mosaic frontispiece

Blocked on M2 and on choosing the artwork. Tiles of one hidden artwork, one
revealed per fragment, each linking to its fragment. An index that indexes
nothing.

Open: tile count (sets the horizon), what happens at 100%, 2D vs 3D.
**Build 2D first.** Do not start before fragment ten — it is additive and
replaces one file.

## M5 — The tile artwork as its own release

The large existing digital artwork, cut and released, sharing the label scheme.
Only meaningful once M4 exists.

---

## Risks

| Risk | Why it matters | Counter |
|---|---|---|
| **Drift** | No external deadline; five months already lost | `/resume` reports days since last publish, plainly |
| **Elaboration over publishing** | The documented failure mode | Unresolved → `decisions.md`, publish anyway |
| **Disconnected graph** | 1 fragment, 6 tags, 4 domains, nothing recurring yet | Domains are the recurring layer; check at M2 |
| **Split tag nodes** | Case is folded by Quartz, but composed vs decomposed accents are not | Publish script NFC-normalises; near-misses (`Eliot` vs `T-S-Eliot`) are not caught |
| **Prompt drift** | The skill is outside the repo and unversioned | Consider vendoring a copy into `.claude/skills/` |
| **Quartz divergence** | 3+ modified files; v5 is 300+ commits ahead | Mark edits; decide on v5 at M3 |
| **Silent vision failure** | Plausible tags can be hallucinated | Transcripts make it visible |

## Triage

Short on time? In order: **publish a fragment** → fix something broken →
close an M1 unit → anything else. Never start M3–M5 in a short session.
