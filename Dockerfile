# syntax=docker/dockerfile:1

FROM node:22-bullseye-slim@sha256:6bdd5766dc26c92f47cddf61eaa330170d9a9bfb65829e07d2f71ac84db01469

WORKDIR /app

# Install dependencies
COPY package.json .
RUN npm install --ignore-scripts  --global npm@10.8.1 && \
    npm install --ignore-scripts  --global npx --force && \
    npm cache clean --force && \
    npm install --ignore-scripts  --global @security-alert/sarif-to-comment@1.10.10 &&\
    npm install --ignore-scripts  --global && \
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh
USER node
ENTRYPOINT ["bash", "/app/entrypoint.sh"]
