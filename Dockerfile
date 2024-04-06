# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:b307acadb845540961fa70ac4ca060390f0c33375ad7705943310d25c6f87d32

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
