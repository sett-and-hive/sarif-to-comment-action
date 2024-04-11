# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:c5014e11f343e1b34962bd709e4269480b580c4c8d321a1b93eadde7bc833f87

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
