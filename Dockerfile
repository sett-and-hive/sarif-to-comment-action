# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:d205d6314aad59b3bfa83a98daeb81672854fdf162d3875708484c9c3153a626

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
