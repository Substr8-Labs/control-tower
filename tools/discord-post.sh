#!/bin/bash
# Discord Post Helper for Control Tower
# Post to Discord channels from anywhere (scripts, cron, webhooks)
#
# Usage: ./discord-post.sh <channel_name|channel_id> "message"
#
# Setup:
#   1. Replace BOT_TOKEN with your Discord bot token
#   2. Update CHANNELS map with your server's channel IDs

# ============================================
# CONFIGURATION - Update these for your server
# ============================================

BOT_TOKEN="YOUR_BOT_TOKEN_HERE"

# Map channel names to IDs (get IDs from Discord Developer Mode)
declare -A CHANNELS=(
  ["strategy"]=""       # #strategy channel ID
  ["engineering"]=""    # #engineering channel ID
  ["product"]=""        # #product channel ID
  ["marketing"]=""      # #marketing channel ID
  ["ops"]=""            # #ops channel ID
)

# ============================================
# SCRIPT - No changes needed below
# ============================================

CHANNEL_INPUT="$1"
MESSAGE="$2"

# Resolve channel name to ID if needed
if [[ -v CHANNELS[$CHANNEL_INPUT] && -n "${CHANNELS[$CHANNEL_INPUT]}" ]]; then
  CHANNEL_ID="${CHANNELS[$CHANNEL_INPUT]}"
else
  CHANNEL_ID="$CHANNEL_INPUT"
fi

# Validate inputs
if [[ -z "$CHANNEL_ID" || -z "$MESSAGE" ]]; then
  echo "Usage: $0 <channel_name|channel_id> \"message\""
  echo ""
  echo "Configured channels:"
  for name in "${!CHANNELS[@]}"; do
    if [[ -n "${CHANNELS[$name]}" ]]; then
      echo "  $name -> ${CHANNELS[$name]}"
    else
      echo "  $name -> (not configured)"
    fi
  done
  exit 1
fi

if [[ "$BOT_TOKEN" == "YOUR_BOT_TOKEN_HERE" ]]; then
  echo "Error: Please configure your BOT_TOKEN in this script"
  exit 1
fi

# Post to Discord
RESPONSE=$(curl -s -X POST "https://discord.com/api/v10/channels/${CHANNEL_ID}/messages" \
  -H "Authorization: Bot ${BOT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"content\": $(echo "$MESSAGE" | jq -Rs .)}")

# Check result
if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
  MSG_ID=$(echo "$RESPONSE" | jq -r '.id')
  echo "✓ Posted to #${CHANNEL_INPUT} (message ID: $MSG_ID)"
else
  ERROR=$(echo "$RESPONSE" | jq -r '.message // "Unknown error"')
  echo "✗ Failed: $ERROR"
  exit 1
fi
