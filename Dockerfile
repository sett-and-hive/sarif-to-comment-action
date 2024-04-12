# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:65881997e49f9118732af6e10e88cd6b632df8c8f1b0d47009c604103a46d955

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
