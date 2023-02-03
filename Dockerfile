# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:e75a12d97ee874d93f44b99120ac6c2fc19256edfbb285195946ce7b120a798b

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
