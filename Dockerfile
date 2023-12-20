# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:e42a19a34d91f1d9be82f60bc7a8e349171df305b5f6aefe862d44d98089d9bb

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
