# syntax=docker/dockerfile:1

FROM node:22-bullseye-slim@sha256:1f71b85503b7f10480fad48d4c50aff8bd55abb68d3db280b908bb9c8fb214ff

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
