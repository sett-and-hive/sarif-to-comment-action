# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:fc31003e2875c484f7a34416ca36d74b64fbaf46413b2a50f495d91a593a4acb

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
