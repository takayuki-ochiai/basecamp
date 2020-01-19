FROM golang:1.13.4-buster as base

RUN curl -sL -o /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_x86_64 && \
    chmod +x /usr/local/bin/dumb-init
WORKDIR /go/src/backend/

FROM base as source
# for install realize
RUN go get -v gopkg.in/urfave/cli.v2 && \
    go get -v github.com/oxequa/realize
COPY ./src .

# Develop Image
FROM source as dev
ENV GO111MODULE on
ENTRYPOINT ["/usr/local/bin/dumb-init", "--"]
CMD ["realize", "start"]
