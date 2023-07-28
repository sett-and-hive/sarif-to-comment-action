# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:55571ebc48f4dfecfb4d6ec0a056a042ac32ed1ebea44d0fedd78088709b9948

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
