# This is a multi-stage Dockerfile and requires >= Docker 17.05
# https://docs.docker.com/engine/userguide/eng-image/multistage-build/
FROM golang:1.17.5-alpine3.15 as builder

#ENV GOPROXY http://proxy.golang.org

RUN mkdir -p /src/workspace
WORKDIR /src/workspace

# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

ADD . .
RUN go build -o /bin/gocron

FROM alpine:3.15

RUN apk add \
  --no-cache \
  bash \
  ca-certificates

COPY --from=builder /bin/gocron /bin
RUN chmod +x /bin/gocron
RUN mkdir -p /app/gocron

WORKDIR /app/gocron

RUN touch .env
ENV GIN_MODE release

ENV PORT 5000
EXPOSE 5000

CMD [ "/bin/gocron" ]
