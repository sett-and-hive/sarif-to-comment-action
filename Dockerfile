# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:383ded27268efc3424c99e8e48f1f227f6e9467852ba7cb1e10cfa4e9a893c8a

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
