# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:3e1a690b3dda477e2a0191acc7c545a2758fea90181bd9c87475096b76956351

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
