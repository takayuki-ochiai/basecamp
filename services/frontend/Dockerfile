FROM node:12.13.0-slim as base

RUN set -x && \
    : "install package" && \
    apt-get update && \
    apt-get install -y git vim less && \
    apt-get clean

RUN curl -sL -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 && \
    chmod +x /usr/local/bin/dumb-init
EXPOSE 3000
RUN mkdir /app && chown -R node:node /app
WORKDIR /app

USER node
COPY --chown=node:node package.json package-lock.json tsconfig.json ./
RUN npm ci && npm cache clean --force
ENV PATH=/app/node_modules/.bin:$PATH

ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
# デバッグ、パッケージ更新用
CMD ["sleep", "infinity"]

# Source Image
FROM base as source
COPY --chown=node:node . .

# Develop Image
FROM source as dev
ENV NODE_ENV=development
CMD ["npm", "run", "dev:watch"]

# Production Image
FROM source as prod
ENV NODE_ENV=production
RUN npm run build
CMD ["npm", "run", "production"]
