# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:67a73455d3befb6ff5ab8cafd3481df3ec4c643eac9d15230e2d6f58c443e47c

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.8 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
