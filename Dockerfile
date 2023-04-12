# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:602626a95fde52072639a61a3bb6dad86aea5d6776687788f707d6bc2c6e0b87

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
