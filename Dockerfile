# syntax=docker/dockerfile:1

FROM node:22-bookwork-slim@sha256:840079c08ec485123cf7ea506a13afea630db25606f71e6140cf8dbdf9bba552

WORKDIR /app

# Install dependencies
RUN npm install --ignore-scripts  --global npm@10.8.1 && \
    npm install --ignore-scripts  --global npx --force && \
    npm cache clean --force && \
    npm install --ignore-scripts  --global @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
