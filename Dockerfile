# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:5138ded35380c7e55b7898a5c3666009334aa4af416571060d37347242e1812f

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
