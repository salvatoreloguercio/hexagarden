Publish a fragment: $ARGUMENTS

`$ARGUMENTS` is a path to an image, optionally followed by a week label. If no
week label is given the script derives it from the filename.

## Preconditions — assert these before running anything

Stop and report if any fail. Publishing is externally visible and a bad
fragment is awkward to withdraw.

1. The file exists and is an image.
2. `git status` is clean, or the only changes are ones I have just approved.
   Never publish on top of unrelated work in progress.
3. `jq`, `python3` and `claude` are all on PATH.
4. `ANTHROPIC_API_KEY` is **not** set in the environment. The script clears it
   per-call, but if it is set globally something else may pick it up.

## Then

Run with `--dry-run` **first**, always:

```
./publish-keep.sh <image> [week] --dry-run
```

Show me:

- the derived week and date — check these against the filename yourself and
  flag anything implausible (a capture date in the future, a week that does
  not match the filename's date)
- the hex label, and whether it extended beyond 5 digits (if so, say which
  existing fragment it collided with)
- the proposed tags, and **which of them already exist** on other fragments.
  If none recur, say so — tags are the only edges in the graph, and a fragment
  that shares no tags connects to nothing.
- the first ~200 words of the transcript, and whether it plausibly matches the
  image. A verbatim transcript is the only check that the model actually
  received the image; six plausible tags can be hallucinated.
- the generated markdown in full

**Then stop and wait for my approval.** Do not publish from the dry run.

## On approval

Run it for real, then confirm the Actions run goes green and the fragment
loads at its URL.

## Do NOT

- publish without a dry run
- edit the tags yourself — propose, and let me decide
- "fix" a transcript that looks wrong; report it instead, because a wrong
  transcript means the vision step failed and that is worth knowing
- touch `content/index.md` — the landing page is static by decision
