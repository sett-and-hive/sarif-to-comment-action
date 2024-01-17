# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:ef46f8bf489e6a6c2d056e0c0bec23a4120b34aabb9551a446baf68282defa01

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
