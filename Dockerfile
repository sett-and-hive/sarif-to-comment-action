# syntax=docker/dockerfile:1

FROM node:22-bullseye-slim@sha256:5baa25a7a7d4fde6ae7180db579f930748b9c6cd9c2ccf0065b9ea2c61585405

WORKDIR /app

# Install dependencies
RUN npm install --global npm@10.8.1 && \
    npm install --global npx --force && \
    npm cache clean --force && \
    npm install --global @security-alert/sarif-to-comment@1.10.10 --ignore-scripts &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
