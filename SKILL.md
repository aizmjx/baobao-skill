---
name: baowen-feed
description: 拉取 baowen 爆文系统的文章列表。默认走「全量爆文最新」模式（不限赛道，按发布时间倒序）——当用户问「今日爆文 / 今天有什么爆文 / 拿一下爆文」等时触发。当用户明确说「我的订阅 / 我订阅了什么 / 按标签过滤」时加 `--scope mine` 走订阅过滤；当用户说「昨天的爆文」时加 `--since yesterday`；当用户说「按热度 / TOP / 最热」时加 `--sort heat`。since 默认根据 scope 自动选（scope=all → today；scope=mine → 48h，订阅集合稀疏所以放宽窗口）。可选参数：since（today = Asia/Shanghai 今天 00:00 起 / yesterday = 昨天 00:00 起 / 24h = 滚动 24 小时 / 48h / 7d / 30d / all），category（限定单赛道，wx 拼音码如 keji / yuer / chuangye），sort（默认 published 按发布时间倒序，可改 heat 按热度），limit（默认 20，最大 50），scope（默认 all，可改 mine 走订阅过滤）。
---

调 baowen API 拿爆文列表，markdown 输出给 AI 阅读 / 总结 / 二次加工。

## 用法

```bash
# 默认：全量爆文 TOP（不限赛道）
bash ~/.claude/skills/baowen-feed/fetch.sh [--since 24h] [--category keji] [--sort heat] [--limit 20]

# 只看我自己订阅过的赛道（用 baowen 网页订阅设置 + 标签过滤）
bash ~/.claude/skills/baowen-feed/fetch.sh --scope mine [其他参数]
```

## 环境变量

- `BAOWEN_API_KEY`（必填）— baowen `/settings` 页一键生成的 token，格式 `bw_<64hex>`
- `BAOWEN_BASE_URL`（可选）— 默认 `https://fd.aiawaken.top`

## 何时用哪种 scope

| 用户问 | scope | 理由 |
|---|---|---|
| "今日爆文" / "今天有什么爆文" / "拿一下爆文" / "热门文章" | `all`（默认）| 用户想看全站 TOP，不只是自己订阅的 |
| "我的订阅" / "我订阅了什么" / "我关注的话题今天有啥" | `mine` | 明确要订阅过滤 |

## 何时用哪种 since

since 默认根据 scope 自动选：
- `scope=all` → 默认 `today`（今天 00:00 起）
- `scope=mine` → 默认 `48h`（订阅集合稀疏，宽窗口提高命中率）

用户显式说时间时手动指定：

| 用户问 | since | 理由 |
|---|---|---|
| "今日爆文" / "今天有什么" | `today` | Asia/Shanghai 今天 00:00 起 |
| "昨天的爆文" / "昨天爆文" | `yesterday` | 昨天 00:00 起到现在（含今天）|
| "过去 24 小时" / "近一天" | `24h` | 滚动窗口 |
| "过去 48 小时" / "近两天" | `48h` | 滚动窗口 |
| "近 7 天" / "本周" | `7d` | 滚动窗口 |

## 何时用哪种 sort

| 用户问 | sort | 理由 |
|---|---|---|
| "今日爆文" / 默认 / "最新的" / "按时间" | `published`（默认）| 按发布时间倒序，最新的在前 |
| "TOP / 最热 / 按热度" | `heat` | 按阅读量降序 |

## 输出格式

markdown bullet list，每条：

```
1. **标题** · 来源 · 公众号名 · 热度 · 分类
   - tags: ...
   - https://原文链接
   - 发布时间
```

## 不要做

不需要再调其他 API。这个 skill 只读 `/api/me/feed`，订阅维护和分类管理在 baowen 网页端。
