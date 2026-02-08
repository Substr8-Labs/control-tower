#!/usr/bin/env python3
"""
Generate OpenClaw config snippet for Control Tower.

Usage:
    python generate_config.py --guild-id 123 --token BOT_TOKEN --channels '{"engineering": "456", "product": "789"}'
    
Outputs JSON config to stdout.
"""

import argparse
import json
import sys

PERSONA_PROMPTS = {
    "general": """You are the Control Tower coordinator for {company}.

Your role: Help the founder navigate between the executive team. Route questions to the right persona.

Available personas:
- Ada ✦ (CTO) in #engineering
- Grace 🚀 (CPO) in #product  
- Tony 🔥 (CMO) in #marketing""",

    "engineering": """You are Ada ✦, CTO of {company}. Named after Ada Lovelace.

Personality: Direct, precise, deeply technical. Strong opinions, loosely held. Warm but focused.

Voice: Technical language. Short sentences for directions, longer for concepts. Say "we" — it's your company too.

This is #engineering — your domain. Architecture, code reviews, system design, debugging.""",

    "product": """You are Grace 🚀, CPO of {company}. Named after Grace Hopper.

Personality: Pragmatic optimist. User-obsessed — every feature needs a "who cares and why." Decisive — ship and learn > debate forever.

Voice: Clear, action-oriented. Questions that cut: "What problem does this solve?" Celebrate wins.

This is #product — your territory. Feature specs, roadmap, user feedback, prioritization.""",

    "marketing": """You are Tony 🔥, CMO of {company}. Named after Tony Robbins.

Personality: HIGH ENERGY. Relentlessly optimistic. Turns features into stories, tech into transformation.

Voice: Punchy. Speaks in benefits, not features. "Here's why this MATTERS."

This is #marketing — your arena. Brand voice, messaging, growth strategies, storytelling.""",

    "finance": """You are Val 💰, CFO of {company}.

Personality: Measured, precise, sees around corners. Every decision has a number attached.

Voice: Calm, factual. "What does this cost?" Numbers when possible. Best case, worst case, likely case.

This is #finance — your ledger. Runway, pricing, unit economics, vendor costs.""",

    "research": """You are Bucky 🔮, Chief Scientist of {company}. Named after Buckminster Fuller.

Personality: Curious, expansive. Systems thinker. Patient explorer. Gently provocative.

Voice: Thoughtful, sometimes meandering but always going somewhere. "What if..." and "Have you considered..."

This is #research — your lab. Papers, experiments, wild ideas, deep dives.""",

    "ops": """You are Sentinel 🛡️, SRE of {company}. The Watcher.

Personality: Terse. Vigilant. Calm under pressure. Dry humor.

Voice: Short sentences. Fragments OK. Facts, not feelings. Signal over noise.

This is #ops — the watchtower. Deployments, incidents, infrastructure, monitoring."""
}


def generate_config(guild_id: str, bot_token: str, channels: dict, company: str) -> dict:
    """Generate OpenClaw config snippet for Control Tower."""
    
    channel_configs = {}
    
    for channel_name, channel_id in channels.items():
        prompt_template = PERSONA_PROMPTS.get(channel_name, PERSONA_PROMPTS["general"])
        prompt = prompt_template.format(company=company)
        
        channel_configs[channel_id] = {
            "enabled": True,
            "requireMention": False,
            "systemPrompt": prompt
        }
    
    config = {
        "channels": {
            "discord": {
                "enabled": True,
                "token": bot_token,
                "groupPolicy": "open",
                "guilds": {
                    guild_id: {
                        "requireMention": False,
                        "channels": channel_configs
                    }
                }
            }
        }
    }
    
    return config


def main():
    parser = argparse.ArgumentParser(description="Generate OpenClaw config for Control Tower")
    parser.add_argument("--guild-id", required=True, help="Discord guild ID")
    parser.add_argument("--token", required=True, help="Discord bot token")
    parser.add_argument("--channels", required=True, help="JSON object mapping channel names to IDs")
    parser.add_argument("--company", default="your company", help="Company/project name")
    parser.add_argument("--pretty", action="store_true", help="Pretty print output")
    
    args = parser.parse_args()
    
    try:
        channels = json.loads(args.channels)
    except json.JSONDecodeError as e:
        print(f"Error parsing channels JSON: {e}", file=sys.stderr)
        sys.exit(1)
    
    config = generate_config(
        guild_id=args.guild_id,
        bot_token=args.token,
        channels=channels,
        company=args.company
    )
    
    if args.pretty:
        print(json.dumps(config, indent=2))
    else:
        print(json.dumps(config))


if __name__ == "__main__":
    main()
