#!/usr/bin/env bash
#
# publish-keep.sh — publish one Keep screenshot to the weekly stream
#
#   ./publish-keep.sh <image> [week-label] [options]
#   ./publish-keep.sh ~/Downloads/Screenshot_20190524-200251.png
#   ./publish-keep.sh ~/Downloads/shot.png 2025-W32
#
# The week label is optional. Left off, it is read from the capture date in
# the image filename (Screenshot_20190524-... or 2019-05-24-...), and that
# exact date becomes the fragment's date:. Pass a label explicitly and it
# wins — but a week implies no particular day, so --date is required with it.
#
# Options
#   --manual            skip LLM tagging, type tags by hand
#   --dry-run           write the files, show them, don't commit or push
#   --date YYYY-MM-DD   set date: explicitly; required with a week label
#   --no-tags           publish with no tags at all
#   -h, --help          this message
#
# Look up a week's label without publishing anything:
#   ./publish-keep.sh --label 2025-W32       ->  d5fbe
#
# Tagging runs through headless Claude Code on your subscription.
# No ANTHROPIC_API_KEY required — and if one is set, it is unset for
# the call so billing stays on the subscription.

set -euo pipefail

# ---------------------------------------------------------------- config

REPO="${KEEP_REPO:-$HOME/projects/personal/hexagarden}"
FRAGMENT_SUBDIR="content"
MODEL="${KEEP_MODEL:-sonnet}"
SKILL="/keep-tags"
HEX_LEN="${KEEP_HEX_LEN:-5}"   # hex chars in a fragment label; see resolve_label()

# ---------------------------------------------------------------- helpers

die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info() { printf '\033[2m%s\033[0m\n' "$*" >&2; }
ok()   { printf '\033[32m%s\033[0m\n' "$*" >&2; }

usage() { sed -n '2,26p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

# The tagging skill lives outside this repo, in ~/.claude/skills. A fresh
# clone therefore looks complete and then quietly produces nonsense: headless
# claude treats an unknown "/keep-tags" as ordinary prompt text and, because
# the call forces a tags schema, fills it with words describing its own
# confusion (keep-tags-unavailable, command-not-found). That lands in the
# frontmatter and is easy to miss, so check up front instead.
skill_installed() {
  local n="${1#/}" f
  for f in "$HOME/.claude/skills/$n/SKILL.md" "$REPO/.claude/skills/$n/SKILL.md"; do
    if [ -f "$f" ]; then return 0; fi
  done
  # Synced and plugin skills nest under a generated bucket directory, so match
  # the declared name rather than the path.
  if grep -rqs --include='SKILL.md' "^name:[[:space:]]*${n}[[:space:]]*$" \
       "$HOME/.claude/skills" "$HOME/.claude/plugins" 2>/dev/null; then
    return 0
  fi
  return 1
}

# ------------------------------------------------------------- date helper
# Defined up here, not down in the date section, because the week has to be
# settled before resolve_label() hashes it.

# Capture date out of the filename: "2019-05-24-..." first, else a bare
# "20190524" run as Android writes it. Prints "<week> <date>". The date is
# sanity-checked against a plausible range so a resolution like 20481080 or
# a version string can't be read as a day.
week_from_filename() {
  local base ymd
  base="$(basename "$1")"
  ymd="$(printf '%s' "$base" | grep -oE '(19|20)[0-9]{2}-[0-9]{2}-[0-9]{2}' | head -1)"
  if [ -z "$ymd" ]; then
    ymd="$(printf '%s' "$base" | grep -oE '(19|20)[0-9]{6}' | head -1)"
    [ -n "$ymd" ] && ymd="${ymd:0:4}-${ymd:4:2}-${ymd:6:2}"
  fi
  [ -n "$ymd" ] || return 1
  python3 - "$ymd" <<'PY'
import datetime, sys
try:
    d = datetime.date.fromisoformat(sys.argv[1])
except ValueError:
    sys.exit(1)
if not (datetime.date(1990,1,1) <= d <= datetime.date.today()):
    sys.exit(1)
y, w, _ = d.isocalendar()
print(f"{y}-W{w:02d} {d.isoformat()}")
PY
}


# ---------------------------------------------------------------- args

IMG=""; WEEK=""; MANUAL=0; DRYRUN=0; NOTAGS=0; DATE_OVERRIDE=""; LABELONLY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --manual)  MANUAL=1; shift ;;
    --dry-run) DRYRUN=1; shift ;;
    --no-tags) NOTAGS=1; shift ;;
    --label)
      LABELONLY=1; IMG="-"
      WEEK="${2:-}"
      [ -n "$WEEK" ] || die "--label needs a week (e.g. --label 2025-W32)"
      shift 2 ;;
    --date)    DATE_OVERRIDE="${2:-}"; shift 2 ;;
    -h|--help) usage ;;
    -*)        die "unknown option: $1" ;;
    *)
      if   [ -z "$IMG" ];  then IMG="$1"
      elif [ -z "$WEEK" ]; then WEEK="$1"
      else die "unexpected argument: $1"
      fi
      shift ;;
  esac
done

[ "$LABELONLY" -eq 1 ] || [ -n "$IMG" ] || die "no image given. see --help"
[ "$LABELONLY" -eq 1 ] || [ -f "$IMG" ] || die "image not found: $IMG"

# Only the LLM path needs the skill: --manual and --no-tags never call it, and
# --label exits before tagging. Checked here so a missing skill costs nothing.
if [ "$LABELONLY" -eq 0 ] && [ "$NOTAGS" -eq 0 ] && [ "$MANUAL" -eq 0 ]; then
  skill_installed "$SKILL" || die "the $SKILL skill is not installed, so tagging
       would return nonsense instead of failing. install it:

         mkdir -p ~/.claude/skills/${SKILL#/}
         cp SKILL.md ~/.claude/skills/${SKILL#/}/

       or skip the LLM for this run:  --manual  (type them)  /  --no-tags"
fi

# The week is optional: a screenshot already carries its capture date in the
# filename. Only consulted when no label was passed, so an explicit label
# always wins. CAPTURE_DATE is set only on this path, and is what makes the
# date: exact rather than the Monday of the week.
CAPTURE_DATE=""
if [ -z "$WEEK" ] && [ "$LABELONLY" -eq 0 ]; then
  if derived="$(week_from_filename "$IMG")"; then
    WEEK="${derived%% *}"
    CAPTURE_DATE="${derived##* }"
    info "week $WEEK read from filename (captured $CAPTURE_DATE)"
  fi
fi

# A week alone no longer yields a date, so point at both flags: following
# the old advice would just walk into the date check a few lines down.
[ -n "$WEEK" ] || die "no date in filename; pass the week and date explicitly
       (e.g. 2019-W21 --date 2019-05-24)"

# normalise + validate the week label: YYYY-Www
WEEK="$(printf '%s' "$WEEK" | tr '[:lower:]' '[:upper:]')"
case "$WEEK" in
  [0-9][0-9][0-9][0-9]-W[0-9][0-9]) : ;;
  [0-9][0-9][0-9][0-9]-W[0-9])      WEEK="${WEEK%W*}W0${WEEK#*W}" ;;
  *) die "week label must look like 2025-W32 (got: $WEEK)" ;;
esac

# The fragment label: sha256 of the week, truncated. Deterministic (the same
# week always yields the same label), non-sequential (leaks no publication
# order), and one-way — d5fbe can be verified against 2025-W32 but not read
# back from it. No 0x prefix: it is identical on every fragment, so it carries
# no information, and on a site where every title is hex the context says it.
#
# 5 digits is 20 bits. Collision probability over N weekly entries is ~1% at
# 145 posts, 10% at 470, 50% at ~1200 — roughly 25 years before the first one
# is expected. But averages are the wrong lens: 2019-W39 and 2029-W41 happen to
# share their first SIX digits, so no length short enough to look good is
# provably safe for real weeks. Hence resolve_label() below, which makes the
# question moot rather than trading looks for probability.
sha_of() { printf '%s' "$1" | shasum -a 256 | cut -c1-40; }

# Resolve a week to a label that is unique in the archive. Normally this is
# just the first HEX_LEN digits. If that label is already held by a DIFFERENT
# week, lengthen by one digit and try again — so a clash costs one extra
# character on one fragment, silently, instead of a scheme-wide migration.
# Re-publishing the same week returns the label it already has.
resolve_label() {
  local week="$1" full n label existing
  full="$(sha_of "$week")"
  n="$HEX_LEN"
  while [ "$n" -le 40 ]; do
    label="$(printf '%s' "$full" | cut -c1-"$n")"
    if [ ! -e "$DEST/$label.md" ]; then
      printf '%s' "$label"; return 0
    fi
    existing="$(sed -n 's/^week:[[:space:]]*//p' "$DEST/$label.md" | head -1)"
    if [ "$existing" = "$week" ]; then
      printf '%s' "$label"; return 0        # same week again, not a clash
    fi
    n=$((n + 1))
  done
  return 1
}

if [ "$LABELONLY" -eq 0 ]; then
  [ -d "$REPO/.git" ] || die "not a git repo: $REPO
       set KEEP_REPO to the right path, or edit REPO at the top of this script."
fi

# Filenames follow the label, so the URL stays opaque too. The week survives in
# a frontmatter field that nothing renders, which keeps the archive greppable
# and lets resolve_label() tell a clash from a re-publish:
#   grep -rl 2025-W32 content
DEST="$REPO/$FRAGMENT_SUBDIR"

if [ -d "$DEST" ]; then
  HEX="$(resolve_label "$WEEK")" || die "could not find a free label for $WEEK"
else
  HEX="$(sha_of "$WEEK" | cut -c1-"$HEX_LEN")"
fi

EXT="${IMG##*.}"
EXT="$(printf '%s' "$EXT" | tr '[:upper:]' '[:lower:]')"
[ "$EXT" = "$IMG" ] && EXT="png"
IMG_NAME="keep-${HEX}.${EXT}"
MD_PATH="$DEST/${HEX}.md"

# ---------------------------------------------------------------- date

# --label reports the hex and stops. It carries no image, so there is no
# capture date to find and nothing below applies to it.
if [ "$LABELONLY" -eq 1 ]; then
  printf '%s\n' "$HEX"
  exit 0
fi

# A week no longer implies a day: there is no Monday fallback. The date comes
# from the filename, or from --date, or the run stops. Nothing is guessed.
if [ -n "$DATE_OVERRIDE" ]; then
  case "$DATE_OVERRIDE" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) DATE="$DATE_OVERRIDE" ;;
    *) die "--date must be YYYY-MM-DD (got: $DATE_OVERRIDE)" ;;
  esac
else
  # Note this also fires when the filename HAS a date but a week label was
  # passed too: an explicit label suppresses derivation, so nothing set
  # CAPTURE_DATE. Dropping the label is usually what the user wants.
  [ -n "$CAPTURE_DATE" ] || die "no date for $WEEK: a week does not imply a day.
       pass one:          --date YYYY-MM-DD
       or drop the week label and let the filename supply the capture date."
  # Derived from the filename: the day it was actually captured.
  DATE="$CAPTURE_DATE"
fi

# ---------------------------------------------------------------- tags

TAGS=""
DOMAINS=""
TRANSCRIPT=""

extract_tags() {
  command -v claude >/dev/null 2>&1 || die "claude not found on PATH. use --manual"
  command -v jq     >/dev/null 2>&1 || die "jq not found on PATH. brew install jq"

  local abs schema out
  abs="$(cd "$(dirname "$IMG")" && pwd)/$(basename "$IMG")"
  # domains are accumulated open-endedly for now: no enum, because the point
  # is to find out which coarse labels actually recur before fixing a set.
  #
  # transcript: the model reads every word on the fragment anyway, and without
  # this all but a handful are thrown away. Kept so embeddings, re-tagging and
  # whatever graph method wins later can be derived without re-reading images.
  # It is also the only check that the image reached the model at all — six
  # plausible tags can be hallucinated, a verbatim transcript cannot.
  schema='{"type":"object","properties":{"tags":{"type":"array","items":{"type":"string"}},"domains":{"type":"array","items":{"type":"string"}},"transcript":{"type":"string"}},"required":["tags","domains","transcript"]}'

  info "reading $(basename "$abs") with claude ($MODEL)…"

  # ANTHROPIC_API_KEY is cleared for this call only: with it set, headless
  # runs can bill the API account instead of the subscription. Run from the
  # repo so the project's own .claude/skills/ is in scope wherever the script
  # was invoked from. stdin is closed: claude -p appends piped stdin to the
  # prompt, so without this it swallows the answers meant for the review gate
  # and the overwrite prompt below.
  if ! out="$(
    cd "$REPO" && env -u ANTHROPIC_API_KEY claude -p "$SKILL $abs" \
      --model "$MODEL" \
      --allowedTools "Read" \
      --permission-mode auto \
      --permission-prompts none \
      --output-format json \
      --json-schema "$schema" < /dev/null 2>/dev/null
  )"; then
    info "claude call failed."
    return 1
  fi

  TAGS="$(printf '%s' "$out" | jq -r '.structured_output.tags[]?' 2>/dev/null | tr '\n' ' ')"
  TAGS="${TAGS% }"

  # Deliberately NOT merged into TAGS: tags are the graph's only edges and are
  # kept sparse on purpose. Domains are coarse by design and would connect
  # everything to everything. They ride along in the frontmatter instead.
  DOMAINS="$(printf '%s' "$out" | jq -r '.structured_output.domains[]?' 2>/dev/null | tr '\n' ' ')"
  DOMAINS="${DOMAINS% }"

  # Unlike tags and domains this is never normalised, trimmed or reviewed: it
  # is meant to be exactly what the model read.
  TRANSCRIPT="$(printf '%s' "$out" | jq -r '.structured_output.transcript // empty' 2>/dev/null)"

  local cost
  cost="$(printf '%s' "$out" | jq -r '.total_cost_usd // empty' 2>/dev/null || true)"
  [ -n "$cost" ] && info "cost: \$$cost"

  [ -n "$TAGS" ] || { info "claude returned no tags."; return 1; }
  return 0
}

if [ "$NOTAGS" -eq 1 ]; then
  TAGS=""
elif [ "$MANUAL" -eq 1 ]; then
  printf 'tags (space separated, blank for none): ' >&2
  IFS= read -r TAGS || TAGS=""
else
  if ! extract_tags; then
    info "falling back to manual entry."
    printf 'tags (space separated, blank for none): ' >&2
    IFS= read -r TAGS || TAGS=""
  fi
fi

# --- review gate -------------------------------------------------------

if [ -n "$DOMAINS" ]; then
  printf '\n  \033[2mdomains:\033[0m %s\n' "$DOMAINS" >&2
fi

if [ -n "$TAGS" ]; then
  printf '\n  %s\n\n' "$TAGS" >&2
  printf 'enter to accept, or retype the list (- for none): ' >&2
  IFS= read -r REPLY_TAGS || REPLY_TAGS=""
  case "$REPLY_TAGS" in
    "")  : ;;
    "-") TAGS="" ;;
    *)   TAGS="$REPLY_TAGS" ;;
  esac
fi

# Quartz lowercases tags itself (slugTag, via github-slugger), so case never
# splits a graph node. Unicode does: macOS can hand over `è` as one code point
# or as `e` plus a combining grave, the slugger keeps them apart, and the graph
# shows two nodes that look identical. NFC makes them one. Runs after the
# review gate so typed lists are covered too; if python3 balks, warn and
# publish as typed.
nfc() {
  PYTHONIOENCODING=utf-8 python3 -c 'import sys, unicodedata
print(unicodedata.normalize("NFC", sys.stdin.read()), end="")'
}
for v in TAGS DOMAINS; do
  if n="$(printf '%s' "${!v}" | nfc)"; then
    printf -v "$v" '%s' "$n"
  else
    info "could not normalise $v; publishing them as typed."
  fi
done

# ---------------------------------------------------------------- write

mkdir -p "$DEST"

PUBLISHED="$(date +%Y-%m-%d)"

if [ -e "$MD_PATH" ]; then
  printf '%s already exists (%s). overwrite? [y/N] ' "${HEX}.md" "$WEEK" >&2
  IFS= read -r ans || ans=""
  case "$ans" in [yY]*) : ;; *) die "aborted." ;; esac
  # Overwriting is reprocessing, not republishing: the fragment keeps the day
  # it first went out.
  prev="$(sed -n 's/^published: *//p' "$MD_PATH" | head -n 1)"
  [ -n "$prev" ] && PUBLISHED="$prev"
fi

# Reprocessing passes the published image itself, and cp refuses to copy a
# file onto itself — under set -e that aborts before anything is written.
if [ ! "$IMG" -ef "$DEST/$IMG_NAME" ]; then
  cp "$IMG" "$DEST/$IMG_NAME"
fi

{
  printf -- '---\n'
  printf 'title: "%s"\n' "$HEX"
  printf 'date: %s\n' "$DATE"
  printf 'week: %s\n' "$WEEK"        # never rendered; here so you can grep
  printf 'published: %s\n' "$PUBLISHED"
  if [ -n "$TAGS" ]; then
    printf 'tags:\n'
    for t in $TAGS; do
      t="$(printf '%s' "$t" | tr -d '"'"'"'[],')"
      [ -n "$t" ] && printf '  - %s\n' "$t"
    done
  fi
  # Never rendered and never fed to the graph, like week:. Accumulating them
  # now so a fixed vocabulary can be chosen later from what actually recurs:
  #   grep -h -A20 '^domains:' content/*.md | grep '^  - ' | sort | uniq -c
  if [ -n "$DOMAINS" ]; then
    printf 'domains:\n'
    for d in $DOMAINS; do
      d="$(printf '%s' "$d" | tr -d '"'"'"'[],')"
      [ -n "$d" ] && printf '  - %s\n' "$d"
    done
  fi
  printf 'draft: false\n'
  printf -- '---\n\n'
  # Styled by p.fragment-meta in custom.scss. Held here rather than in a
  # Quartz component so the wording stays in this script.
  printf '<p class="fragment-meta">published %s</p>\n\n' "$PUBLISHED"
  printf '![[%s]]\n' "$IMG_NAME"
} > "$MD_PATH"

printf '\n\033[2m--- %s ---\033[0m\n' "$FRAGMENT_SUBDIR/${HEX}.md" >&2
cat "$MD_PATH" >&2
printf '\033[2m---\033[0m\n\n' >&2

# Outside content/, so Quartz never sees it: not published, not in RSS, not in
# og:description. Present in git for embeddings and re-tagging. A missing
# transcript is recoverable later; a failed publish is friction, so an empty
# one only warns.
if [ -n "$TRANSCRIPT" ]; then
  mkdir -p "$REPO/transcripts"
  printf '%s\n' "$TRANSCRIPT" > "$REPO/transcripts/${HEX}.txt"
  info "transcript: $(printf '%s' "$TRANSCRIPT" | wc -w | tr -d ' ') words -> transcripts/${HEX}.txt"
elif [ "$NOTAGS" -eq 0 ] && [ "$MANUAL" -eq 0 ]; then
  info "no transcript returned — publishing anyway, but the vision step may have failed."
fi

# ---------------------------------------------------------------- commit

if [ "$DRYRUN" -eq 1 ]; then
  ok "dry run — files written, nothing committed."
  info "  $MD_PATH"
  info "  $DEST/$IMG_NAME"
  exit 0
fi

cd "$REPO"
git add "$FRAGMENT_SUBDIR"
# Only if it exists: under set -e a missing pathspec would abort the publish
# after the fragment is written (first --manual / --no-tags run, or a model
# that returned no transcript).
if [ -d transcripts ]; then git add transcripts; fi
if git diff --cached --quiet; then
  info "nothing to commit."
  exit 0
fi
git commit -q -m "keep: $WEEK"
git push -q

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
ok "pushed to $BRANCH — the site rebuilds in a minute or two."
