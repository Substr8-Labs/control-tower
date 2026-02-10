# Control Tower Quick Start

Get your AI executive team running in 5 minutes.

## Step 1: Create Your Discord Server (1 min)

1. Open Discord
2. Click the **+** button (left sidebar)
3. Select **"Create My Own"** → **"For me and my friends"**
4. Name it **"[YourCompany] HQ"**
5. Click **Create**

## Step 2: Add the Bot (30 sec)

Click this link and select your server:

**[Add Control Tower Bot](https://discord.com/oauth2/authorize?client_id=1469265115248463995&permissions=8&scope=bot)**

Click **Authorize**.

## Step 3: Run Setup (1 min)

Get your Server ID:
1. In Discord, right-click your server name
2. Click **"Copy Server ID"** (enable Developer Mode in Settings → Advanced if you don't see this)

Then run:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/Substr8-Labs/control-tower/main/tools/setup-tower.py

# Run it with your server ID and company name
python3 setup-tower.py YOUR_SERVER_ID "Your Company Name"
```

## Step 4: Start Using It

Go to any channel and start chatting:

- **#engineering** → Technical questions (Ada)
- **#product** → Product strategy (Grace)  
- **#marketing** → Growth & messaging (Tony)
- **#finance** → Business planning (Val)
- **#general** → Cross-functional discussions

---

## That's It!

Your AI executive team is ready. They'll respond in their respective channels.

### Need Help?

- Join our Discord: https://discord.gg/hw2r5gRPM2
- Docs: https://github.com/Substr8-Labs/control-tower
