# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim

# WORKDIR /app

# Install dependencies
RUN npm install @security-alert/sarif-to-comment@1.10.4
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
