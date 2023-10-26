# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:9bd92446fa6af24593919e2e617b08b2462e4d9eb504775a7aa118fe4b24986a

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
