FROM golang:1.16.0-alpine3.13 as builder
LABEL maintainer="andy.lo-a-foe@philips.com"
RUN apk add --no-cache git openssh gcc musl-dev
WORKDIR /go-hello-world
COPY go.mod .
COPY go.sum .

# Get dependancies - will also be cached if we won't change mod/sum
RUN go mod download

# Build
COPY . .
RUN go build .

FROM philipslabs/siderite:latest AS siderite

FROM alpine:latest
RUN apk add --no-cache git openssh openssl bash postgresql-client
WORKDIR /app
COPY --from=siderite /app/siderite /app/siderite
COPY --from=builder /go-hello-world/go-hello-world /app

ENTRYPOINT ["/app/siderite","runner"]
