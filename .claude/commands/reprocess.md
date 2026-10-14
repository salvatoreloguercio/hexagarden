Re-run an existing fragment through the current pipeline: $ARGUMENTS

`$ARGUMENTS` is a hex label (`29c26`) or a week (`2019-W21`). Either resolves
to the same fragment.

Use this after the tagging skill changes, or after the extraction schema
changes — the whole point of vendoring the skill is that its effects are
reproducible, and that only holds if old fragments can be brought forward.

## Work out what to run

1. Resolve the label: `./publish-keep.sh --label <week>`, or read `week:` from
   `content/<hex>.md` if given a hex.
2. The source image is `content/keep-<hex>.<ext>` — the published copy is the
   only copy, which is fine, it is the same file.
3. The filename carries no date, so the week **must** be passed explicitly.

## Preconditions — assert before touching anything

Stop and report if any fail.

1. `git status` is clean. This rewrites a published fragment; the diff is the
   only record of what changed, and it is worthless mixed with other work.
2. No stale `.git/index.lock`. If one exists and no git process is running,
   say so and ask before removing it.
3. The `keep-tags` skill resolves — `skill_installed` in `publish-keep.sh`
   covers this, but check `.claude/skills/keep-tags/SKILL.md` exists.

## Then

```
./publish-keep.sh content/keep-<hex>.<ext> <week> --dry-run
```

Answer `y` to the overwrite prompt — rewriting is the intent here.

**Note `--dry-run` still writes files.** It skips the commit, not the write. So
the working tree is now modified and `git checkout content/<hex>.md` is the
undo.

Show me:

- `git diff content/<hex>.md` — what tags and domains changed, and whether any
  changed for the worse
- the first ~200 words of `transcripts/<hex>.txt`, and whether it plausibly
  matches the image. **This is the only check that the model received the
  image at all** — tags can be invented, a verbatim transcript cannot
- anything that looks like the model describing its own confusion rather than
  the fragment, which is what a missing skill produces

**Then stop.** Do not commit. I decide whether the new tags are better than the
old ones; that is a judgment about the work, not about the code.

## Do NOT

- reprocess more than one fragment without showing me the first
- edit tags by hand to "improve" the result — if the output is wrong, the skill
  is wrong, and that is the thing to fix
- run this with uncommitted work in the tree
