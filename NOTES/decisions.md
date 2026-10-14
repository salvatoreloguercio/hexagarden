# Decisions

Append-only, newest at the bottom. Each entry: the choice, the reason, and
**what would change it** — that last part is what makes this useful rather
than a diary.

Only decisions worth not re-litigating. Routine implementation choices are
noise here.

---

## Anti-garden, not garden
**Chose:** fragments published bare — no caption, no annotation, no categories,
no chronology — against the digital-garden model of cultivation and curation.
**Why:** Eliot's "heap of broken images"; the hadith "I was a hidden treasure,
and I loved to be known". Publishing as emanation, not broadcast.
**Would change it:** nothing short of abandoning the concept. This is the
project.

## Quartz, forked, not a bespoke generator
**Chose:** stay on Quartz v4.1.1 rather than build a ~200-line static generator.
**Why:** the graph is the navigation and would otherwise have to be rebuilt —
it is 329 lines of d3-force that already exist in this repo and are fully
editable. "No control over the graph" was false; Quartz v4 is a template you
fork, not a dependency you install.
**Would change it:** if the fights move from CSS into the build pipeline
itself. Content is plain markdown + images, so the exit stays cheap.

## Quartz v5 deferred
**Chose:** not upgrading now. Upstream default branch is v5; `v4` is 304
commits behind.
**Why:** the layout question is version-independent — v5 also ships three
columns with sidebars. Upgrading mid-implementation adds a variable.
**Would change it:** revisit at M3. Cost grows with every edit under `quartz/`;
currently a small number of files. v5 likely has a dynamic OG-image emitter,
which would give each fragment its own social preview.

## Name: hexagarden
**Chose:** the author's own working name, over `heap`, `hexarium`, `siccus`,
`hortus-siccus`, `antihortus`, `gloss`, `shored`, `cairn`, `incipit`, `quire`,
`preimage`, `hord`, `moraine`, `ometto`, `sekitei`.
**Why:** pronounceable in both his languages, states both halves of the
concept, and "garden" works as misdirection rather than a tell.
**Two findings worth keeping:** Latin is *transparent* to an Italian ear, not
opaque — `siccus` reads as *secco*/*essiccato*, withered. And test names against
disease: `hexarium` echoes *hexamitiasis*.
**Would change it:** renaming is cheap. GitHub redirects repos but **not**
project-site Pages URLs; a two-line meta-refresh stub at `hexagarden/index.html`
in the user repo preserves old links permanently.

## Labels: 5 hex digits, no `0x`, auto-extending
**Chose:** `sha256(week)[:5]`, no prefix, lengthening by a digit when a label
is already held by a different week.
**Why:** the prefix is identical on every fragment so it carries no
information. On length: do not trade looks for probability when the collision
can be designed away — `2019-W39` and `2029-W41` share their first *six*
digits, so no length short enough to look good was ever safe.
**Related finding:** "no collisions observed" is not "no collisions possible".
4 digits was chosen on a 208-week sample with a 28% birthday probability.
**Test truncated hashes against the birthday bound, not a sample.**
**Would change it:** changing `KEEP_HEX_LEN` after publishing rewrites every
URL. Effectively frozen.

## Opacity is experiential, not cryptographic
**Chose:** accept that the week is recoverable.
**Why:** the repo is public so `week:` is readable in source; `date:` becomes
the RSS `<pubDate>`; and with only ~2,000 plausible week labels and the scheme
published in the colophon, the hash has **no preimage resistance** — a lookup
table takes milliseconds.
**Consequence:** the colophon's claim that "preimages are not recoverable" is
false and must be rewritten.
**Would change it:** a secret salt, or random labels. Random is preferred if
revisited — it makes the label genuinely meaningless and removes the false
claim.

## Fragments at the content root
**Chose:** `content/d5fbe.md`, not `content/weekly/d5fbe.md`.
**Why:** a folder is a category, and the premise is that fragments aren't
categorised. URL is opaque end to end.
**Cost:** `content/` is flat and gets busier with every fragment. Accepted.
**Would change it:** nothing foreseeable. Quartz v4.1.1 has no per-page slug
override, so this is the only way to get the URL.

## Two layout modes instead of one compromise
**Chose:** bare by default (fragment alone, sidebars hidden); `body.expanded`
restores stock three-column Quartz with the graph.
**Why:** every layout bug came from repositioning Quartz's furniture. Bare mode
only *hides*; Open mode overrides nothing. The single remaining override is
`body.expanded .graph.desktop-only { display: block }`, visibility only —
Quartz hides `.desktop-only` below 1510px, which is most laptops.
**Would change it:** if stock Quartz breaks at some width, that is a Quartz
issue to raise, not something to patch around.

## The banner is the only home link
**Chose:** `pageTitle` text visually hidden via `text-indent`, banner as the
anchor.
**Why:** top-left-is-home needs no teaching, so opacity costs nothing.
**Correction already applied:** `pageTitle: ""` left the link with no
accessible name and the RSS channel with no title. Text must be present and
hidden, not absent.

## Transcripts captured, stored outside `content/`
**Chose:** the model returns tags *and* a verbatim transcript; transcripts go
to `transcripts/` at the repo root.
**Why:** the model reads every word and six were being kept. Storing the text
makes embeddings, re-tagging and any future graph method possible without
re-reading images. Outside `content/` so Quartz never publishes it — no RSS
leakage, no og:description leakage.
**Secondary benefit:** a verbatim transcript cannot be hallucinated, so it is
the first real test that the Read tool is delivering images at all.
**Would change it:** if search becomes wanted, build a custom index from
transcripts rather than moving the text into the page.

## Two label layers: specific tags, coarse domains
**Chose:** the extraction returns both `tags` (hyper-specific — `Cosmè-Tura`,
`one-wild-precious-life`) and `domains` (coarse — `poetry`, `biochemistry`).
Domains are accumulated open-endedly, with no enum.
**Why:** "specific over general" fights recurrence, and tags are the only
edges — hyper-specific tags would give one isolated island per fragment. Rather
than making tags more general and losing the surprise, a second coarser layer
carries connectivity while tags keep their precision. Specific tags create
*surprising* connections when they happen; domains create connections *at all*.
**Supersedes:** an earlier plan to force tag-vocabulary reuse by passing
existing tags into the prompt. That would have blunted tags to do a job domains
now do better. If vocabulary reuse is wanted anywhere, it belongs on **domains**
— they are the layer that should converge.
**Would change it:** if embeddings replace both as the structural layer (M3),
this matters much less. If domains also fail to recur by fragment ten, the
extraction is too specific at both layers.
**Open:** whether domains should become a closed enum once a vocabulary
settles. Open-ended is right while the set is still forming.

## Casing must be normalised
**Chose:** flagged, not yet fixed.
**Why:** `Poetry` and `poetry` are different nodes. Current tags are
inconsistent — `Cosmè-Tura`, `Erato`, `Mary-Oliver` capitalised against
`allegory-of-prudence`, `one-wild-precious-life` lowercase. At one fragment
this is invisible; at thirty it silently halves the graph.
**Status:** fix before volume. Also `Fprotein-folding` — a typo'd tag is a
permanent orphan by construction.

## Everything is a fragment; no sections
**Chose:** one flat namespace for writing, art, body practice, ideas, captures.
**Why:** the pipeline never cared what a fragment is. This **reverses** the
April decision ("separate sections, not interleaved; interleaving rejected as
too elaborate") — correct then, backwards now. Interleaving is the default;
separation would be the extra work.
**Status:** details UNRESOLVED — revisit after sizable content exists. Do not
build sections in the meantime.

## The tagging skill lives outside the repo
**Chose:** `~/.claude/skills/keep-tags/SKILL.md`, with a `skill_installed()`
guard in `publish-keep.sh` that fails loudly when it is missing.
**Why the guard:** without it, `claude` treats an unknown `/keep-tags` as
ordinary prompt text and — because the call forces a tags schema — fills it
with words describing its own confusion. Silent, plausible garbage.
**Cost:** the prompt is not version-controlled with the project. Editing it
changes every future fragment with no diff in this repo, and a fresh machine
produces different tags until the skill is installed.
**Would change it:** vendor a copy into `.claude/skills/` so the prompt is
versioned alongside the fragments it produced. Worth doing before the corpus
is large enough that prompt drift would be invisible.

## Frontispiece: static now, mosaic later
**Chose:** a static full-bleed illumination as the landing page now. **Not**
the latest fragment.
**Status:** implemented 2026-10-13, reconfirmed by Salvatore the same day.
Commit `0c63ffd` (2026-09-21, never pushed) had made `/` a copy of the newest
fragment, rewritten by `publish-keep.sh` on every publish. Only that part was
reverted: `content/index.md` is back to the Lindisfarne gif that was live all
along, and the script no longer writes or stages it. About and the banner
changes from the same commit stand.
**Open, not blocking:** which illumination, and full-bleed or not. The current
page is a 300×284 gif plus "Welcome!", which `0c63ffd` rightly called a
welcome mat. Candidate: `quartz/static/banner-full.webp`, the full Chi-Rho.
**Why:** "latest" reintroduces chronology and currency at the exact moment a
visitor forms their model of the site, and the project rejects recency
everywhere else. It also forced the publish script to rewrite `index.md`,
duplicating a fragment as a graph node.
**Later:** the mosaic — tiles of one hidden artwork, one revealed per fragment,
each linking to its fragment. An index that indexes nothing, and a literal
enactment of the hadith.
**Status:** UNRESOLVED — tile count (sets the horizon), what happens at 100%
(the project acquires an end state it has never had), 2D vs 3D. **Build 2D
first.** Do not build before fragment ten; the mosaic is additive and replaces
one file.

## Graph method: tags now, probably hybrid later
**Status:** UNRESOLVED — do not build on this.
Candidate: embeddings over transcripts for structure, a model call per kNN
edge for the label, so concepts sit **on the edges** as explanations of why two
fragments touched. A tag cannot carry *"joined by: the idea that constraint is
what makes improvisation legible"*.
**Blocked on:** ~20–30 fragments. Cannot be evaluated at n=1.
**Note:** a fragment with six tags is a *hyperedge*, not an edge. The current
bipartite graph is already its incidence form — so "concepts as nodes,
fragments as edges" is a rendering change, not a structural one, unless clique
expansion is used.
