# syntax=docker/dockerfile:1

FROM node:19-bullseye-slim@sha256:8ac2083552bb3d92abbbda6baaf9b89b054bfa2cde863d965df9c28ac9baef41

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
