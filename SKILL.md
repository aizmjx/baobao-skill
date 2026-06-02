---
name: baowen-feed
description: 拉取我在 baowen 爆文系统的订阅文章列表。当用户问「我的订阅 / 今日爆文 / 今天有什么爆文 / 拿一下爆文 / 我订阅了什么」等时触发。可选参数：since（默认 24h，可 7d / 30d / all），category（限定单赛道，wx 拼音码如 keji / yuer / chuangye），sort（默认 heat 按热度，可改 published 按发布时间），limit（默认 20，最大 50）。
---

调 baowen API 拿当前用户的订阅文章列表，markdown 输出给 AI 阅读 / 总结 / 二次加工。

## 用法

```bash
bash ~/.claude/skills/baowen-feed/fetch.sh [--since 24h] [--category keji] [--sort heat] [--limit 20]
```

## 环境变量

- `BAOWEN_API_KEY`（必填）— baowen 网页 `/settings` 页一键生成的 token，格式 `bw_<64hex>`
- `BAOWEN_BASE_URL`（可选）— 默认 `https://fd.aiawaken.top`

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
