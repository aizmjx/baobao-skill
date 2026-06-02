# baobao-skill

Claude Code skill：拉取 **baowen 爆文系统** (fd.aiawaken.top) 的订阅文章列表，在 Claude 对话里直接看 / 总结 / 二次加工。

跟 Claude 说「我的订阅」「今日爆文」「今天有什么爆文」等关键词即可触发。

## 安装

### 1. clone 到 user-level skill 目录

```bash
git clone git@github.com:aizmjx/baobao-skill.git ~/.claude/skills/baowen-feed
chmod +x ~/.claude/skills/baowen-feed/fetch.sh
```

### 2. 配 API Key

打开 https://fd.aiawaken.top/settings → 点「**生成 API Key**」→ 弹窗一次性显示 `bw_<64hex>` token → 复制。

把 token 写进 shell 启动文件（永久生效）：

```bash
echo 'export BAOWEN_API_KEY=bw_刚才复制的xxx' >> ~/.zshrc   # 或 ~/.bashrc
source ~/.zshrc
```

或者只本次 session 生效：

```bash
export BAOWEN_API_KEY=bw_刚才复制的xxx
```

### 3. 验证

```bash
bash ~/.claude/skills/baowen-feed/fetch.sh --since 24h --limit 5
```

如果看到 markdown 列表的 5 条爆文就 OK。

### 4. 触发

打开任意 Claude 对话，输入「**今日爆文**」「**我的订阅**」「**今天有什么爆文**」「**拿一下爆文**」等 —— Claude 会自动调 baowen-feed skill 把数据拉出来。

## 参数

`fetch.sh` 支持以下可选参数（不传走默认）：

| 参数 | 默认 | 说明 |
|---|---|---|
| `--since` | `24h` | 时间范围；可选 `24h` / `7d` / `30d` / `all` |
| `--category` | 不限 | 限定单赛道，传 wx 拼音码（如 `keji` / `yuer` / `chuangye` / `caijing`）|
| `--sort` | `heat` | 排序；可选 `heat`（按阅读量）/ `published`（按发布时间）|
| `--limit` | `20` | 返回条数；最大 50 |

例如：

```bash
# 7 天内 科技 赛道 TOP 10
bash ~/.claude/skills/baowen-feed/fetch.sh --since 7d --category keji --limit 10

# 24 小时按时间排序
bash ~/.claude/skills/baowen-feed/fetch.sh --sort published
```

## 输出格式

```
## baowen 订阅爆文 · since=24h · 共 5 条

1. **标题** · 来源 · 公众号名 · 热度 26.4w · 时政
   - tags: 社会热点, 民生
   - https://toutiao.com/group/xxx
   - 2026-05-29T10:23:00+08:00

2. ...
```

## 依赖

- `bash`
- `curl`
- `jq` (`brew install jq` 或 `apt install jq`)

## 撤销 / 重置 token

去 https://fd.aiawaken.top/settings：

- **Rotate**：生成新 token，旧 token 立即失效
- **Revoke**：清空 token，skill 调不通直到再次生成

## License

MIT
