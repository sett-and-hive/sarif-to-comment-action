# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:3afb93c631e692edb893a403d25f9b4cae4b03748244cc9804c31dd957235682

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
