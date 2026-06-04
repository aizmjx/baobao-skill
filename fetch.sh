#!/usr/bin/env bash
set -euo pipefail

# 默认 scope=all（看全量爆文 TOP）；--scope mine 走个人订阅过滤
# since 默认根据 scope 自动选：scope=all → today / scope=mine → 48h（订阅集合稀疏，要宽窗口）
# 默认 sort=published（按发布时间倒序，最新的在前）；--sort heat 按热度
SCOPE="all"; SINCE=""; CATEGORY=""; SORT="published"; LIMIT="20"
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

# scope-aware default since（用户没显式 --since 时）
if [ -z "$SINCE" ]; then
  if [ "$SCOPE" = "mine" ]; then SINCE="48h"; else SINCE="today"; fi
fi

QS="scope=$SCOPE&since=$SINCE&sort=$SORT&limit=$LIMIT"
[ -n "$CATEGORY" ] && QS="$QS&category=$CATEGORY"

response=$(curl -fsSL -H "Authorization: Bearer $API_KEY" "$BASE_URL/api/me/feed?$QS")

echo "$response" | jq -r '
  # markdown 表格 cell 转义：| 替换成 \|，去掉换行
  def esc_cell:
    if . == null then "—"
    elseif type == "string" then
      gsub("\\|"; "\\\\|") | gsub("\n"; " ")
    else . end;

  if (.data | length) == 0 then
    if (.meta.reason // "") == "no-subscriptions" then
      "（你还没有在 baowen 订阅任何赛道。去 https://fd.aiawaken.top/subscriptions 选几个再试，或者直接用全量模式：去掉 --scope mine 即可。）"
    else
      "（暂无文章）\n\nmeta: \(.meta)"
    end
  else
    [
      "## baowen \(if .meta.scope == "mine" then "订阅" else "全量" end)爆文 · since=\(.meta.since) · 共 \(.meta.total) 条",
      "",
      "| # | 标题 | 来源 | 公众号 | 热度 | 分类 | 标签 | 时间 |",
      "|---|------|------|--------|------|------|------|------|"
    ] + [
      .data | to_entries[] | (
        "| \(.key + 1)"
        + " | [\(.value.title | esc_cell)](\(.value.contentUrl))"
        + " | \(.value.source | esc_cell)"
        + " | \(.value.author | esc_cell)"
        + " | \(.value.heat)"
        + " | \(.value.category | esc_cell)"
        + " | \(if (.value.tags | length) > 0 then (.value.tags | join(",") | esc_cell) else "—" end)"
        + " | \(.value.publishedAtCN // .value.publishedAt | esc_cell)"
        + " |"
      )
    ] | join("\n")
  end
'
