# syntax=docker/dockerfile:1

FROM node:21-bullseye-slim@sha256:29a0fb94a755e0e29afffadf2ad1d83bf89471237b9adc18148af2ff78eed6c1

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.10 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
