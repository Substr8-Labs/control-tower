#!/bin/bash
# Add guild configuration to OpenClaw with isolated sessions
#
# Usage: ./write-config.sh <guild-id> <company-slug> <channels-json> [config-path]
#
# channels-json format: {"strategy":"123","engineering":"456",...}

set -e

GUILD_ID="$1"
COMPANY_SLUG="$2"
CHANNELS_JSON="$3"
CONFIG_PATH="${4:-$HOME/.openclaw/openclaw.json}"

if [[ -z "$GUILD_ID" || -z "$COMPANY_SLUG" || -z "$CHANNELS_JSON" ]]; then
  echo "Usage: $0 <guild-id> <company-slug> <channels-json> [config-path]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates/prompts"

# Read system prompts from templates
read_prompt() {
  local name="$1"
  local company="$2"
  local template="${TEMPLATES_DIR}/${name}.txt"
  
  if [[ -f "$template" ]]; then
    # Replace {{company}} placeholder
    sed "s/{{company}}/${company}/g" "$template"
  else
    echo "System prompt for ${name}"
  fi
}

# Build channel configs
build_channel_config() {
  local channel_id="$1"
  local persona="$2"
  local prompt
  prompt=$(read_prompt "$persona" "$COMPANY_SLUG" | jq -Rs .)
  
  cat <<EOF
{
  "requireMention": false,
  "enabled": true,
  "systemPrompt": ${prompt}
}
EOF
}

# Map channel names to their IDs
STRATEGY_ID=$(echo "$CHANNELS_JSON" | jq -r '.strategy')
ENGINEERING_ID=$(echo "$CHANNELS_JSON" | jq -r '.engineering')
PRODUCT_ID=$(echo "$CHANNELS_JSON" | jq -r '.product')
MARKETING_ID=$(echo "$CHANNELS_JSON" | jq -r '.marketing')
OPS_ID=$(echo "$CHANNELS_JSON" | jq -r '.ops')

# Build the guild config
GUILD_CONFIG=$(cat <<EOF
{
  "requireMention": false,
  "isolated": true,
  "sessionLabel": "customer:${COMPANY_SLUG}",
  "channels": {
    "${STRATEGY_ID}": $(build_channel_config "$STRATEGY_ID" "strategy"),
    "${ENGINEERING_ID}": $(build_channel_config "$ENGINEERING_ID" "engineering"),
    "${PRODUCT_ID}": $(build_channel_config "$PRODUCT_ID" "product"),
    "${MARKETING_ID}": $(build_channel_config "$MARKETING_ID" "marketing"),
    "${OPS_ID}": $(build_channel_config "$OPS_ID" "ops")
  }
}
EOF
)

# Add to config using jq
jq --arg gid "$GUILD_ID" --argjson cfg "$GUILD_CONFIG" \
  '.channels.discord.guilds[$gid] = $cfg' \
  "$CONFIG_PATH" > "${CONFIG_PATH}.tmp" && mv "${CONFIG_PATH}.tmp" "$CONFIG_PATH"

echo "Added guild ${GUILD_ID} (${COMPANY_SLUG}) to config"

# Signal hot-reload
GATEWAY_PID=$(pgrep -f "openclaw-gateway" | head -1)
if [[ -n "$GATEWAY_PID" ]]; then
  kill -SIGUSR1 "$GATEWAY_PID"
  echo "Sent hot-reload signal to gateway (PID ${GATEWAY_PID})"
fi
