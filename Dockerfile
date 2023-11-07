# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:2c247f69ae354d692fcb76cab79cdbaa14485c0e0375a70efca9a98201b4ed29

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
