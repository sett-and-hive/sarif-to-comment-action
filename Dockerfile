# syntax=docker/dockerfile:1

# 1. Base Image: Use official LTS (Node 22) on Debian 12 (Bookworm)
# This instantly fixes the "ancient npm" vulnerabilities.
FROM node:22-bookworm-slim

WORKDIR /app

# 2. Install System Dependencies
# We include curl/ca-certificates to fetch the GH CLI manually.
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Install GitHub CLI (Direct Binary Download)
# We update to 2.83.1 (Nov 2025) to fix CVE-2024-45337 (x/crypto)
# and ensure the binary was compiled with a modern Go runtime (fixing stdlib CVEs).
ARG GH_VERSION=2.83.1
RUN curl -fsSL https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz -o gh.tar.gz \
    && tar -xzf gh.tar.gz \
    && mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin/gh \
    && rm -rf gh.tar.gz gh_${GH_VERSION}_linux_amd64 \
    && gh --version

# 4. Install & Patch Node Dependencies
# FIX: Added --ignore-scripts to ALL commands to prevent 'node-gyp' from
# trying to compile native addons (which causes exit code 127 on slim images).
# FIX: Used $(npm root -g) to dynamically find the install path.
RUN npm install -g npm@latest --ignore-scripts && \
    npm install -g @security-alert/sarif-to-comment@1.10.10 --omit=dev --ignore-scripts && \
    # <--- The Security Patch Layer --->
    cd "$(npm root -g)/@security-alert/sarif-to-comment" && \
    npm update --depth 99 --omit=dev --ignore-scripts && \
    # Clean up caches to keep image small
    npm cache clean --force && \
    rm -rf /root/.npm /root/.cache

COPY ./entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
