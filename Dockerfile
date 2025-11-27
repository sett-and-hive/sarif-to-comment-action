# syntax=docker/dockerfile:1

# latest node-bullseye image 9 February 2024
FROM node:22-bullseye-slim@sha256:204476c3121ff0222e53b2cdf6f90d5c2997bfbb7f8285ad278ba4555de3a087
WORKDIR /app

# Install node dependencies and update vulnerable packages
RUN npm install --ignore-scripts  --global npm@11.1.0 && \
    npm install --ignore-scripts  --global npx --force && \
    npm cache clean --force && \
    npm install --ignore-scripts  --global @security-alert/sarif-to-comment@1.10.10 --omit=dev --no-audit --no-fund

# Remove unnecessary cache and temp files to reduce attack surface
RUN rm -rf /root/.npm /root/.cache

# Install jq and dependency security patches
RUN apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1+deb11u1 \
        e2fsprogs=1.46.2-2+deb11u1 \
        libsystemd0=247.3-7+deb11u7 \
        logsave=1.46.2-2+deb11u1 \
        perl-base=5.32.1-4+deb11u4 \
        libcom-err2=1.46.2-2+deb11u1 \
        libudev1=247.3-7+deb11u7 \
        libss2=1.46.2-2+deb11u1 \
        && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
