# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:b7e71faa7f9ca4762c37fef680e0452482e71bfc74f4116dd73e2105ba756fd6

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
