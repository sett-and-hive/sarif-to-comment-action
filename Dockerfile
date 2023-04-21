# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:2cd3fdd49eb8bc1b942be824030469beca57fb6723edaaa9041e593b79a56cd1

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
