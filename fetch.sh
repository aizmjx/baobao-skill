#!/usr/bin/env bash
set -euo pipefail

# 默认 scope=all（看全量爆文 TOP）；--scope mine 走个人订阅过滤
SCOPE="all"; SINCE="24h"; CATEGORY=""; SORT="heat"; LIMIT="20"
while [ $# -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2 ;;
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

QS="scope=$SCOPE&since=$SINCE&sort=$SORT&limit=$LIMIT"
[ -n "$CATEGORY" ] && QS="$QS&category=$CATEGORY"

response=$(curl -fsSL -H "Authorization: Bearer $API_KEY" "$BASE_URL/api/me/feed?$QS")

echo "$response" | jq -r '
  if (.data | length) == 0 then
    if (.meta.reason // "") == "no-subscriptions" then
      "（你还没有在 baowen 订阅任何赛道。去 https://fd.aiawaken.top/subscriptions 选几个再试，或者直接用全量模式：去掉 --scope mine 即可。）"
    else
      "（暂无文章）\n\nmeta: \(.meta)"
    end
  else
    [
      "## baowen \(if .meta.scope == "mine" then "订阅" else "全量" end)爆文 · since=\(.meta.since) · 共 \(.meta.total) 条\n"
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
