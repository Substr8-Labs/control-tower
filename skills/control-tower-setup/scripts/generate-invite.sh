#!/bin/bash
# Generate Discord OAuth invite URL for Control Tower bot
#
# Usage: ./generate-invite.sh [bot-client-id]
#
# Permissions breakdown:
#   MANAGE_CHANNELS    = 16
#   SEND_MESSAGES      = 2048
#   READ_MESSAGE_HISTORY = 65536
#   MANAGE_MESSAGES    = 8192
#   Total              = 75776

BOT_CLIENT_ID="${1:-1469265115248463995}"  # Default: Substr8 AI
PERMISSIONS="75776"
SCOPE="bot"

INVITE_URL="https://discord.com/api/oauth2/authorize?client_id=${BOT_CLIENT_ID}&permissions=${PERMISSIONS}&scope=${SCOPE}"

echo "$INVITE_URL"
