# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:4c4d1930c335191ebcf049eec6a4d35571b1fb9468ab0b8a403724c1a6d23f58

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
