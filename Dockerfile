FROM teddysun/xray:latest

# Install dropbear SSH server
RUN apk update && apk add --no-cache dropbear && \
    rm -rf /var/cache/apk/*

# Configure dropbear
RUN mkdir -p /etc/dropbear && \
    dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key && \
    echo "root:prvtspyyy404" | chpasswd

# Copy Xray config
COPY config.json /etc/xray/config.json

# Entrypoint: dropbear on 2222, Xray on 8080
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'dropbear -p 2222 -E &' >> /entrypoint.sh && \
    echo 'exec /usr/bin/xray run -c /etc/xray/config.json' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
