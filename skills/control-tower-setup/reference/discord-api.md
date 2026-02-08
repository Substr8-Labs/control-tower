# Discord API Reference

Quick reference for Control Tower setup automation.

## Authentication

All requests need:
```
Authorization: Bot <token>
Content-Type: application/json
```

## Endpoints

### Create Channel
```
POST /guilds/{guild.id}/channels

{
  "name": "channel-name",
  "type": 0,           // 0 = text, 2 = voice, 4 = category
  "topic": "Description",
  "parent_id": "category-id"  // optional
}
```

### Get Guild Channels
```
GET /guilds/{guild.id}/channels
```

### Send Message
```
POST /channels/{channel.id}/messages

{
  "content": "Hello!",
  "embeds": [...]  // optional
}
```

### Create Category (for organization)
```
POST /guilds/{guild.id}/channels

{
  "name": "Control Tower",
  "type": 4
}
```

## Permission Integer

Calculate at: https://discordapi.com/permissions.html

| Permission | Value |
|------------|-------|
| MANAGE_CHANNELS | 16 |
| SEND_MESSAGES | 2048 |
| MANAGE_MESSAGES | 8192 |
| READ_MESSAGE_HISTORY | 65536 |

Combined: `75776`

## OAuth URL Format

```
https://discord.com/api/oauth2/authorize
  ?client_id=<BOT_CLIENT_ID>
  &permissions=<PERMISSION_INT>
  &scope=bot
```

## Rate Limits

- Global: 50 requests/second
- Per-route: varies (usually 5/5s for channel creation)
- Response headers: `X-RateLimit-*`

## Events (for webhook/gateway)

- `GUILD_CREATE` — Bot added to server
- `CHANNEL_CREATE` — New channel created
- `MESSAGE_CREATE` — New message

## Error Codes

| Code | Meaning |
|------|---------|
| 10003 | Unknown Channel |
| 10004 | Unknown Guild |
| 50001 | Missing Access |
| 50013 | Missing Permissions |
