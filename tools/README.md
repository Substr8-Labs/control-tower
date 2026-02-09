# Control Tower Tools

Utility scripts for your AI Executive Team.

## discord-post.sh

Post to Discord channels from anywhere (scripts, cron, other tools).

```bash
# By channel name
./discord-post.sh marketing "New feature launched!"

# By channel ID
./discord-post.sh 1469277924229120000 "Technical update"
```

### Setup

1. Edit the script and add your bot token
2. Update the channel mappings for your server

### Channel Shortcuts

Edit the `CHANNELS` array in the script to match your server:

```bash
declare -A CHANNELS=(
  ["engineering"]="YOUR_CHANNEL_ID"
  ["product"]="YOUR_CHANNEL_ID"
  ["marketing"]="YOUR_CHANNEL_ID"
  # ... add your channels
)
```

## Future Tools

- `notion-sync.sh` — Sync decisions to Notion
- `standup.sh` — Post daily standup summaries
- `metrics.sh` — Pull and post key metrics
- `alert.sh` — Send alerts across all channels
