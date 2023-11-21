# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:64e9f17e17a0447941ea96ef48b41818adbc86e7e1f5c64bb8cbf866984ee3d3

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
