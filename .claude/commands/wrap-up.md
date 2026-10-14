Close out this session by writing state into the repo.

1. **Append an entry to `NOTES/session-log.md`** — today's date, one line of
   context, then three sections:

   - **Done** — what actually changed. Name files and numbers. Not "improved
     the graph" but "graph labels were rendering at opacity 0 —
     `(opacityScale - 1) / 3.75` with the default `opacityScale: 1`; set to 4".
   - **Open / broke** — anything left failing, half-done, or unverified. Be
     honest here; this is the section that saves the next session.
   - **Next** — the single action to start with. One, not a list.

   Write it for a stranger. In three weeks that is who will read it.

2. **Close out any directives you executed** in `NOTES/directives.md` — record
   the outcome under the directive's own heading and mark it `DONE` or
   `BLOCKED`, with what blocked it. Do not delete completed directives; the
   outcomes are the record of what the pipeline actually did.

3. **Capture any new decisions** in `NOTES/decisions.md` — but only ones that
   would otherwise be re-litigated. Each needs the choice, the reason, and
   **what would change it**. Routine implementation choices do not belong here.

   If something was discussed but not settled, add it marked
   `**Status:** UNRESOLVED — do not build on this` rather than leaving it in
   your head.

4. **Update `PLAN.md`** only if a milestone's units changed state. Do not
   rewrite the plan.

5. **Do not commit on my behalf.** Show me `git status` and what you have
   written, and let me commit.

Then report the project's state in two sentences. Include days since the last
fragment was published.
