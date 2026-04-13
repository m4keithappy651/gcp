# Stage 1: Build the tiny health check server
FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN echo 'package main; import "net/http"; func main() { http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(200) }); http.HandleFunc("/prvtspyyy", func(w http.ResponseWriter, r *http.Request) { http.Error(w, "WebSocket required", 400) }); http.ListenAndServe(":8080", nil) }' > main.go
RUN CGO_ENABLED=0 GOOS=linux go build -o health main.go

# Stage 2: Final image with Xray and the health server
FROM teddysun/xray:latest

# Copy the health server binary from the builder stage
COPY --from=builder /app/health /usr/bin/health

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script that runs both services
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/bin/health &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
