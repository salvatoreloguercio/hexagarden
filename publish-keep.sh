#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <image-path> <week-label>"
  echo "  image-path   Path to the Google Keep screenshot"
  echo "  week-label   ISO week label, e.g. 2025-W32"
  exit 1
}

[[ $# -ne 2 ]] && usage

IMAGE_PATH="$1"
WEEK="$2"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "Error: ANTHROPIC_API_KEY is not set" >&2
  exit 1
fi

if [[ ! -f "$IMAGE_PATH" ]]; then
  echo "Error: image file not found: $IMAGE_PATH" >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
WEEKLY_DIR="$REPO_ROOT/content/weekly"
DEST_IMAGE="$WEEKLY_DIR/keep-${WEEK}.png"
DEST_MD="$WEEKLY_DIR/${WEEK}.md"

# --- infer Monday of the given ISO week ---
YEAR="${WEEK%-W*}"
WNUM="${WEEK#*-W}"
# Remove leading zero from week number for date arithmetic
WNUM_DEC=$((10#$WNUM))
# Jan 4 is always in week 1 per ISO 8601
JAN4="${YEAR}-01-04"
# Day-of-week of Jan 4 (1=Mon … 7=Sun), then Monday of week 1
JAN4_DOW=$(date -j -f "%Y-%m-%d" "$JAN4" "+%u" 2>/dev/null \
           || date -d "$JAN4" "+%u")
MON_W1=$(( $(date -j -f "%Y-%m-%d" "$JAN4" "+%s" 2>/dev/null \
             || date -d "$JAN4" "+%s") - (JAN4_DOW - 1) * 86400 ))
TARGET_TS=$(( MON_W1 + (WNUM_DEC - 1) * 7 * 86400 ))
INFERRED_DATE=$(date -r "$TARGET_TS" "+%Y-%m-%d" 2>/dev/null \
                || date -d "@$TARGET_TS" "+%Y-%m-%d")

echo "Week: $WEEK  →  date: $INFERRED_DATE"

# --- copy image ---
cp "$IMAGE_PATH" "$DEST_IMAGE"
echo "Copied image to $DEST_IMAGE"

# --- encode image as base64 ---
B64=$(base64 < "$DEST_IMAGE" | tr -d '\n')

# --- call Anthropic API ---
echo "Calling Claude to extract tags…"
SYSTEM_PROMPT='You are tagging fragments for a knowledge graph.
Given this screenshot of Google Keep notes (mostly text),
read the content carefully and extract 5-10 specific topic tags.
Rules:
- Read all visible text, including small notes
- Specific over general (sufi-poetry not spirituality, protein-folding not biology)
- Single concepts, hyphenated if compound
- No meta-tags (no "notes", "weekly", "ideas")
- Across all domains — science, arts, philosophy, martial arts, markets, anything present
- Return only a JSON array of strings, nothing else'

PAYLOAD=$(jq -n \
  --arg system "$SYSTEM_PROMPT" \
  --arg b64 "$B64" \
  '{
    model: "claude-sonnet-4-20250514",
    max_tokens: 256,
    system: $system,
    messages: [{
      role: "user",
      content: [{
        type: "image",
        source: {
          type: "base64",
          media_type: "image/png",
          data: $b64
        }
      }, {
        type: "text",
        text: "Extract tags from this Keep screenshot."
      }]
    }]
  }')

RESPONSE=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "$PAYLOAD")

RAW_TAGS=$(echo "$RESPONSE" | jq -r '.content[0].text // empty')

if [[ -z "$RAW_TAGS" ]]; then
  echo "Error: unexpected API response:" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

echo ""
echo "Proposed tags (edit then press Enter to confirm, Ctrl-C to abort):"
echo "$RAW_TAGS" | jq -r '.[]' | sed 's/^/  - /'
echo ""
echo "Current JSON: $RAW_TAGS"
echo ""
read -r -p "Edit tags JSON (leave blank to accept as-is): " EDITED
if [[ -n "$EDITED" ]]; then
  FINAL_TAGS="$EDITED"
else
  FINAL_TAGS="$RAW_TAGS"
fi

# Validate it's a JSON array
if ! echo "$FINAL_TAGS" | jq -e 'if type == "array" then . else error end' > /dev/null 2>&1; then
  echo "Error: tags must be a JSON array" >&2
  exit 1
fi

# --- build YAML tag block ---
TAG_YAML=$(echo "$FINAL_TAGS" | jq -r '.[] | "  - " + .')

# --- write markdown file ---
cat > "$DEST_MD" <<MDEOF
---
title: "Keep · ${WEEK}"
date: ${INFERRED_DATE}
tags:
${TAG_YAML}
draft: false
---

![[keep-${WEEK}.png]]
MDEOF

echo ""
echo "Written: $DEST_MD"
echo "---"
cat "$DEST_MD"
echo "---"
echo ""

# --- commit and push ---
if [[ "${DRY_RUN:-}" == "1" ]]; then
  echo "[DRY RUN] Would run: git add . && git commit -m 'keep: ${WEEK}' && git push"
else
  cd "$REPO_ROOT"
  git add .
  git commit -m "keep: ${WEEK}"
  git push
  echo "Pushed."
fi
