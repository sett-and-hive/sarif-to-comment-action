# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:a986a5f80c06758c0742f79ca3468615c39e1a6b733157a172de85c5fa9cace6

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
