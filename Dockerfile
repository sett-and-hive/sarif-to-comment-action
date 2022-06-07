# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim@sha256:0739e03851228cc1380f60e9dc14c192bd9d22d02eab364de609b6b8efb94174

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.4 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
