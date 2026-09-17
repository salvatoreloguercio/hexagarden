#!/usr/bin/env bash
#
# publish-keep.sh — publish one Keep screenshot to the weekly stream
#
#   ./publish-keep.sh <image> <week-label> [options]
#   ./publish-keep.sh ~/Downloads/shot.png 2025-W32
#
# Options
#   --manual            skip LLM tagging, type tags by hand
#   --dry-run           write the files, show them, don't commit or push
#   --date YYYY-MM-DD   override the inferred date
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

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

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
[ -n "$WEEK" ] || die "no week label given (e.g. 2025-W32). see --help"
[ "$LABELONLY" -eq 1 ] || [ -f "$IMG" ] || die "image not found: $IMG"

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

# ISO week -> the Monday of that week. Python's fromisocalendar is exact and
# handles the 53-week years; BSD and GNU `date` disagree about %V/%U parsing,
# so we do not go near them.
iso_week_monday() {
  local label="$1" y w
  y="${label%-W*}"; w="${label#*W}"
  python3 - "$y" "$w" <<'PY'
import datetime, sys
y, w = int(sys.argv[1]), int(sys.argv[2])
try:
    print(datetime.date.fromisocalendar(y, w, 1).isoformat())
except ValueError as e:
    sys.exit(f"bad ISO week: {e}")
PY
}

if [ -n "$DATE_OVERRIDE" ]; then
  case "$DATE_OVERRIDE" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) DATE="$DATE_OVERRIDE" ;;
    *) die "--date must be YYYY-MM-DD (got: $DATE_OVERRIDE)" ;;
  esac
elif command -v python3 >/dev/null 2>&1; then
  DATE="$(iso_week_monday "$WEEK")" || die "could not resolve $WEEK to a date"
else
  die "python3 not found, so the week label can't be converted to a date.
       pass it explicitly:  --date YYYY-MM-DD"
fi

# --label reports the hex and stops. Placed after the date resolution so a
# week that doesn't exist is rejected rather than cheerfully hashed.
if [ "$LABELONLY" -eq 1 ]; then
  printf '%s\n' "$HEX"
  exit 0
fi

# ---------------------------------------------------------------- tags

TAGS=""

extract_tags() {
  command -v claude >/dev/null 2>&1 || die "claude not found on PATH. use --manual"
  command -v jq     >/dev/null 2>&1 || die "jq not found on PATH. brew install jq"

  local abs schema out
  abs="$(cd "$(dirname "$IMG")" && pwd)/$(basename "$IMG")"
  schema='{"type":"object","properties":{"tags":{"type":"array","items":{"type":"string"}}},"required":["tags"]}'

  info "reading $(basename "$abs") with claude ($MODEL)…"

  # ANTHROPIC_API_KEY is cleared for this call only: with it set, headless
  # runs can bill the API account instead of the subscription.
  if ! out="$(
    env -u ANTHROPIC_API_KEY claude -p "$SKILL $abs" \
      --model "$MODEL" \
      --allowedTools "Read" \
      --permission-mode auto \
      --permission-prompts none \
      --output-format json \
      --json-schema "$schema" 2>/dev/null
  )"; then
    info "claude call failed."
    return 1
  fi

  TAGS="$(printf '%s' "$out" | jq -r '.structured_output.tags[]?' 2>/dev/null | tr '\n' ' ')"
  TAGS="${TAGS% }"

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

# ---------------------------------------------------------------- write

mkdir -p "$DEST"

if [ -e "$MD_PATH" ]; then
  printf '%s already exists (%s). overwrite? [y/N] ' "${HEX}.md" "$WEEK" >&2
  IFS= read -r ans || ans=""
  case "$ans" in [yY]*) : ;; *) die "aborted." ;; esac
fi

cp "$IMG" "$DEST/$IMG_NAME"

PUBLISHED="$(date +%Y-%m-%d)"

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

# ---------------------------------------------------------------- commit

if [ "$DRYRUN" -eq 1 ]; then
  ok "dry run — files written, nothing committed."
  info "  $MD_PATH"
  info "  $DEST/$IMG_NAME"
  exit 0
fi

cd "$REPO"
git add "$FRAGMENT_SUBDIR"
if git diff --cached --quiet; then
  info "nothing to commit."
  exit 0
fi
git commit -q -m "keep: $WEEK"
git push -q

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
ok "pushed to $BRANCH — the site rebuilds in a minute or two."
