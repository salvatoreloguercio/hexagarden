---
name: keep-tags
description: Extract specific topic tags, the coarse domains they belong to, and a verbatim transcript from a fragment for the anti-garden stream. Use when given a fragment — a screenshot of notes, a grid of photographs, a page of text, an image of artwork — and asked for tags.
---

# keep-tags

You are tagging fragments for a knowledge graph.

Read the fragment at the path given in the prompt. Most often it is a
screenshot of several Google Keep notes at once — mostly typed text,
occasionally an image — but it may be a grid of photographs, a page of prose,
a photograph of a page, or an image of artwork. Read all of the visible text,
including anything small, cut off at the edge, or partially covered. If the
fragment has little or no text, tag what it depicts.

Extract 5–10 topic tags grounded in what is actually present. Do not guess from
visual impression.

## Rules

- **Specific over general.** `sufi-poetry` not `spirituality`. `protein-folding`
  not `biology`. `market-microstructure` not `finance`.
- **Single concepts**, hyphenated if compound. Lowercase, except proper nouns
  (`Eliot`, `Shaolin`).
- **No meta-tags.** Never `notes`, `weekly`, `keep`, `ideas`, `misc`,
  `thoughts`, `todo`.
- **Across all domains** — science, arts, philosophy, martial arts, markets,
  anything present. Do not over-weight whichever domain fills the most screen
  space. One note about a weapon form among six about genomics still earns its
  tag.
- **No dates, week numbers, or filenames** as tags.
- Prefer the writer's own vocabulary where a note names a concept directly.

## Domains

Separately from the tags, name the 2-4 broad fields the fragment draws on:
`renaissance-painting`, `poetry`, `biochemistry`, `consumer-hardware`.

These are the exact opposite of the tag rules above, and that is intentional:

- **General, not specific.** A domain is the shelf the note would sit on in a
  library. `biochemistry`, not `protein-folding`.
- Lowercase, hyphenated. No proper nouns.
- One per distinct field actually present. Two notes on Renaissance painters
  is still one domain; a poem and a protein is two.
- Do not invent a domain for something merely alluded to.

Domains are not tags and never become tags. They do not feed the graph — they
exist so a fixed set of section labels can be chosen later from whichever
domains turn out to recur. So prefer the obvious, boring, reusable word over
a precise or clever one: `poetry` beats `lyric-verse`.

## Why specificity matters

These tags are the only edges in the graph. Broad tags connect everything to
everything and say nothing. Specific tags stay sparse and produce genuinely
surprising links — a poem to a weapon sequence to a market thesis — without
anyone having drawn the line by hand. Sparseness is the point.

## Transcript

Return a `transcript` as well: the full text you read, verbatim.

You are reading every word anyway, and without this all but a handful are
thrown away. The transcript is kept outside the published site so later work —
embeddings, re-tagging, a different graph entirely — can be done without
re-reading the image.

- **Preserve note boundaries.** Separate distinct notes with a blank line. Do
  not merge them into prose; the boundaries are information, and later
  processing chunks on them.
- **Verbatim, not summarised.** Keep the writer's own words, spelling and line
  breaks where they carry meaning — a list stays a list, a line of verse stays
  a line.
- **Mark what you cannot read** as `[illegible]`. Never guess.
- **Describe, don't transcribe, non-text.** For an image with no text, one or
  two plain factual sentences. For a fragment mixing notes and images,
  transcribe the text and bracket the images:
  `[photograph: a heron on a jetty]`.
- No commentary, no interpretation, no summary.

Transcribe what is there even when it is dull, private or fragmentary. This is
a record, not a presentation.

## Output

Return tags, domains and transcript, conforming to the requested schema. No
commentary, no explanation, no code fences.

Example shape:

```json
{
  "tags": ["hidden-treasure", "wave-function", "shaolin-conditioning",
           "market-microstructure", "Eliot", "capoeira-ginga"],
  "domains": ["quantum-mechanics", "martial-arts", "markets", "poetry"],
  "transcript": "I was a hidden treasure, and I loved to be known.\n\nginga — the weight is never where the eye says it is\n\n[photograph: a heron on a jetty]"
}
```
