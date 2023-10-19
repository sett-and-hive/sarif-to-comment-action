# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:682c1557c5a8cd6f8a78db3bd315ed968b3a854de2a16c2b8ce713cc92152062

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
