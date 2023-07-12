# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:77360666adb6622d13d0f32786185b7ddc5e5cd4a9c4140097ee7fdd9b3db527

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
