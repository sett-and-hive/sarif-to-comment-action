# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:788417c15fd7e0fde36a592e70c06fdb9b0a553733ad036e118ece9950d0d35e

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
