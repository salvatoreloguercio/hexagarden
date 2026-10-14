# hexagarden

A conceptual art project that publishes fragments — screenshots of notes, text,
images, anything — to a static site, each labelled with an opaque hex code and
connected to the others only by machine-extracted tags. It is deliberately an
*anti*-garden: nothing is curated, categorised, annotated or arranged for a
reader. Solo project, run in spare time, no deadline.

Live at `https://salvatoreloguercio.github.io/hexagarden/`

## Goal, and what wins

**Primary: the work as an art object.** Conceptual and aesthetic coherence
outrank publishing velocity. It is acceptable to publish nothing for a month
while a structural question is settled.

**Secondary: the apparatus.** It serves the work. Generalise it when that is
cheap; do not polish it for its own sake.

### The one rule that exists because violating it is costly

> A structural question may pause publishing. A *preference* may not.

This project was parked for five months (April–September 2026) holding a
complete, correct plan. The failure mode is elaboration, not haste. So: when
something feels unresolved, write it into `NOTES/decisions.md` marked
`UNRESOLVED` and publish anyway. Revisit with evidence from more fragments
rather than from more thinking.

## Working agreements

- **Opacity is experiential, not cryptographic.** The repo is public and
  `date:` reaches RSS. With only ~2,000 plausible week labels and the scheme
  published in the colophon, the hash has no preimage resistance. The hex
  shapes how the site *reads*; it hides nothing from anyone determined.
- **Hiding is cheap, repositioning is expensive.** Every layout bug so far came
  from forcing Quartz's furniture somewhere it doesn't go. If a fix needs
  `position`, `order`, `flex` or `z-index` on a sidebar, it is the wrong fix.
- **Tags and domains are the only edges.** Fragments never link to each other.
  Turn off `showTags` and the graph becomes disconnected dots.
- **Never block a publish.** If an optional step fails, warn and publish
  anyway. Friction is the one thing this project cannot afford.
- **No sections, no categories, no chronology.** A poem, a weapon sequence and
  a Keep screenshot are all fragments in one flat namespace. "Latest" is a feed
  value and does not belong at the entry point.

## The two label layers

| | Purpose | Recurs? |
|---|---|---|
| `tags` | hyper-specific — `Cosmè-Tura`, `one-wild-precious-life` | rarely, by design |
| `domains` | coarse — `poetry`, `biochemistry` | often — this is what connects fragments |

Specific tags create *surprising* connections when they happen; domains create
connections *at all*. Keep both. Do not make tags more general to fix
connectivity — that is what domains are for.

**Case does not matter; Unicode does.** Quartz slugifies every tag
(`slugTag`, via `github-slugger`), which lowercases — so `Eliot` and `eliot`
are one node, and the site only ever shows the lowercase slug. But a composed
`è` and `e` plus a combining grave slug differently and become two nodes that
look identical; `publish-keep.sh` NFC-normalises to prevent it. Frontmatter
follows the skill's rule, lowercase except proper nouns (`Cosmè-Tura`,
`allegory-of-prudence`), for the repo's readability only.

## Hard constraints

- `claude -p` runs under `env -u ANTHROPIC_API_KEY` **on purpose**, so tagging
  bills the subscription. Never add `--bare` — bare mode requires an API key.
- ISO week ↔ date conversion uses `python3` `isocalendar()` **deliberately**.
  BSD and GNU `date` disagree on `%V`/`%U` and mishandle 53-week years.
  `2019-12-31` must yield `2020-W01`.
- Collapsed graph containers use `max-height: 0`, never `display: none` — d3
  reads `offsetWidth`, and a zero-width container renders nodes in a corner.
- Graph click handlers must be **module-level** functions. Quartz rebinds on
  every SPA navigation and `removeEventListener` only matches stable refs.
- Asset URLs in SCSS must be **relative** (`url("static/…")`). The site is
  served from a subpath; an absolute path breaks silently.
- `KEEP_HEX_LEN` is effectively frozen at 5. Changing it after publishing
  rewrites every URL.

## Environment

```
repo          ~/projects/personal/hexagarden      branch main
deploy        push → GitHub Actions → Pages (project site, subpath)
quartz        v4.1.1, forked and modified (upstream is on v5)
publish       ./publish-keep.sh <image> [week] [--dry-run|--manual|--no-tags]
label lookup  ./publish-keep.sh --label 2019-W21   → 29c26
requires      jq, python3, claude
```

**The tagging skill is vendored** at `.claude/skills/keep-tags/SKILL.md`, so
the prompt is versioned alongside the fragments it produced. `extract_tags()`
runs `cd "$REPO"` before calling `claude` so the project skill is in scope
wherever the script was invoked from.

`publish-keep.sh` still guards for it with `skill_installed()` and fails loudly
if absent — without that, `claude` treats `/keep-tags` as ordinary prose and,
because the call forces a schema, fills it with words describing its own
confusion. Silent, plausible garbage.

**Editing the skill changes every future fragment.** It is a diff in this repo
now, which is the point — but a diff nobody reads is no safer than none, so say
in the commit message what behaviour changed.

## Modified from upstream Quartz

Check `git log -- quartz/` before editing anything under `quartz/`. Known:

- `quartz/components/BannerToggle.tsx` — custom component, not upstream
- `quartz/components/scripts/graph.inline.ts` — module-level handlers
- `quartz/styles/custom.scss` — the whole anti-garden block

Leave a comment marking any new edit, so a future v5 migration can find it.

## Repo map

```
CLAUDE.md                   this file
PLAN.md                     milestones and risks
NOTES/decisions.md          what was chosen, why, what would change it
NOTES/session-log.md        where each session left off
publish-keep.sh             the whole publish pipeline
.claude/commands/           /resume, /wrap-up, /publish
content/                    fragments (flat, hex-named) + index.md, about.md,
                            colophon.md, and some non-fragment pages
quartz/                     forked Quartz — see above
```

## Session ritual

Start with `/resume`. End with `/wrap-up`. Both read and write `NOTES/`.

Commands: `/publish <image>`, `/reprocess <hex|week>`.

The desktop app has access to this repo and should **write into `NOTES/`**, not
into chats that then have to be mined. If you find yourself composing a long
prompt to paste between tools, write it to `NOTES/` instead — that is the
failure this structure exists to prevent.

### If the desktop app writes a shell block, a slash command is missing

The point of this setup is that operations are one word here, not a sequence
of commands typed somewhere else. A pasted block of `cd && ./script && git …`
means the operation has no command yet. Write one instead of running it.

The desktop app has additive-only access to this repo: it can create and edit
files but **cannot delete them**, so git cannot run from that side at all — a
stale `.git/index.lock` left by an attempted `git status` has to be removed by
hand. Anything touching git belongs in Claude Code.
