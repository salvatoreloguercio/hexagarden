---
title: "Colophon"
date: 2026-09-16
draft: false
---

A colophon is the note a scribe left at the end of a manuscript, recording who
made the book and how. This one records how this one is made.

## The unit

Each fragment here is a screenshot of several notes held at once — a view, not
a note. What is published is the constellation, not any single thought in it.

Nothing is captioned. Nothing is explained. The label is a hexadecimal string
and the only other thing on the page is the date it surfaced.

## The label

Each fragment is named by the first five hexadecimal digits of the SHA-256 hash
of its capture week:

```
2025-W32  →  sha256  →  d5fbe
```

The mapping is deterministic, so the same week always yields the same label and
any label can be recomputed from nothing. It is also one-way: `d5fbe` can be
checked against `2025-W32`, but it cannot be read back into it. The week is a
preimage, and preimages are not recoverable.

Five digits is not enough to guarantee uniqueness forever. When two weeks would
claim the same label, the later one takes a sixth digit. So a label of unusual
length is a record of a collision, and the only thing on this site that carries
any information about a fragment other than itself.

The labels are not sequential. They leak no order of publication.

## The gap

The date on a fragment is the date it was published, not the date it was
written. Those are independent. A fragment surfacing this week may have been
captured two years ago, and there is no way to tell from the page which.

## The tags

No tag here was written by a person.

Each screenshot is read by a language model, which returns five to ten specific
topic tags grounded in the text it can see. The instruction it follows asks for
specificity over generality — `sufi-poetry` rather than `spirituality`,
`protein-folding` rather than `biology` — and forbids meta-tags. Specific tags
stay sparse, and sparse tags produce the occasional surprising edge instead of
connecting everything to everything.

The tags are reviewed before publishing, then written into the file's
frontmatter. They are never rendered. You cannot see them.

## The graph

The tags are the only edges. Every connection in the graph was inferred from
what the fragments happen to contain, and no line in it was drawn deliberately.
The structure is a consequence, not a plan.

This is why the graph is the navigation. There is no index, no chronology, no
categories. You are not told where to go.

## The apparatus

Quartz, static, deployed from a push. One shell script does the rest: copies
the image in, calls the model, takes the tags, computes the label, writes the
file, commits, pushes. The site rebuilds itself.

The banner is a detail from the Chi-Rho page of the Lindisfarne Gospels — the
incipit to Matthew, written on Holy Island around the year 700. The
digitisation is faithful and therefore muted; the colour here has been pushed
back toward how it was meant to look when it was made. The interlinear glosses
visible in the original were added by Aldred, a priest, some two hundred and
fifty years after the book was finished. He was annotating someone else's work
in a language its makers did not write.

The tagging here is the same gesture, performed by a machine.

## On the method

This is not a garden, whatever the name promises. Nothing here is cultivated,
pruned, or arranged for a reader's benefit. The fragments accumulate, the graph
thickens, and any pattern you find in it is one you brought with you or one
that was already there.

> These fragments I have shored against my ruins.
