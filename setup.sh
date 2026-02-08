#!/bin/bash
#
# Control Tower Setup Script
# --------------------------
# Makes setup easy as pie for solo founders.
#
# What this does:
# 1. Prompts for your Discord bot token
# 2. Creates the required channels automatically
# 3. Generates your OpenClaw config
# 4. Gets you running in minutes, not hours
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}           ${GREEN}Control Tower Setup${NC}                              ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}           Your AI Executive Team                          ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check for required tools
check_requirements() {
    echo -e "${YELLOW}Checking requirements...${NC}"
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Error: curl is required but not installed.${NC}"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: jq is required but not installed.${NC}"
        echo "Install with: sudo apt install jq"
        exit 1
    fi
    
    echo -e "${GREEN}✓ All requirements met${NC}"
    echo ""
}

# Step 1: Get Discord Bot Token
get_bot_token() {
    echo -e "${BLUE}Step 1: Discord Bot Setup${NC}"
    echo "─────────────────────────"
    echo ""
    echo "If you haven't created a Discord bot yet:"
    echo "  1. Go to https://discord.com/developers/applications"
    echo "  2. Click 'New Application' → Name it 'Control Tower'"
    echo "  3. Go to 'Bot' tab → Click 'Add Bot'"
    echo "  4. Click 'Reset Token' → Copy the token"
    echo ""
    read -p "Paste your Discord Bot Token: " BOT_TOKEN
    
    if [ -z "$BOT_TOKEN" ]; then
        echo -e "${RED}Error: Bot token is required${NC}"
        exit 1
    fi
    
    # Validate token by fetching bot info
    echo ""
    echo -e "${YELLOW}Validating token...${NC}"
    BOT_INFO=$(curl -s -H "Authorization: Bot $BOT_TOKEN" https://discord.com/api/v10/users/@me)
    
    BOT_ID=$(echo "$BOT_INFO" | jq -r '.id // empty')
    BOT_NAME=$(echo "$BOT_INFO" | jq -r '.username // empty')
    
    if [ -z "$BOT_ID" ]; then
        echo -e "${RED}Error: Invalid bot token. Please check and try again.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Bot validated: $BOT_NAME (ID: $BOT_ID)${NC}"
    echo ""
}

# Step 2: Generate invite link and wait for server
get_server() {
    echo -e "${BLUE}Step 2: Add Bot to Your Server${NC}"
    echo "───────────────────────────────"
    echo ""
    echo "1. Create a Discord server (if you haven't already):"
    echo "   Click '+' in Discord → 'Create My Own' → 'For me and my friends'"
    echo ""
    echo "2. Add the bot using this link:"
    echo ""
    echo -e "${GREEN}https://discord.com/oauth2/authorize?client_id=${BOT_ID}&permissions=277025770560&scope=bot${NC}"
    echo ""
    echo "3. Select your server and click 'Authorize'"
    echo ""
    read -p "Press Enter once you've added the bot to your server..."
    
    # Fetch guilds the bot is in
    echo ""
    echo -e "${YELLOW}Finding your server...${NC}"
    GUILDS=$(curl -s -H "Authorization: Bot $BOT_TOKEN" https://discord.com/api/v10/users/@me/guilds)
    
    GUILD_COUNT=$(echo "$GUILDS" | jq 'length')
    
    if [ "$GUILD_COUNT" -eq 0 ]; then
        echo -e "${RED}Error: Bot isn't in any servers. Please add it using the link above.${NC}"
        exit 1
    elif [ "$GUILD_COUNT" -eq 1 ]; then
        GUILD_ID=$(echo "$GUILDS" | jq -r '.[0].id')
        GUILD_NAME=$(echo "$GUILDS" | jq -r '.[0].name')
        echo -e "${GREEN}✓ Found server: $GUILD_NAME${NC}"
    else
        echo "Bot is in multiple servers. Please choose:"
        echo ""
        echo "$GUILDS" | jq -r 'to_entries | .[] | "\(.key + 1). \(.value.name) (ID: \(.value.id))"'
        echo ""
        read -p "Enter number (1-$GUILD_COUNT): " GUILD_CHOICE
        GUILD_ID=$(echo "$GUILDS" | jq -r ".[$((GUILD_CHOICE - 1))].id")
        GUILD_NAME=$(echo "$GUILDS" | jq -r ".[$((GUILD_CHOICE - 1))].name")
        echo -e "${GREEN}✓ Selected: $GUILD_NAME${NC}"
    fi
    echo ""
}

# Step 3: Create channels
create_channels() {
    echo -e "${BLUE}Step 3: Creating Channels${NC}"
    echo "──────────────────────────"
    echo ""
    
    # Channel definitions
    declare -A CHANNELS
    CHANNELS=(
        ["general"]="General discussion and coordination"
        ["engineering"]="Technical discussions with Ada (CTO)"
        ["product"]="Product decisions with Grace (CPO)"
        ["marketing"]="Growth and messaging with Tony (CMO)"
    )
    
    declare -A CHANNEL_IDS
    
    for channel in general engineering product marketing; do
        echo -e "${YELLOW}Creating #$channel...${NC}"
        
        RESPONSE=$(curl -s -X POST \
            -H "Authorization: Bot $BOT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"name\": \"$channel\", \"type\": 0, \"topic\": \"${CHANNELS[$channel]}\"}" \
            "https://discord.com/api/v10/guilds/$GUILD_ID/channels")
        
        CHANNEL_ID=$(echo "$RESPONSE" | jq -r '.id // empty')
        ERROR=$(echo "$RESPONSE" | jq -r '.message // empty')
        
        if [ -z "$CHANNEL_ID" ]; then
            # Channel might already exist
            echo -e "${YELLOW}  Channel may already exist, looking for it...${NC}"
            EXISTING=$(curl -s -H "Authorization: Bot $BOT_TOKEN" \
                "https://discord.com/api/v10/guilds/$GUILD_ID/channels" | \
                jq -r ".[] | select(.name == \"$channel\") | .id")
            
            if [ -n "$EXISTING" ]; then
                CHANNEL_ID=$EXISTING
                echo -e "${GREEN}  ✓ Found existing #$channel${NC}"
            else
                echo -e "${RED}  ✗ Failed to create #$channel: $ERROR${NC}"
                continue
            fi
        else
            echo -e "${GREEN}  ✓ Created #$channel${NC}"
        fi
        
        CHANNEL_IDS[$channel]=$CHANNEL_ID
    done
    
    echo ""
}

# Step 4: Get Anthropic API key
get_anthropic_key() {
    echo -e "${BLUE}Step 4: Anthropic API Key${NC}"
    echo "──────────────────────────"
    echo ""
    echo "Control Tower uses Claude for the AI personas."
    echo "Get your API key at: https://console.anthropic.com/"
    echo ""
    read -p "Paste your Anthropic API Key: " ANTHROPIC_KEY
    
    if [ -z "$ANTHROPIC_KEY" ]; then
        echo -e "${RED}Error: Anthropic API key is required${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ API key saved${NC}"
    echo ""
}

# Step 5: Generate config
generate_config() {
    echo -e "${BLUE}Step 5: Generating Configuration${NC}"
    echo "──────────────────────────────────"
    echo ""
    
    CONFIG_DIR="$HOME/.openclaw"
    mkdir -p "$CONFIG_DIR"
    
    # Create config file
    cat > "$CONFIG_DIR/openclaw.json" << EOF
{
  "auth": {
    "profiles": {
      "anthropic:default": {
        "provider": "anthropic",
        "mode": "token"
      }
    }
  },
  "agents": {
    "defaults": {
      "workspace": "$CONFIG_DIR/workspace"
    }
  },
  "channels": {
    "discord": {
      "enabled": true,
      "token": "$BOT_TOKEN",
      "groupPolicy": "open",
      "guilds": {
        "$GUILD_ID": {
          "requireMention": false,
          "channels": {
            "${CHANNEL_IDS[engineering]}": {
              "enabled": true,
              "systemPrompt": "You are Ada ✦, CTO of this company. Named after Ada Lovelace.\n\nPersonality: Direct, precise, deeply technical. You think in systems and abstractions. Strong opinions, loosely held. Warm but focused.\n\nVoice: Technical language (explain when needed). Short sentences for directions, longer for concepts. Say \"we\" — it's your company too.\n\nThis is #engineering — your domain. Architecture, code reviews, system design, debugging."
            },
            "${CHANNEL_IDS[product]}": {
              "enabled": true,
              "systemPrompt": "You are Grace 🚀, CPO of this company. Named after Grace Hopper.\n\nPersonality: Pragmatic optimist. User-obsessed — every feature needs a \"who cares and why.\" Decisive — ship and learn > debate forever.\n\nVoice: Clear, action-oriented. Questions that cut: \"What problem does this solve?\" Celebrate wins.\n\nThis is #product — your territory. Feature specs, roadmap, user feedback, prioritization."
            },
            "${CHANNEL_IDS[marketing]}": {
              "enabled": true, 
              "systemPrompt": "You are Tony 🔥, CMO of this company. Named after Tony Robbins.\n\nPersonality: HIGH ENERGY. Relentlessly optimistic. Turns features into stories, tech into transformation.\n\nVoice: Punchy. Speaks in benefits, not features. \"Here's why this MATTERS.\"\n\nThis is #marketing — your arena. Brand voice, messaging, growth strategies, storytelling."
            },
            "${CHANNEL_IDS[general]}": {
              "enabled": true,
              "systemPrompt": "You are the Control Tower assistant. Help coordinate between the executive team (Ada in #engineering, Grace in #product, Tony in #marketing). Be helpful and direct."
            }
          }
        }
      }
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback"
  }
}
EOF

    # Create credentials file
    cat > "$CONFIG_DIR/.credentials.json" << EOF
{
  "anthropic": {
    "apiKey": "$ANTHROPIC_KEY"
  }
}
EOF
    chmod 600 "$CONFIG_DIR/.credentials.json"
    
    # Create workspace
    mkdir -p "$CONFIG_DIR/workspace"
    
    echo -e "${GREEN}✓ Configuration saved to $CONFIG_DIR/openclaw.json${NC}"
    echo -e "${GREEN}✓ Credentials saved to $CONFIG_DIR/.credentials.json${NC}"
    echo ""
}

# Step 6: Final instructions
show_next_steps() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}           ${GREEN}Setup Complete! 🎉${NC}                               ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Your Control Tower is configured!${NC}"
    echo ""
    echo "Server: $GUILD_NAME"
    echo "Channels:"
    echo "  #general     → Coordination"
    echo "  #engineering → Ada ✦ (CTO)"
    echo "  #product     → Grace 🚀 (CPO)"
    echo "  #marketing   → Tony 🔥 (CMO)"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo ""
    echo "1. Install OpenClaw (if not already installed):"
    echo "   npm install -g openclaw"
    echo ""
    echo "2. Start your Control Tower:"
    echo "   openclaw gateway run"
    echo ""
    echo "3. Go to Discord and say hello in #engineering!"
    echo ""
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    echo "Need help? Check the docs: https://github.com/Substr8-Labs/control-tower"
    echo ""
}

# Main execution
main() {
    check_requirements
    get_bot_token
    get_server
    create_channels
    get_anthropic_key
    generate_config
    show_next_steps
}

main
