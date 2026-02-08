#!/bin/bash
# Create Control Tower channels in a Discord server
#
# Usage: ./create-channels.sh <guild-id> <bot-token>
#
# Creates: #strategy, #engineering, #product, #marketing, #ops
# Outputs: JSON with channel IDs

set -e

GUILD_ID="$1"
BOT_TOKEN="$2"

if [[ -z "$GUILD_ID" || -z "$BOT_TOKEN" ]]; then
  echo "Usage: $0 <guild-id> <bot-token>" >&2
  exit 1
fi

API_BASE="https://discord.com/api/v10"

# Channel definitions: name -> topic
declare -A CHANNELS=(
  ["strategy"]="Big picture priorities and strategic decisions"
  ["engineering"]="Architecture, code reviews, and technical decisions"
  ["product"]="Feature prioritization, roadmap, and user focus"
  ["marketing"]="Positioning, messaging, and growth strategies"
  ["ops"]="Deployments, monitoring, and incident response"
)

# Order matters for category position
CHANNEL_ORDER=("strategy" "engineering" "product" "marketing" "ops")

echo "{"

first=true
for name in "${CHANNEL_ORDER[@]}"; do
  topic="${CHANNELS[$name]}"
  
  response=$(curl -s -X POST "${API_BASE}/guilds/${GUILD_ID}/channels" \
    -H "Authorization: Bot ${BOT_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{\"name\": \"${name}\", \"type\": 0, \"topic\": \"${topic}\"}")
  
  channel_id=$(echo "$response" | jq -r '.id // empty')
  
  if [[ -z "$channel_id" ]]; then
    echo "Error creating #${name}: $response" >&2
    exit 1
  fi
  
  if [[ "$first" == "true" ]]; then
    first=false
  else
    echo ","
  fi
  
  echo "  \"${name}\": \"${channel_id}\""
done

echo "}"
