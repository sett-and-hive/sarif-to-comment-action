# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:b64d3ff72c327bc8184d7a6d85ed189901a407891340e4693a246f34eb2993aa

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
