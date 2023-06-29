# syntax=docker/dockerfile:1

FROM node:20-bullseye-slim@sha256:00873eee0d287619672ccd368f32fa191ba43837f08d8d2dd8573b1311ed5273

WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.9 &&\
    apt-get update && apt-get install --no-install-recommends -y jq=1.6-2.1 &&\
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["bash", "/app/entrypoint.sh"]
