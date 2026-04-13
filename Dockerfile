FROM teddysun/xray:latest

# Install dropbear (tiny SSH server) - takes 5 seconds
RUN apk update && apk add --no-cache dropbear && \
    rm -rf /var/cache/apk/*

# Configure dropbear
RUN mkdir -p /etc/dropbear && \
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && \
    echo "nano:prvtspyyy404" | chpasswd

# Copy Xray config
COPY config.json /etc/xray/config.json

# Entrypoint: start dropbear on port 2222, then Xray on 8080
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'dropbear -p 2222 -E' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
