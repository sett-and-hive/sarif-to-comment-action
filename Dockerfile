# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:3948235dedc00cadb7c8a7c8536818f3c788a8c80c175a4b2726944d9e5dc534

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
