# syntax=docker/dockerfile:1

FROM node:22-bullseye-slim@sha256:e6e561d53bcaccb763a2ad6f5cdc93c2ee115301e0cb818b301757a6f1beffdf

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
