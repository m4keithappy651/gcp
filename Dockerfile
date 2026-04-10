FROM teddysun/xray:latest

# Install Go to compile a tiny health check server
RUN apk update && apk add --no-cache go git && rm -rf /var/cache/apk/*

# Create a simple Go HTTP health server
RUN echo 'package main; import "net/http"; func main() { http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(200) }); http.ListenAndServe(":8080", nil) }' > /health.go

# Compile the health server
RUN go build -o /health /health.go

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script that runs both services
RUN echo '#!/bin/sh\n/health &\n/usr/bin/xray run -c /etc/xray/config.json' > /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
