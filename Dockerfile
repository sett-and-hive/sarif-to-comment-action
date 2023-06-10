# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:798f2ae4961988e3071f4c6602268e46d2fde530acd9fc4c96b9836a3b2abc8d

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
