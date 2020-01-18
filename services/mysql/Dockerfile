FROM mysql:8.0.16 as base

# Develop Image
FROM base as dev
COPY ./conf.d /etc/mysql/conf.d
COPY ./initdb.d /docker-entrypoint-initdb.d
