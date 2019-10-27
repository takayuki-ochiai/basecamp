FROM node:12.13.0-slim as base

RUN apt-get update && apt-get install -y git
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
EXPOSE 3000
RUN mkdir /app && chown -R node:node /app
WORKDIR /app

USER node
COPY --chown=node:node package.json package-lock.json tsconfig.json ./
RUN npm ci && npm cache clean --force

# Develop Image
FROM base as dev
ENV NODE_ENV=development
ENV PATH=/app/node_modules/.bin:$PATH
CMD ["npm", "run", "dev"]

# Source Image
FROM base as source
COPY --chown=node:node . .

# Production Image
FROM source as prod
ENV NODE_ENV=production
RUN npm run build
ENTRYPOINT ["/tini", "--"]
CMD ["ts-node","src/server/index.ts"]
