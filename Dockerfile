# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:945442de04fb2ed3917e3e43f86cf44286db0f9d472ef011f63a191cd2fbae93

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
