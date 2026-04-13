# Stage 1: Build proxy server (HTTP health + WebSocket proxy)
FROM golang:1.21-alpine AS builder
WORKDIR /app
RUN echo 'package main; import ("io"; "net/http"; "net/http/httputil"; "net/url"; "strings"); func main() { target, _ := url.Parse("http://127.0.0.1:8081"); proxy := httputil.NewSingleHostReverseProxy(target); http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { if strings.HasPrefix(r.URL.Path, "/prvtspyyy") { proxy.ServeHTTP(w, r) } else { w.WriteHeader(200); w.Write([]byte("Prvtspy404")) } }); http.ListenAndServe(":8080", nil) }' > proxy.go
RUN CGO_ENABLED=0 GOOS=linux go build -o proxy proxy.go

# Stage 2: Final image
FROM teddysun/xray:latest

# Install dropbear SSH server
RUN apk update && apk add --no-cache dropbear && rm -rf /var/cache/apk/*
RUN mkdir -p /etc/dropbear && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && echo "nano:saeka404" | chpasswd

# Copy proxy from builder
COPY --from=builder /app/proxy /usr/bin/proxy

# Copy Xray config (VLESS on internal port 8081)
COPY config.json /etc/xray/config.json

# Entrypoint: proxy FIRST (instant), then dropbear, then Xray
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '/usr/bin/proxy &' >> /entrypoint.sh && \
    echo 'dropbear -p 2222 -E &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
