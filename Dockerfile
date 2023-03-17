# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:f5eb5c04eeb0bdaff44e179b84b57b8958f2fc6fb814641d3a5f3fe27d93e248

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
