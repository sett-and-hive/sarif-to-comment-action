# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:d9730e4dd0f0ca135d2407592646252880089cd9ea2405f54da9c076e3fd8ce7

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
