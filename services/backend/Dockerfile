FROM golang:1.13.4-buster as base

WORKDIR /go/src/backend/

# Develop Image
FROM base as dev
# for install realize
RUN go get -v gopkg.in/urfave/cli.v2 && \
    go get -v github.com/oxequa/realize

COPY ./src .

ENV GO111MODULE on
CMD ["realize", "start"]
