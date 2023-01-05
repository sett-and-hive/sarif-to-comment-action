# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:d6f1d4b0ba2b51f1ea448a27ae31f499ddfcef60cc51f899264a8e8be22e2d0b

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
