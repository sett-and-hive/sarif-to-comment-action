# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim@sha256:4eaa2cfea4d58a22805753c13448a419e6e84bd86f1cf99cccab57cc6b605558

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.4 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
