# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:ae7a610be3c47e2cecb1ac58827c2c4ec5b7a9d0a2a5a9ac5a59298bbec6e4b2

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
