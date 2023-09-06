# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:36d587c8542eafc209a8419b1b8ba3225b002b6d15e75bd094c78ca6cd605ec3

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
