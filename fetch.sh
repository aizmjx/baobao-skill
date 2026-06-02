#!/usr/bin/env bash
set -euo pipefail

SINCE="24h"; CATEGORY=""; SORT="heat"; LIMIT="20"
while [ $# -gt 0 ]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    --category) CATEGORY="$2"; shift 2 ;;
    --sort) SORT="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --help|-h) sed -n '/^## 用法/,/^## 环境变量/p' "$(dirname "$0")/SKILL.md" | grep -v '^## 环境变量'; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

API_KEY="${BAOWEN_API_KEY:?BAOWEN_API_KEY env var required (baowen /settings 页一键生成的 bw_xxx token)}"
BASE_URL="${BAOWEN_BASE_URL:-https://fd.aiawaken.top}"

QS="since=$SINCE&sort=$SORT&limit=$LIMIT"
[ -n "$CATEGORY" ] && QS="$QS&category=$CATEGORY"

response=$(curl -fsSL -H "Authorization: Bearer $API_KEY" "$BASE_URL/api/me/feed?$QS")

echo "$response" | jq -r '
  if (.data | length) == 0 then
    "（暂无文章）\n\nmeta: \(.meta)"
  else
    [
      "## baowen 订阅爆文 · since=\(.meta.since) · 共 \(.meta.total) 条\n"
    ] + [
      .data | to_entries[] | (
        "\(.key + 1). **\(.value.title)** · \(.value.source) · \(.value.author // "—") · 热度 \(.value.heat) · \(.value.category // "—")\n"
        + (if (.value.tags | length) > 0 then "   - tags: \(.value.tags | join(", "))\n" else "" end)
        + "   - \(.value.contentUrl)\n"
        + "   - \(.value.publishedAt)"
      )
    ] | join("\n\n")
  end
'
