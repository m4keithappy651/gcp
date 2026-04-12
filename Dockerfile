FROM teddysun/xray:latest

# Install socat and openssl
RUN apk update && apk add --no-cache socat openssl && rm -rf /var/cache/apk/*

# Generate a self-signed certificate for TLS
RUN mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/key.pem \
        -out /etc/ssl/certs/cert.pem \
        -subj "/CN=cloud.google.com"

# Copy Xray configuration
COPY config.json /etc/xray/config.json

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo '# Start a simple health check responder on port 8080' >> /entrypoint.sh && \
    echo 'while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nOK" | socat TCP-LISTEN:8080,fork,reuseaddr -; done &' >> /entrypoint.sh && \
    echo '# Start Xray as the main foreground process' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
