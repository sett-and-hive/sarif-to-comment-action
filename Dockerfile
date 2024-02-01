# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:0567f3294fac3e372bbc33beef37a55109a2579956a504b4eaae177de2e248b6

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
