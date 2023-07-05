# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:57ae74ffd7253c71b6e896ae585184d26446ba10e689a02921a1852d24d82d74

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
