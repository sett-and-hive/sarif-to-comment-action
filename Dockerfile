# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:9cb48d12eeccb9e6ad25e987dda1077399cd63877a46e9e848273c44690ca175

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
