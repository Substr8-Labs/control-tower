# Control Tower - AI Executive Team
# Based on OpenClaw

FROM node:22-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Create app user and directories
RUN useradd -m -s /bin/bash tower && \
    mkdir -p /home/tower/.openclaw/workspace && \
    chown -R tower:tower /home/tower

USER tower
WORKDIR /home/tower

# Copy persona files and config template
COPY --chown=tower:tower personas/ /home/tower/.openclaw/personas/
COPY --chown=tower:tower openclaw/COMPANY.example.md /home/tower/.openclaw/workspace/COMPANY.md

# Copy entrypoint
COPY --chown=tower:tower docker/entrypoint.sh /home/tower/entrypoint.sh
RUN chmod +x /home/tower/entrypoint.sh

# Gateway port
EXPOSE 18789

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD openclaw gateway probe || exit 1

ENTRYPOINT ["/home/tower/entrypoint.sh"]
