# Stage 1: Build binary
FROM golang:1.22-alpine AS builder
WORKDIR /app

# نصب ابزارهای مورد نیاز گیت
RUN apk add --no-cache git

# کپی کردن تمام فایل‌های سورس پروژه
COPY . .

# دانلود و دریافت خودکار تمامی پیش‌نیازها و ساخت go.mod / go.sum در صورت عدم وجود
RUN if [ ! -f go.mod ]; then go mod init cottendns; fi && \
    go mod tidy && \
    go mod download

# بیلد کردن پروژه
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-w -s" -o cottendns-server ./cmd/server

# Stage 2: Runtime image
FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/cottendns-server /app/cottendns-server
COPY server_config.toml.simple /app/server_config.toml

EXPOSE 8080

ENTRYPOINT ["/app/cottendns-server", "-config", "/app/server_config.toml"]
