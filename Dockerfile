# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:bc5812b018fa74ea7dbe759cb6c0b456ff96a5c2bc8765e132438f6a75cd6946

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
