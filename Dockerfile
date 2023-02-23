# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:8a4fc51c2c3b5a79fee36db5da5e3975f14257cb607f12b25b205ac923394c37

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
