#!/usr/bin/env python3
"""
Control Tower Server Creator

Creates a fully configured Discord server for Control Tower with:
- All channels (general, engineering, product, marketing, finance)
- Roles for each persona
- Proper permissions
- Welcome message
- Returns invite link

Usage:
    python create-tower.py "Company Name"
    python create-tower.py "Acme Corp" --token YOUR_BOT_TOKEN
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
]

# Role configuration (will be created for reference, bot uses these for persona routing)
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
2. **Tag @Substr8 AI** — For cross-functional questions in #general
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


def create_guild(name: str, token: str) -> dict:
    """Create a new Discord guild (server)."""
    print(f"Creating server '{name}'...")
    
    data = {
        "name": name,
    }
    
    guild = api_request("POST", "/guilds", token, data)
    print(f"  ✅ Created server: {guild['name']} (ID: {guild['id']})")
    return guild


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


def delete_default_channels(guild_id: str, token: str):
    """Delete default channels created with the guild."""
    channels = api_request("GET", f"/guilds/{guild_id}/channels", token)
    
    for channel in channels:
        if channel["name"] in ["general", "text-channels", "voice-channels"]:
            try:
                api_request("DELETE", f"/channels/{channel['id']}", token)
                print(f"  🗑️  Deleted default #{channel['name']}")
            except:
                pass  # Ignore errors deleting defaults
    
    # Small delay to let Discord process
    time.sleep(0.5)


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


def setup_server(company_name: str, token: str) -> dict:
    """Set up a complete Control Tower server."""
    
    server_name = f"{company_name} HQ"
    
    # Create the guild
    guild = create_guild(server_name, token)
    guild_id = guild["id"]
    
    # Small delay for Discord to process
    time.sleep(1)
    
    # Delete default channels
    print("Cleaning up defaults...")
    delete_default_channels(guild_id, token)
    
    # Create roles
    print("Creating roles...")
    created_roles = {}
    for role in ROLES:
        created_role = create_role(guild_id, role["name"], role["color"], role["hoist"], token)
        created_roles[role["name"]] = created_role
        time.sleep(0.3)  # Rate limit friendly
    
    # Create channels
    print("Creating channels...")
    created_channels = {}
    for channel in CHANNELS:
        created_channel = create_channel(
            guild_id, 
            channel["name"], 
            channel["topic"], 
            channel["type"], 
            token
        )
        created_channels[channel["name"]] = created_channel
        time.sleep(0.3)  # Rate limit friendly
    
    # Send welcome message
    print("Sending welcome message...")
    welcome_channel = created_channels.get("welcome")
    if welcome_channel:
        welcome_text = WELCOME_MESSAGE.format(company=company_name)
        send_message(welcome_channel["id"], welcome_text, token)
    
    # Create invite link
    print("Creating invite link...")
    general_channel = created_channels.get("general") or welcome_channel
    invite = create_invite(general_channel["id"], token)
    invite_url = f"https://discord.gg/{invite['code']}"
    
    return {
        "guild_id": guild_id,
        "guild_name": server_name,
        "invite_url": invite_url,
        "channels": {name: ch["id"] for name, ch in created_channels.items()},
        "roles": {name: r["id"] for name, r in created_roles.items()},
    }


def main():
    parser = argparse.ArgumentParser(
        description="Create a Control Tower Discord server"
    )
    parser.add_argument(
        "company",
        help="Company name for the server"
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
    
    print(f"\n🏰 Creating Control Tower for '{args.company}'...\n")
    
    try:
        result = setup_server(args.company, args.token)
        
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"\n{'='*50}")
            print(f"✅ Control Tower created successfully!")
            print(f"{'='*50}")
            print(f"\n📍 Server: {result['guild_name']}")
            print(f"🔗 Invite: {result['invite_url']}")
            print(f"\nChannels created:")
            for name in result['channels']:
                print(f"  • #{name}")
            print(f"\nShare this link with the founder:")
            print(f"\n  {result['invite_url']}\n")
            
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
