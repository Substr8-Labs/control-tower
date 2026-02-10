#!/usr/bin/env python3
"""
Control Tower Server Setup

Configures an EXISTING Discord server as a Control Tower:
- Creates all channels (engineering, product, marketing, finance)
- Creates roles for each persona
- Sends welcome message
- Outputs configuration

Usage:
    python setup-tower.py GUILD_ID "Company Name"
    python setup-tower.py 1234567890 "Acme Corp"

The user creates their own server, adds the bot, then runs this.
"""

import argparse
import json
import os
import sys
import time
from urllib.request import Request, urlopen
from urllib.error import HTTPError

# Discord API base
API_BASE = "https://discord.com/api/v10"

# Channel configuration
CHANNELS = [
    {"name": "welcome", "topic": "Welcome to your AI executive team!", "type": 0},
    {"name": "general", "topic": "General discussion with your AI team", "type": 0},
    {"name": "engineering", "topic": "Technical discussions with Ada (CTO)", "type": 0},
    {"name": "product", "topic": "Product strategy with Grace (CPO)", "type": 0},
    {"name": "marketing", "topic": "Marketing & growth with Tony (CMO)", "type": 0},
    {"name": "finance", "topic": "Financial planning with Val (CFO)", "type": 0},
    {"name": "decisions", "topic": "Decision log and important choices", "type": 0},
    {"name": "onboarding", "topic": "Set up your Control Tower here", "type": 0},
]

# Role configuration
ROLES = [
    {"name": "Founder", "color": 0x5865F2, "hoist": True},  # Discord blurple
    {"name": "Ada (CTO)", "color": 0x57F287, "hoist": False},  # Green
    {"name": "Grace (CPO)", "color": 0xFEE75C, "hoist": False},  # Yellow
    {"name": "Tony (CMO)", "color": 0xEB459E, "hoist": False},  # Pink
    {"name": "Val (CFO)", "color": 0xED4245, "hoist": False},  # Red
]

WELCOME_MESSAGE = """# 🏰 Welcome to {company} Control Tower!

Your AI executive team is ready to help you build.

## Your Team

| Channel | Persona | Focus |
|---------|---------|-------|
| #engineering | **Ada** (CTO) | Technical architecture, code, infrastructure |
| #product | **Grace** (CPO) | Product strategy, features, roadmap |
| #marketing | **Tony** (CMO) | Growth, messaging, go-to-market |
| #finance | **Val** (CFO) | Business model, pricing, runway |

## How It Works

1. **Post in any channel** — The relevant persona will respond
2. **Tag the bot** — For cross-functional questions in #general
3. **Use #decisions** — Document important choices

## Quick Start

Head to **#general** and tell us about your company. What are you building?

---
*Control Tower by Substr8 Labs — Your AI executive team*
"""


def api_request(method: str, endpoint: str, token: str, data: dict = None) -> dict:
    """Make a Discord API request."""
    url = f"{API_BASE}{endpoint}"
    headers = {
        "Authorization": f"Bot {token}",
        "Content-Type": "application/json",
        "User-Agent": "ControlTower/1.0",
    }
    
    body = json.dumps(data).encode() if data else None
    req = Request(url, data=body, headers=headers, method=method)
    
    try:
        with urlopen(req) as resp:
            if resp.status == 204:
                return {}
            return json.loads(resp.read().decode())
    except HTTPError as e:
        error_body = e.read().decode()
        print(f"API Error {e.code}: {error_body}", file=sys.stderr)
        raise


def get_guild(guild_id: str, token: str) -> dict:
    """Get guild info."""
    return api_request("GET", f"/guilds/{guild_id}", token)


def get_channels(guild_id: str, token: str) -> list:
    """Get all channels in a guild."""
    return api_request("GET", f"/guilds/{guild_id}/channels", token)


def create_channel(guild_id: str, name: str, topic: str, channel_type: int, token: str) -> dict:
    """Create a channel in a guild."""
    data = {
        "name": name,
        "type": channel_type,
        "topic": topic,
    }
    
    channel = api_request("POST", f"/guilds/{guild_id}/channels", token, data)
    print(f"  ✅ Created #{name}")
    return channel


def get_roles(guild_id: str, token: str) -> list:
    """Get all roles in a guild."""
    return api_request("GET", f"/guilds/{guild_id}/roles", token)


def create_role(guild_id: str, name: str, color: int, hoist: bool, token: str) -> dict:
    """Create a role in a guild."""
    data = {
        "name": name,
        "color": color,
        "hoist": hoist,
        "mentionable": True,
    }
    
    role = api_request("POST", f"/guilds/{guild_id}/roles", token, data)
    print(f"  ✅ Created role: {name}")
    return role


def send_message(channel_id: str, content: str, token: str) -> dict:
    """Send a message to a channel."""
    data = {"content": content}
    return api_request("POST", f"/channels/{channel_id}/messages", token, data)


def create_invite(channel_id: str, token: str) -> dict:
    """Create an invite link for a channel."""
    data = {
        "max_age": 0,  # Never expires
        "max_uses": 0,  # Unlimited uses
        "unique": True,
    }
    
    invite = api_request("POST", f"/channels/{channel_id}/invites", token, data)
    return invite


def setup_server(guild_id: str, company_name: str, token: str) -> dict:
    """Set up Control Tower in an existing server."""
    
    # Verify we can access the guild
    print(f"Connecting to server...")
    guild = get_guild(guild_id, token)
    print(f"  ✅ Connected to: {guild['name']}")
    
    # Get existing channels and roles
    existing_channels = get_channels(guild_id, token)
    existing_channel_names = {ch["name"].lower() for ch in existing_channels}
    
    existing_roles = get_roles(guild_id, token)
    existing_role_names = {r["name"].lower() for r in existing_roles}
    
    # Create missing roles
    print("Setting up roles...")
    created_roles = {}
    for role in ROLES:
        if role["name"].lower() not in existing_role_names:
            created_role = create_role(guild_id, role["name"], role["color"], role["hoist"], token)
            created_roles[role["name"]] = created_role
            time.sleep(0.3)
        else:
            print(f"  ⏭️  Role '{role['name']}' already exists")
            # Find existing role
            for r in existing_roles:
                if r["name"].lower() == role["name"].lower():
                    created_roles[role["name"]] = r
                    break
    
    # Create missing channels
    print("Setting up channels...")
    created_channels = {}
    for channel in CHANNELS:
        if channel["name"].lower() not in existing_channel_names:
            created_channel = create_channel(
                guild_id, 
                channel["name"], 
                channel["topic"], 
                channel["type"], 
                token
            )
            created_channels[channel["name"]] = created_channel
            time.sleep(0.3)
        else:
            print(f"  ⏭️  #{channel['name']} already exists")
            # Find existing channel
            for ch in existing_channels:
                if ch["name"].lower() == channel["name"].lower():
                    created_channels[channel["name"]] = ch
                    break
    
    # Send welcome message if welcome channel exists and is empty-ish
    welcome_channel = created_channels.get("welcome")
    if welcome_channel:
        print("Sending welcome message...")
        welcome_text = WELCOME_MESSAGE.format(company=company_name)
        try:
            send_message(welcome_channel["id"], welcome_text, token)
            print("  ✅ Welcome message sent")
        except Exception as e:
            print(f"  ⚠️  Could not send welcome message: {e}")
    
    # Create/get invite link
    print("Getting invite link...")
    general_channel = created_channels.get("general") or created_channels.get("welcome")
    if general_channel:
        try:
            invite = create_invite(general_channel["id"], token)
            invite_url = f"https://discord.gg/{invite['code']}"
        except:
            invite_url = "(Could not create invite - check bot permissions)"
    else:
        invite_url = "(No channel available for invite)"
    
    return {
        "guild_id": guild_id,
        "guild_name": guild["name"],
        "invite_url": invite_url,
        "channels": {name: ch["id"] for name, ch in created_channels.items()},
        "roles": {name: r["id"] for name, r in created_roles.items()},
    }


def main():
    parser = argparse.ArgumentParser(
        description="Set up Control Tower in an existing Discord server"
    )
    parser.add_argument(
        "guild_id",
        help="Discord server (guild) ID"
    )
    parser.add_argument(
        "company",
        help="Company name"
    )
    parser.add_argument(
        "--token",
        default=os.environ.get("DISCORD_BOT_TOKEN"),
        help="Discord bot token (or set DISCORD_BOT_TOKEN env var)"
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output result as JSON"
    )
    
    args = parser.parse_args()
    
    if not args.token:
        # Try to read from openclaw config
        config_path = os.path.expanduser("~/.openclaw/openclaw.json")
        if os.path.exists(config_path):
            with open(config_path) as f:
                config = json.load(f)
                args.token = config.get("channels", {}).get("discord", {}).get("token")
    
    if not args.token:
        print("Error: No Discord bot token provided", file=sys.stderr)
        print("Use --token or set DISCORD_BOT_TOKEN", file=sys.stderr)
        sys.exit(1)
    
    print(f"\n🏰 Setting up Control Tower for '{args.company}'...\n")
    
    try:
        result = setup_server(args.guild_id, args.company, args.token)
        
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"\n{'='*50}")
            print(f"✅ Control Tower setup complete!")
            print(f"{'='*50}")
            print(f"\n📍 Server: {result['guild_name']}")
            print(f"🔗 Invite: {result['invite_url']}")
            print(f"\nChannels:")
            for name, cid in result['channels'].items():
                print(f"  • #{name} ({cid})")
            print(f"\nRoles:")
            for name, rid in result['roles'].items():
                print(f"  • {name} ({rid})")
            print()
            
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
