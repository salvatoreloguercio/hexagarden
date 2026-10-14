# hexagarden

A conceptual art project. Fragments — screenshots of notes, text, images —
published to a static site, each labelled with an opaque hex code, connected
only by machine-extracted tags and domains. No categories, no chronology, no
annotation.

https://salvatoreloguercio.github.io/hexagarden/

Built on a fork of [Quartz v4](https://quartz.jzhao.xyz/), modified
substantially. See `CLAUDE.md` before editing anything under `quartz/`.

## Start here

| If you want to | Read |
|---|---|
| Work on this | `CLAUDE.md`, then `/resume` in Claude Code |
| Know what's next | `PLAN.md` |
| Know why something is the way it is | `NOTES/decisions.md` |
| Know what happened last time | `NOTES/session-log.md` |
| Read the published concept | `content/colophon.md` |

## Publish a fragment

```bash
./publish-keep.sh ~/Downloads/Screenshot_20190524-200251.png --dry-run
./publish-keep.sh ~/Downloads/Screenshot_20190524-200251.png
```

The week and date come from the filename. A label is `sha256(week)[:5]` —
`2019-W21` → `29c26`. Look one up without publishing:

```bash
./publish-keep.sh --label 2019-W21
```

In Claude Code, `/publish <path>` runs the dry-run checks first.

Tagging needs the `keep-tags` skill installed at
`~/.claude/skills/keep-tags/SKILL.md`. The script fails loudly if it is
missing — see `NOTES/decisions.md` for why that guard exists.

## Where things live

```
content/        fragments (flat, hex-named) + index.md, about.md, colophon.md
quartz/         forked Quartz v4.1.1, modified — check git log before editing
NOTES/          decisions and session log
```

## Division of labour

Code and data → Claude Code, where the code is.
Reading, writing, thinking → the desktop app, **writing into `NOTES/`**.
Deciding what to build next → Claude Code plan mode (Shift+Tab).

The repo is the shared state. If you find yourself composing a long prompt to
paste from one tool into another, write it into `NOTES/` instead — that is the
failure this structure exists to prevent.
