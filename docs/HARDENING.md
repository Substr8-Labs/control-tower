# VPS Hardening Guide

**For:** Control Tower deployments  
**Reference server:** srv1338949 (Hostinger)  
**Last updated:** 2026-02-08

---

## Overview

Before installing OpenClaw or any agent infrastructure, the VPS must be hardened. This document captures the security measures applied to the reference deployment.

**Principle:** Defense in depth. Assume any layer can fail.

---

## 1. User & Access Hardening

### Non-Root User

Never run services as root. Create a dedicated user:

```bash
# Create user with home directory
sudo adduser claw

# Add to sudo group (for initial setup only)
sudo usermod -aG sudo claw

# Switch to user
su - claw
```

### SSH Hardening

Edit `/etc/ssh/sshd_config`:

```bash
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Restart SSH:

```bash
sudo systemctl restart sshd
```

**Before doing this:** Ensure your SSH key is in `~/.ssh/authorized_keys` or you'll be locked out.

### SSH Key Setup

```bash
# On your local machine
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy to server (while password auth still works)
ssh-copy-id -i ~/.ssh/id_ed25519.pub claw@your-server-ip
```

---

## 2. Network Hardening

### Tailscale (Private Mesh)

Install Tailscale for secure access without exposing ports:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

**For public HTTPS access (optional):**

```bash
sudo tailscale funnel 443
```

This exposes only port 443 via Tailscale's edge, not your server directly.

### Loopback-Only Binding

Services should bind to `127.0.0.1` unless explicitly needed externally:

```bash
# OpenClaw binds to loopback by default
# Tailscale Funnel proxies external traffic to loopback
```

### Firewall (if needed)

If not using Tailscale exclusively:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 443/tcp  # Only if serving HTTPS directly
sudo ufw enable
```

**With Tailscale Funnel:** Firewall is optional — Tailscale handles ingress.

---

## 3. Service Hardening

### User-Level systemd (Not Root)

Run services as your user, not system-wide:

```bash
# Enable user lingering (services run without login)
sudo loginctl enable-linger claw

# Services go in ~/.config/systemd/user/
mkdir -p ~/.config/systemd/user
```

**Why:** Limits blast radius. Compromised service can't touch system.

### OpenClaw Gateway Service

Create `~/.config/systemd/user/openclaw-gateway.service`:

```ini
[Unit]
Description=OpenClaw Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment="PATH=/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin"
ExecStart=/home/linuxbrew/.linuxbrew/bin/node /usr/lib/node_modules/openclaw/dist/gateway/index.js
WorkingDirectory=/home/claw/.openclaw
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
```

**Critical:** Use Linuxbrew node, not system node (see Node.js Trap below).

Enable and start:

```bash
systemctl --user daemon-reload
systemctl --user enable openclaw-gateway.service
systemctl --user start openclaw-gateway.service
```

### Secrets in Service Environment

Never put secrets in shell history. Use environment files:

```bash
# Create secrets file (readable only by user)
touch ~/.openclaw/.env
chmod 600 ~/.openclaw/.env

# Add secrets
echo "ANTHROPIC_API_KEY=sk-..." >> ~/.openclaw/.env
```

Reference in systemd:

```ini
[Service]
EnvironmentFile=/home/claw/.openclaw/.env
```

---

## 4. The Node.js Trap (NSolid)

### The Problem

Some VPS providers (including Hostinger) symlink `/usr/bin/node` to NSolid:

```bash
$ ls -la /usr/bin/node
lrwxrwxrwx 1 root root 21 ... /usr/bin/node -> /usr/bin/nsolid
```

NSolid is a monitoring wrapper that breaks OpenClaw:

```
error: unknown command '/usr/bin/nsolid'
```

### The Fix

Install Node via Linuxbrew and use that in systemd:

```bash
# Install Linuxbrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to path
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
source ~/.bashrc

# Install Node
brew install node

# Verify
/home/linuxbrew/.linuxbrew/bin/node --version
```

In systemd, explicitly use the Linuxbrew path:

```ini
ExecStart=/home/linuxbrew/.linuxbrew/bin/node /usr/lib/node_modules/openclaw/dist/gateway/index.js
```

---

## 5. Operational Security

### Gateway Health Monitoring

Check gateway is running:

```bash
systemctl --user status openclaw-gateway.service
openclaw gateway probe
openclaw health
```

### Memory Leak Mitigation

The OpenClaw gateway may accumulate memory over time. Daily restart recommended:

```bash
# Cron job (or use OpenClaw's built-in cron)
# Restarts at 2am local time
0 2 * * * systemctl --user restart openclaw-gateway.service
```

### Log Monitoring

```bash
# Follow gateway logs
journalctl --user -u openclaw-gateway.service -f

# Check for errors
journalctl --user -u openclaw-gateway.service --since "1 hour ago" | grep -i error
```

---

## 6. Pre-Flight Checklist

Before going live, verify:

| Check | Command | Expected |
|-------|---------|----------|
| SSH root disabled | `grep PermitRootLogin /etc/ssh/sshd_config` | `no` |
| SSH password disabled | `grep PasswordAuthentication /etc/ssh/sshd_config` | `no` |
| Non-root user | `whoami` | `claw` (not `root`) |
| Tailscale connected | `tailscale status` | Shows your machine |
| Gateway listening | `ss -ltnp \| grep 18789` | Shows listener |
| Gateway healthy | `openclaw gateway probe` | Success |
| Secrets protected | `ls -la ~/.openclaw/.env` | `-rw-------` |

---

## 7. Recovery Procedures

### Locked Out of SSH

If you accidentally lock yourself out:
1. Use VPS provider's console/VNC access
2. Fix `/etc/ssh/sshd_config`
3. Add your SSH key to authorized_keys
4. Restart sshd

### Gateway Won't Start

```bash
# Check logs
journalctl --user -u openclaw-gateway.service -n 50

# Common fixes:
# 1. Wrong node path → check ExecStart
# 2. Port in use → ss -ltnp | grep 18789
# 3. Missing env vars → check EnvironmentFile
```

### Tailscale Funnel Issues

```bash
# Re-enable funnel
sudo tailscale funnel reset
sudo tailscale funnel 443

# Check status
tailscale funnel status
```

---

## Cloud Provider Notes

### Hostinger

- Console access via hPanel
- NSolid trap applies (use Linuxbrew node)
- No built-in firewall UI — use ufw or Tailscale

### Future: One-Click Templates

For providers that support it (DigitalOcean, Vultr), we can create:
- Pre-hardened images with all the above
- User-data scripts for automated setup
- Marketplace listings

---

## Summary

| Layer | Hardening |
|-------|-----------|
| Access | SSH keys only, no root, non-root user |
| Network | Tailscale mesh, loopback binding, funnel for HTTPS |
| Services | User-level systemd, secrets in env files |
| Node.js | Linuxbrew node (avoid NSolid trap) |
| Operations | Health monitoring, daily restart, log checks |

---

*This document is the security foundation for all Control Tower deployments.*
