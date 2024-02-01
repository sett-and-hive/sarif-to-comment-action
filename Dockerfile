# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:075946be0844cc78063ac4c4654ec6c0d232b21a80f5af96ef2681182c5bf237

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
