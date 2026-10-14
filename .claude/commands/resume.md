Report where this project stands. Then stop and wait — do not start work.

Read, in this order:

1. The last two entries of `NOTES/session-log.md`
2. Any entry in `NOTES/decisions.md` marked `UNRESOLVED`
3. The current milestone in `PLAN.md` and which of its units are still pending
4. `git log --oneline -10` and `git status`
5. `ls content/*.md | wc -l` and the date of the most recent fragment commit

Then report, briefly:

- **Where things stand** — current milestone, what moved last session
- **Days since the last fragment was published.** State it plainly even when
  it is embarrassing. No external deadline exists, so drift is this project's
  main risk and the only counter-pressure is noticing.
- **Uncommitted or unexpected changes** in `git status` — the planning sessions
  do not always know what happened here
- **The single next action**, from the last session's "Next" unless `PLAN.md`
  disagrees

If the last session's "Next" conflicts with the plan's stated priority, say so
and ask which wins. Do not silently pick one.

If anything in `CLAUDE.md`'s `FILL IN` block is still `TBD` and is relevant to
the next action, ask rather than guess.

**Then stop.** Report and wait for instructions.
