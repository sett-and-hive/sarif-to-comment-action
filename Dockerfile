# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:f52e0eb0f31863051b56d76d191b283c2b49ac084762eddfeb1afb54791b250b

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
