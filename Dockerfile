# Stage 1: Build binary
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-w -s" -o cottendns-server ./cmd/server

# Stage 2: Runtime image
FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/cottendns-server /app/cottendns-server
COPY server_config.toml.simple /app/server_config.toml

EXPOSE 8080

ENTRYPOINT ["/app/cottendns-server", "-config", "/app/server_config.toml"]
