# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:cc16ec9e9a785fe0a185ac07d121327fd0efe4f588a55297362a5d4a9a347013

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
