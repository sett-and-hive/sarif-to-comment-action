# syntax=docker/dockerfile:1

# 1. Base Image: Use official LTS (Node 22) on Debian 12 (Bookworm)
# This instantly fixes the "ancient npm" vulnerabilities.
FROM node:24-bookworm-slim

WORKDIR /app

# 2. Install System Dependencies and Security Updates
# We include curl/ca-certificates to fetch the GH CLI manually.
# Upgrade all system packages to get latest security patches (including libpam-modules for CVE-2025-6020)
RUN apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
    curl \
    ca-certificates \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 3. Install GitHub CLI (Direct Binary Download)
# We update to 2.83.1 (Nov 2025) to fix CVE-2024-45337 (x/crypto)
# and ensure the binary was compiled with a modern Go runtime (fixing stdlib CVEs).
ARG GH_VERSION=2.83.1
# Download and verify GitHub CLI via published SHA256 checksums to reduce supply-chain risk.
RUN set -e; \
    GH_BASE_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
    # 1. Define the official filename expected by the checksum file
    GH_FILENAME="gh_${GH_VERSION}_linux_amd64.tar.gz"; \
    # 2. Download artifacts using the OFFICIAL name (Critical for sha256sum)
    curl -fsSL "${GH_BASE_URL}/${GH_FILENAME}" -o "${GH_FILENAME}"; \
    curl -fsSL "${GH_BASE_URL}/gh_${GH_VERSION}_checksums.txt" -o gh_checksums.txt; \
    # 3. Verify (Grep ensures we only check the linux_amd64 hash)
    grep " ${GH_FILENAME}\$" gh_checksums.txt > gh_checksums_filtered.txt; \
    sha256sum -c gh_checksums_filtered.txt; \
    # 4. Extract & Install
    tar -xzf "${GH_FILENAME}"; \
    mv "gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin/gh; \
    # 5. Cleanup
    rm -rf "${GH_FILENAME}" gh_checksums.txt gh_checksums_filtered.txt "gh_${GH_VERSION}_linux_amd64"; \
    gh --version

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
