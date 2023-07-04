# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:90e0095d6f8526f308259d97a322b5a5bd5416c17fcc78aa2894c3b62ebe370f

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
