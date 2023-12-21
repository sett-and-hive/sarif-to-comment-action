# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:a46d5f82c3c88ff4870bff5203e9fda43699719e3a458a4dbf4691e80951db5a

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
