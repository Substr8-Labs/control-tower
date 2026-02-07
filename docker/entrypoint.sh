#!/bin/bash
set -e

echo "🗼 Control Tower - Starting up..."

# Validate required environment variables
required_vars=(
    "ANTHROPIC_API_KEY"
    "DISCORD_BOT_TOKEN"
    "DISCORD_GUILD_ID"
    "ENGINEERING_CHANNEL_ID"
    "PRODUCT_CHANNEL_ID"
    "MARKETING_CHANNEL_ID"
    "FINANCE_CHANNEL_ID"
)

missing=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing+=("$var")
    fi
done

if [ ${#missing[@]} -ne 0 ]; then
    echo "❌ Missing required environment variables:"
    for var in "${missing[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "See .env.example for the complete list."
    exit 1
fi

echo "✓ Environment validated"

# Load persona prompts
CTO_PROMPT=$(cat /home/tower/.openclaw/personas/cto.md)
CPO_PROMPT=$(cat /home/tower/.openclaw/personas/cpo.md)
CMO_PROMPT=$(cat /home/tower/.openclaw/personas/cmo.md)
CFO_PROMPT=$(cat /home/tower/.openclaw/personas/cfo.md)

# Replace company name placeholder if set
COMPANY_NAME="${COMPANY_NAME:-Your Company}"
CTO_PROMPT="${CTO_PROMPT//\{\{COMPANY_NAME\}\}/$COMPANY_NAME}"
CPO_PROMPT="${CPO_PROMPT//\{\{COMPANY_NAME\}\}/$COMPANY_NAME}"
CMO_PROMPT="${CMO_PROMPT//\{\{COMPANY_NAME\}\}/$COMPANY_NAME}"
CFO_PROMPT="${CFO_PROMPT//\{\{COMPANY_NAME\}\}/$COMPANY_NAME}"

# Escape prompts for JSON
escape_json() {
    printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

CTO_JSON=$(escape_json "$CTO_PROMPT")
CPO_JSON=$(escape_json "$CPO_PROMPT")
CMO_JSON=$(escape_json "$CMO_PROMPT")
CFO_JSON=$(escape_json "$CFO_PROMPT")

# Generate config
cat > /home/tower/.openclaw/openclaw.json << EOF
{
  "\$schema": "https://openclaw.ai/schemas/config.json",
  "meta": {
    "name": "Control Tower",
    "version": "1.0.0"
  },
  "auth": {
    "profiles": {
      "anthropic:main": {
        "provider": "anthropic",
        "mode": "token",
        "token": "${ANTHROPIC_API_KEY}"
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "./workspace",
      "model": "${MODEL:-anthropic/claude-sonnet-4-20250514}",
      "compaction": {
        "mode": "safeguard"
      }
    }
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "${DISCORD_BOT_TOKEN}",
      "groupPolicy": "open",
      "guilds": {
        "${DISCORD_GUILD_ID}": {
          "requireMention": false,
          "channels": {
            "${ENGINEERING_CHANNEL_ID}": {
              "enabled": true,
              "systemPrompt": ${CTO_JSON}
            },
            "${PRODUCT_CHANNEL_ID}": {
              "enabled": true,
              "systemPrompt": ${CPO_JSON}
            },
            "${MARKETING_CHANNEL_ID}": {
              "enabled": true,
              "systemPrompt": ${CMO_JSON}
            },
            "${FINANCE_CHANNEL_ID}": {
              "enabled": true,
              "systemPrompt": ${CFO_JSON}
            }
          }
        }
      }
    }
  },
  "guardrails": {
    "maxA2AHops": 5,
    "dailyTokenBudget": ${DAILY_TOKEN_BUDGET:-100000},
    "alertAt": 0.8,
    "sessionRateLimit": 20
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "0.0.0.0"
  }
}
EOF

echo "✓ Config generated"

# Start gateway
echo "🚀 Launching Control Tower..."
exec openclaw gateway start --foreground
