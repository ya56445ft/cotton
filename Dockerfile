# Stage 1: Build binary
FROM golang:1.22-alpine AS builder
WORKDIR /app

# نصب ابزارها و گیت
RUN apk add --no-cache git curl bash build-base

# کپی کامل سورس
COPY . .

# فعال‌سازی دریافت خودکار نسخه‌های Go و وابستگی‌ها
ENV GOTOOLCHAIN=auto
ENV GOPROXY=https://proxy.golang.org,direct

# دریافت خودکار کامپایلر Go مناسب، ساخت فایل‌های go.mod/go.sum و دانلود پکیج‌ها
RUN if [ ! -f go.mod ]; then go mod init cottendns; fi && \
    go mod tidy && \
    go mod download

# بیلد نهایی پروژه
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-w -s" -o cottendns-server ./cmd/server

# Stage 2: Runtime image
FROM alpine:latest
RUN apk add --no-cache ca-certificates tzdata
WORKDIR /app
COPY --from=builder /app/cottendns-server /app/cottendns-server
COPY server_config.toml.simple /app/server_config.toml

EXPOSE 8080

ENTRYPOINT ["/app/cottendns-server", "-config", "/app/server_config.toml"]
