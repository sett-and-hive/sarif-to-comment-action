# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:b5c6acf736d668e4f07fdb5c24365264bce24566e5da2fd8e9893d7d378bad05

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
