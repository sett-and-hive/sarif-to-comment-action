# syntax=docker/dockerfile:1

FROM node:22-bullseye-slim@sha256:6bdd5766dc26c92f47cddf61eaa330170d9a9bfb65829e07d2f71ac84db01469
# This works in sarif-to-issue-action
# FROM node:22-bullseye-slim@sha256:78d58cb33cd6508d24dc07b6b9825d4669275b094ea2aafc9ae10610991d8945
# latest node image 9 February 2024
# FROM node:22-bullseye-slim@sha256:78d58cb33cd6508d24dc07b6b9825d4669275b094ea2aafc9ae10610991d8945
WORKDIR /app

# Install dependencies and update vulnerable packages
RUN npm install --ignore-scripts  --global npm@10.8.1 && \
    npm install --ignore-scripts  --global npx --force && \
    npm cache clean --force && \
    npm install --ignore-scripts  --global @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 \
        e2fsprogs=1.46.2-2+deb11u1 \
        libsystemd0=247.3-7+deb11u6 \
        logsave=1.46.2-2+deb11u1 \
        perl-base=5.32.1-4+deb11u4 \
        libcom-err2=1.46.2-2+deb11u1 \
        libudev1=247.3-7+deb11u6 \
        libss2=1.46.2-2+deb11u1 \
        && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
