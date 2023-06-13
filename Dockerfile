# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:873d0db3312a942fd77d99117d2dbfc7e38c8cf51ab3a2157aa98ec5e9197ad8

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
