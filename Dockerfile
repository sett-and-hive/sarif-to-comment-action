# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:48410457928b6f90c6137d51e4de27d78b66529e0162f4441e83608e58c78b07

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
