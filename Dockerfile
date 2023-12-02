# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:10235f11a217783f6a796724a3a0be525db0feee8a3e46f197e0c3a11702bbc3

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
