# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim@sha256:70bf84739156657c85440e6a55a3d77a7cac668f9c4c3c44005bc29bdc529db7

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
