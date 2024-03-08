# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:cfa357b2b0c37e66057525c0e8b06cf1cb54f9cb5534b401b0a587df794a25df

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
