# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:6459dbe71065404cc3d7608611bc742a3d7829fee2b8e013590323738c5a146c

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
