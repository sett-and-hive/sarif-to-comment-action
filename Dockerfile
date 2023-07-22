# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:45dbc40906607e48873d26caa1a968f1a5187dd5e78e0e47205eea15393fd9c3

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
