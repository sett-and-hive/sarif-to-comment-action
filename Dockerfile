# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:115459129ed17d1c8c4a7911e7a3756c8e49b9d89e3eac48f34249578c9971ef

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
