FROM teddysun/xray:latest

# Generate a self-signed certificate for TLS
RUN apk update && apk add --no-cache openssl && \
    mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/key.pem \
        -out /etc/ssl/certs/cert.pem \
        -subj "/CN=cloud.google.com" && \
    rm -rf /var/cache/apk/*

# Copy the Xray configuration
COPY config.json /etc/xray/config.json

EXPOSE 8080
ENTRYPOINT ["/usr/bin/xray", "run", "-c", "/etc/xray/config.json"]
