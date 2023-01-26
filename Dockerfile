# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:8886b323f04105798b3e5aac31ab7cc9ee35ae71099fbd7cd6645e1d165dbf94

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
