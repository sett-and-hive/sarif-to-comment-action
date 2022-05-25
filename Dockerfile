# syntax=docker/dockerfile:1

FROM node:18-bullseye-slim

COPY entrypoint.sh /entrypoint.sh

RUN npm install @security-alert/sarif-to-comment@1.10.3

ENTRYPOINT ["/entrypoint.sh"]
