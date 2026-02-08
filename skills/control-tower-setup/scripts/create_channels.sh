#!/bin/bash
#
# Create Discord channels for Control Tower personas
#
# Usage: ./create_channels.sh <guild_id> <bot_token> [personas]
# 
# personas: comma-separated list (default: engineering,product,marketing)
#
# Example:
#   ./create_channels.sh 123456789 BOT_TOKEN_HERE
#   ./create_channels.sh 123456789 BOT_TOKEN_HERE engineering,product,marketing,finance
#

set -e

GUILD_ID="$1"
BOT_TOKEN="$2"
PERSONAS="${3:-engineering,product,marketing}"

if [ -z "$GUILD_ID" ] || [ -z "$BOT_TOKEN" ]; then
    echo "Usage: $0 <guild_id> <bot_token> [personas]"
    echo ""
    echo "personas: comma-separated (default: engineering,product,marketing)"
    echo "options: engineering, product, marketing, finance, research, ops, general"
    exit 1
fi

# Channel topics
declare -A TOPICS
TOPICS["general"]="Control Tower coordination"
TOPICS["engineering"]="Technical discussions with Ada (CTO)"
TOPICS["product"]="Product decisions with Grace (CPO)"
TOPICS["marketing"]="Growth and messaging with Tony (CMO)"
TOPICS["finance"]="Unit economics with Val (CFO)"
TOPICS["research"]="Exploration with Bucky (Chief Scientist)"
TOPICS["ops"]="Infrastructure with Sentinel (SRE)"

# Parse personas
IFS=',' read -ra CHANNEL_LIST <<< "$PERSONAS"

echo "Creating channels in guild $GUILD_ID..."
echo ""

CREATED_CHANNELS="{}"

for channel in "${CHANNEL_LIST[@]}"; do
    channel=$(echo "$channel" | xargs)  # trim whitespace
    topic="${TOPICS[$channel]:-Control Tower channel}"
    
    echo "Creating #$channel..."
    
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: Bot $BOT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$channel\", \"type\": 0, \"topic\": \"$topic\"}" \
        "https://discord.com/api/v10/guilds/$GUILD_ID/channels")
    
    CHANNEL_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    ERROR=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$CHANNEL_ID" ] && [ "$CHANNEL_ID" != "null" ]; then
        echo "  ✓ Created #$channel (ID: $CHANNEL_ID)"
        CREATED_CHANNELS="$CREATED_CHANNELS\"$channel\": \"$CHANNEL_ID\","
    else
        echo "  ✗ Failed to create #$channel: $ERROR"
        
        # Try to find existing channel
        echo "  Looking for existing channel..."
        EXISTING=$(curl -s -H "Authorization: Bot $BOT_TOKEN" \
            "https://discord.com/api/v10/guilds/$GUILD_ID/channels" | \
            grep -o "{[^}]*\"name\":\"$channel\"[^}]*}" | \
            grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ -n "$EXISTING" ]; then
            echo "  ✓ Found existing #$channel (ID: $EXISTING)"
            CREATED_CHANNELS="$CREATED_CHANNELS\"$channel\": \"$EXISTING\","
        fi
    fi
done

echo ""
echo "Channel IDs (for config):"
echo "{"
echo "$CREATED_CHANNELS" | sed 's/,$//'
echo "}"
