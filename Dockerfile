# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:9e79f15dcf6544b7503ba032cffba65b5a1467a5ceca60fab258f518c5aa3828

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
